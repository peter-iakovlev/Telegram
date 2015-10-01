/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEncryptionKeyViewController.h"

#import "TGInterfaceAssets.h"

#import <MTProtoKit/MTEncryption.h>
#import "TGImageUtils.h"

#import "TGDatabase.h"

@interface TGEncryptionKeyViewController ()

@property (nonatomic) int64_t encryptedConversationId;
@property (nonatomic) int userId;

@property (nonatomic, strong) UIImageView *keyImageView;

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) UIButton *linkButton;

@end

@implementation TGEncryptionKeyViewController

- (id)initWithEncryptedConversationId:(int64_t)encryptedConversationId userId:(int)userId
{
    self = [super init];
    if (self)
    {
        self.titleText = TGLocalized(@"EncryptionKey.Title");
        
        _encryptedConversationId = encryptedConversationId;
        _userId = userId;
        
        _userName = [TGDatabaseInstance() loadUser:userId].displayFirstName;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _keyImageView = [[UIImageView alloc] init];
    [self.view addSubview:_keyImageView];
    
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.textColor = [UIColor blackColor];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.font = [UIFont systemFontOfSize:14];
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionLabel.numberOfLines = 0;
    [self.view addSubview:_descriptionLabel];
    
    _linkButton = [[UIButton alloc] init];
    [_linkButton setBackgroundImage:[UIImage imageNamed:@"Transparent.png"] forState:UIControlStateNormal];
    UIImage *rawLinkImage = [UIImage imageNamed:@"LinkFull.png"];
    [_linkButton setBackgroundImage:[rawLinkImage stretchableImageWithLeftCapWidth:(int)(rawLinkImage.size.width / 2) topCapHeight:(int)(rawLinkImage.size.height / 2)] forState:UIControlStateHighlighted];
    [_linkButton addTarget:self action:@selector(linkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_linkButton];
    
    NSString *textFormat = TGLocalized(@"EncryptionKey.Description");
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, _userName, _userName];
    
    if ([_descriptionLabel respondsToSelector:@selector(setAttributedText:)])
    {
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:_descriptionLabel.font, NSFontAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:_descriptionLabel.font.pointSize], NSFontAttributeName, nil];
        NSDictionary *linkAtts = @{NSForegroundColorAttributeName: TGAccentColor()};
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
        
        [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%1$@"].location, _userName.length)];
        [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%2$@"].location + (_userName.length - @"%1$@".length), _userName.length)];
        [attributedText setAttributes:linkAtts range:[baseText rangeOfString:@"telegram.org"]];
        
        [_descriptionLabel setAttributedText:attributedText];
    }
    else
    {
        [_descriptionLabel setText:baseText];
    }
    
    
    NSData *keySignatureData = [TGDatabaseInstance() encryptionKeySignatureForConversationId:[TGDatabaseInstance() peerIdForEncryptedConversationId:_encryptedConversationId]];
    if (keySignatureData != nil)
    {
        NSData *hashData = keySignatureData;
        if (hashData != nil)
        {
            UIImage *image = TGIdenticonImage(hashData, CGSizeMake(264, 264));
            _keyImageView.image = image;
        }
    }
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
    
    [self updateLayout:self.view.bounds.size];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateLayout:self.view.bounds.size];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    [self updateLayout:self.view.bounds.size];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration {
    [super layoutControllerForSize:size duration:duration];
    
    [self updateLayout:size];
}

- (void)updateLayout:(CGSize)size
{
    CGSize screenSize = size;
    
    CGFloat screenWidth = MIN(screenSize.width, screenSize.height);
    
    if (screenSize.width < screenWidth + FLT_EPSILON)
    {
        CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
     
        CGFloat keySize = [TGViewController isWidescreen] ? 264 : 220;
        
        _keyImageView.frame = CGRectMake(CGFloor((self.view.frame.size.width - keySize) / 2), self.controllerInset.top + 28, keySize, keySize);
        
        _descriptionLabel.frame = CGRectMake(CGFloor((screenSize.width - labelSize.width) / 2), _keyImageView.frame.origin.y + _keyImageView.frame.size.height + 24, labelSize.width, labelSize.height);
        
        NSString *lineText = @"Learn more at telegram.org";
        CGFloat lastWidth = [lineText sizeWithFont:_descriptionLabel.font].width;
        CGFloat prefixWidth = [@"Learn more at " sizeWithFont:_descriptionLabel.font].width;
        CGFloat suffixWidth = [@"telegram.org" sizeWithFont:_descriptionLabel.font].width;
        
        _linkButton.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - lastWidth) / 2) + prefixWidth - 3, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height - 18, suffixWidth + 4, 19);
    }
    else
    {
        _keyImageView.frame = CGRectMake(10, self.controllerInset.top + 10, 248, 248);
        
        CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(200, 1000)];
        
        _descriptionLabel.frame = CGRectMake(_keyImageView.frame.origin.x + _keyImageView.frame.size.width + CGFloor((screenSize.width - (_keyImageView.frame.origin.x + _keyImageView.frame.size.width) - labelSize.width) / 2), self.controllerInset.top + CGFloor(((screenSize.height - self.controllerInset.top) - labelSize.height) / 2), labelSize.width, labelSize.height);
        
        NSString *lineText = @"Learn more at telegram.org";
        CGFloat lastWidth = [lineText sizeWithFont:_descriptionLabel.font].width;
        CGFloat prefixWidth = [@"Learn more at " sizeWithFont:_descriptionLabel.font].width;
        CGFloat suffixWidth = [@"telegram.org" sizeWithFont:_descriptionLabel.font].width;
        
        _linkButton.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - lastWidth) / 2) + prefixWidth - 3, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height - 18, suffixWidth + 4, 19);
    }
}

- (void)linkButtonPressed
{
    [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"http://telegram.org"]];
}

@end
