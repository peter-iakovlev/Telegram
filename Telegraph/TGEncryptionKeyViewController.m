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
#import "TGStringUtils.h"

#import "TGDatabase.h"

@interface TGEncryptionKeyViewController ()

@property (nonatomic) int64_t encryptedConversationId;
@property (nonatomic) int userId;

@property (nonatomic, strong) UIImageView *keyImageView;

@property (nonatomic, strong) UILabel *fingerprintLabel;
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
    
    _fingerprintLabel = [[UILabel alloc] init];
    _fingerprintLabel.textColor = [UIColor blackColor];
    _fingerprintLabel.backgroundColor = [UIColor clearColor];
    NSString *fontName = @"CourierNew-Bold";
    if (iosMajorVersion() >= 7) {
        fontName = @"Menlo-Bold";
    }
    _fingerprintLabel.font = [UIFont fontWithName:fontName size:14];
    _fingerprintLabel.numberOfLines = 4;
    [self.view addSubview:_fingerprintLabel];
    
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
    
    NSData *additionalSignature = nil;
    NSData *keySignatureData = [TGDatabaseInstance() encryptionKeySignatureForConversationId:[TGDatabaseInstance() peerIdForEncryptedConversationId:_encryptedConversationId] additionalSignature:&additionalSignature];
    if (keySignatureData != nil)
    {
        NSData *hashData = keySignatureData;
        if (hashData != nil)
        {
            if (additionalSignature != nil) {
                NSMutableData *data = [[NSMutableData alloc] init];
                [data appendData:keySignatureData];
                [data appendData:additionalSignature];
                
                NSString *s1 = [[data subdataWithRange:NSMakeRange(0, 8)] stringByEncodingInHex];
                NSString *s2 = [[data subdataWithRange:NSMakeRange(8, 8)] stringByEncodingInHex];
                NSString *s3 = [[additionalSignature subdataWithRange:NSMakeRange(0, 8)] stringByEncodingInHex];
                NSString *s4 = [[additionalSignature subdataWithRange:NSMakeRange(8, 8)] stringByEncodingInHex];
                NSString *text = [[NSString alloc] initWithFormat:@"%@\n%@\n%@\n%@", s1, s2, s3, s4];
                
                if (![TGViewController isWidescreen]) {
                    text = [[NSString alloc] initWithFormat:@"%@%@\n%@%@", s1, s2, s3, s4];
                }
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 3.0f;
                style.lineBreakMode = NSLineBreakByWordWrapping;
                style.alignment = NSTextAlignmentCenter;
                
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: _fingerprintLabel.font, NSForegroundColorAttributeName: UIColorRGB(0x222222)}];
                
                _fingerprintLabel.attributedText = attributedString;
            }
            
            UIImage *image = TGIdenticonImage(hashData, additionalSignature, CGSizeMake(264, 264));
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
    
    CGFloat keySize = [TGViewController isWidescreen] ? 264 : 220;
    
    _fingerprintLabel.alpha = 1.0f;
    
    if (screenSize.width < screenSize.height)
    {
        CGFloat keyOffset = 0.0f;
        CGFloat topInset = 0.0f;
        CGFloat fingerpringOffset = 0.0f;
        
        if (TGIsPad()) {
            keyOffset += 12.0f;
            fingerpringOffset += -12.0f;
            topInset += 70.0f;
        } else if ([TGViewController hasVeryLargeScreen]) {
            keyOffset += 60.0f;
            fingerpringOffset += 3.0f;
            topInset += 102.0f;
        } else if ([TGViewController hasLargeScreen]) {
            keyOffset += 50.0f;
            fingerpringOffset += -1.0f;
            topInset += 89.0f;
        } else if ([TGViewController isWidescreen]) {
            keyOffset += 12.0f;
            fingerpringOffset += -12.0f;
            topInset += 70.0f;
        } else {
            keyOffset += 12.0f;
            fingerpringOffset += -10.0f;
            topInset += 30.0f;
        }
        
        if (_fingerprintLabel.text.length != 0) {
            [_fingerprintLabel sizeToFit];
            CGSize fingerprintSize = _fingerprintLabel.frame.size;
            
            _fingerprintLabel.frame = CGRectMake(CGFloor((screenSize.width - fingerprintSize.width) / 2), fingerpringOffset + self.controllerInset.top + keyOffset + keySize + 24, fingerprintSize.width, fingerprintSize.height);
        }
        
        CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(screenSize.width - 20, 1000)];
        
        _keyImageView.frame = CGRectMake(CGFloor((self.view.frame.size.width - keySize) / 2), self.controllerInset.top + keyOffset, keySize, keySize);
        
        _descriptionLabel.frame = CGRectMake(CGFloor((screenSize.width - labelSize.width) / 2), _keyImageView.frame.origin.y + _keyImageView.frame.size.height + 24 + topInset, labelSize.width, labelSize.height);
        
        NSString *lineText = @"Learn more at telegram.org";
        CGFloat lastWidth = [lineText sizeWithFont:_descriptionLabel.font].width;
        CGFloat prefixWidth = [@"Learn more at " sizeWithFont:_descriptionLabel.font].width;
        CGFloat suffixWidth = [@"telegram.org" sizeWithFont:_descriptionLabel.font].width;
        
        _linkButton.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - lastWidth) / 2) + prefixWidth - 3, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height - 18, suffixWidth + 4, 19);
    }
    else
    {
        if (TGIsPad()) {
        } else if ([TGViewController hasVeryLargeScreen]) {
        } else if ([TGViewController hasLargeScreen]) {
        } else if ([TGViewController isWidescreen]) {
        } else {
            _fingerprintLabel.alpha = 0.0f;
        }
        
        _keyImageView.frame = CGRectMake(10, self.controllerInset.top + (size.height - self.controllerInset.top - 248.0f) / 2.0f, 248, 248);
        
        CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(200, 1000)];
        
        CGFloat labelAdditionalHeight = 0.0f;
        
        if (_fingerprintLabel.text.length != 0) {
            [_fingerprintLabel sizeToFit];
            CGSize fingerprintSize = _fingerprintLabel.frame.size;
            
            _fingerprintLabel.frame = CGRectMake(CGFloor((screenSize.width - fingerprintSize.width) / 2), 0.0f, fingerprintSize.width, fingerprintSize.height);
            
            labelAdditionalHeight += fingerprintSize.height + 20.0f;
        }
        
        _descriptionLabel.frame = CGRectMake(_keyImageView.frame.origin.x + _keyImageView.frame.size.width + CGFloor((screenSize.width - (_keyImageView.frame.origin.x + _keyImageView.frame.size.width) - labelSize.width) / 2), self.controllerInset.top + CGFloor(((screenSize.height - self.controllerInset.top) - (labelSize.height +- labelAdditionalHeight)) / 2), labelSize.width, labelSize.height);
        
        if (_fingerprintLabel.text.length != 0) {
            _fingerprintLabel.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - _fingerprintLabel.frame.size.width) / 2), _descriptionLabel.frame.origin.y - 20.0f - _fingerprintLabel.frame.size.height, _fingerprintLabel.frame.size.width, _fingerprintLabel.frame.size.height);
        }
        
        NSString *lineText = @"Learn more at telegram.org";
        CGFloat lastWidth = [lineText sizeWithFont:_descriptionLabel.font].width;
        CGFloat prefixWidth = [@"Learn more at " sizeWithFont:_descriptionLabel.font].width;
        CGFloat suffixWidth = [@"telegram.org" sizeWithFont:_descriptionLabel.font].width;
        
        _linkButton.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - lastWidth) / 2) + prefixWidth - 3, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height - 18, suffixWidth + 4, 19);
    }
}

- (void)linkButtonPressed
{
    [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:@"https://telegram.org/faq#secret-chats"]];
}

@end
