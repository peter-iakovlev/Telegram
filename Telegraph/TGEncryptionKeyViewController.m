/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEncryptionKeyViewController.h"

#import "TGInterfaceAssets.h"
#import "TGFont.h"

#import <MTProtoKit/MTEncryption.h>
#import "TGImageUtils.h"
#import "TGStringUtils.h"
#import "TGTimerTarget.h"

#import "TGDatabase.h"

#import "TGMenuView.h"

@interface TGEncryptionKeyViewController ()
{
    TGMenuContainerView *_tooltipContainerView;
    NSTimer *_tooltipTimer;
}

@property (nonatomic) int64_t encryptedConversationId;
@property (nonatomic) int userId;

@property (nonatomic, strong) UIImageView *keyImageView;

@property (nonatomic, strong) UILabel *fingerprintLabel;
@property (nonatomic, strong) UILabel *emojiLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) UIButton *linkButton;

@property (nonatomic, strong) ASHandle *actionHandle;

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
    _fingerprintLabel.userInteractionEnabled = true;
    [self.view addSubview:_fingerprintLabel];
    
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyTapped:)];
//    [_fingerprintLabel addGestureRecognizer:gestureRecognizer];
//    
//    _emojiLabel = [[UILabel alloc] init];
//    _emojiLabel.alpha = 0.0f;
//    _emojiLabel.backgroundColor = [UIColor clearColor];
//    _emojiLabel.font = TGSystemFontOfSize(48.0f);
//    _emojiLabel.userInteractionEnabled = false;
//    [self.view addSubview:_emojiLabel];
//    
//    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyTapped:)];
//    [_emojiLabel addGestureRecognizer:gestureRecognizer];
    
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
                
                NSString *s1 = [[data subdataWithRange:NSMakeRange(0, 8)] stringByEncodingInHexSeparatedByString:@" "];
                NSString *s2 = [[data subdataWithRange:NSMakeRange(8, 8)] stringByEncodingInHexSeparatedByString:@" "];
                NSString *s3 = [[additionalSignature subdataWithRange:NSMakeRange(0, 8)] stringByEncodingInHexSeparatedByString:@" "];
                NSString *s4 = [[additionalSignature subdataWithRange:NSMakeRange(8, 8)] stringByEncodingInHexSeparatedByString:@" "];
                NSString *text = [[NSString alloc] initWithFormat:@"%@\n%@\n%@\n%@", s1, s2, s3, s4];                
                text = [text uppercaseString];
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 3.0f;
                style.lineBreakMode = NSLineBreakByWordWrapping;
                style.alignment = NSTextAlignmentCenter;
                
                NSAttributedString *fingerprintString = [[NSAttributedString alloc] initWithString:text attributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: _fingerprintLabel.font, NSForegroundColorAttributeName: UIColorRGB(0x222222)}];
                
                _fingerprintLabel.attributedText = fingerprintString;
                
//                NSAttributedString *emojiString = [[NSAttributedString alloc] initWithString:[TGStringUtils stringForEmojiHashOfData:additionalSignature count:5 positionExtractor:^int32_t(uint8_t *bytes, int32_t i, int32_t count)
//                {
//                    int32_t num = ((bytes[i * 4] & 0x7f) << 24) | ((bytes[i * 4 + 1] & 0xff) << 16) | ((bytes[i * 4 + 2] & 0xff) << 8) | (bytes[i * 4 + 3] & 0xff);
//                    return num % count;
//                }] attributes:@{NSFontAttributeName: _emojiLabel.font, NSKernAttributeName: @(2.0f)}];
//                
//                _emojiLabel.attributedText = emojiString;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupTooltip];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self tooltipTimerTick];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self tooltipTimerTick];
}

- (void)updateLayout:(CGSize)size
{
    CGSize screenSize = size;
    _fingerprintLabel.hidden = false;
    _emojiLabel.hidden = false;
    
    if (screenSize.width < screenSize.height)
    {
        CGFloat keyOffset = 0.0f;
        CGFloat topInset = 0.0f;
        CGFloat fingerpringOffset = 0.0f;
        CGFloat keySize = 264;
        
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
            keySize = 228.0f;
        } else {
            keyOffset += 12.0f;
            fingerpringOffset += -10.0f;
            topInset += 70.0f;
            keySize = 204.0f;
        }
        
        if (_fingerprintLabel.text.length != 0) {
            [_fingerprintLabel sizeToFit];
            CGSize fingerprintSize = _fingerprintLabel.frame.size;
            
            _fingerprintLabel.frame = CGRectMake(CGFloor((screenSize.width - fingerprintSize.width) / 2), fingerpringOffset + self.controllerInset.top + keyOffset + keySize + 24, fingerprintSize.width, fingerprintSize.height);
            
            [_emojiLabel sizeToFit];
            _emojiLabel.frame = CGRectMake(floor(_fingerprintLabel.frame.origin.x + (_fingerprintLabel.frame.size.width - _emojiLabel.frame.size.width) / 2.0f), floor(_fingerprintLabel.frame.origin.y + (_fingerprintLabel.frame.size.height - _emojiLabel.frame.size.height) / 2.0f), _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
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
        CGFloat keySize = 248;
        
        if (TGIsPad()) {
        } else if ([TGViewController hasVeryLargeScreen]) {
        } else if ([TGViewController hasLargeScreen]) {
        } else if ([TGViewController isWidescreen]) {
        } else {
            _emojiLabel.hidden = true;
            _fingerprintLabel.hidden = true;
        }
        
        _keyImageView.frame = CGRectMake(10, self.controllerInset.top + (size.height - self.controllerInset.top - 248.0f) / 2.0f, keySize, keySize);
        
        CGSize labelSize = [_descriptionLabel sizeThatFits:CGSizeMake(200, 1000)];
        
        CGFloat labelAdditionalHeight = 0.0f;
        
        if (_fingerprintLabel.text.length != 0) {
            [_fingerprintLabel sizeToFit];
            CGSize fingerprintSize = _fingerprintLabel.frame.size;
            
            _fingerprintLabel.frame = CGRectMake(CGFloor((screenSize.width - fingerprintSize.width) / 2), 0.0f, fingerprintSize.width, fingerprintSize.height);
            
            if (!_fingerprintLabel.hidden)
                labelAdditionalHeight += fingerprintSize.height + 20.0f;
        }
        
        _descriptionLabel.frame = CGRectMake(_keyImageView.frame.origin.x + _keyImageView.frame.size.width + CGFloor((screenSize.width - (_keyImageView.frame.origin.x + _keyImageView.frame.size.width) - labelSize.width) / 2), self.controllerInset.top + CGFloor(((screenSize.height - self.controllerInset.top) - (labelSize.height +- labelAdditionalHeight)) / 2), labelSize.width, labelSize.height);
        
        if (_fingerprintLabel.text.length != 0) {
            _fingerprintLabel.frame = CGRectMake(_descriptionLabel.frame.origin.x + CGFloor((_descriptionLabel.frame.size.width - _fingerprintLabel.frame.size.width) / 2), _descriptionLabel.frame.origin.y - 20.0f - _fingerprintLabel.frame.size.height, _fingerprintLabel.frame.size.width, _fingerprintLabel.frame.size.height);
            
            [_emojiLabel sizeToFit];
            _emojiLabel.frame = CGRectMake(floor(_fingerprintLabel.frame.origin.x + (_fingerprintLabel.frame.size.width - _emojiLabel.frame.size.width) / 2.0f), floor(_fingerprintLabel.frame.origin.y + (_fingerprintLabel.frame.size.height - _emojiLabel.frame.size.height) / 2.0f), _emojiLabel.frame.size.width, _emojiLabel.frame.size.height);
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

- (void)keyTapped:(id)__unused sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@(3) forKey:@"TG_displayedEmojifySecretChatTooltip_v1"];
    
    CGFloat emojiTargetAlpha = 0.0f;
    bool emojiInteractionEnabled = false;
    if (_emojiLabel.alpha < FLT_EPSILON)
    {
        emojiTargetAlpha = 1.0f;
        emojiInteractionEnabled = true;
    }
    
    _fingerprintLabel.userInteractionEnabled = false;
    _emojiLabel.userInteractionEnabled = false;
    
    _emojiLabel.transform = emojiInteractionEnabled ? CGAffineTransformMakeScale(0.9f, 0.9f) : CGAffineTransformIdentity;
    _fingerprintLabel.transform = !emojiInteractionEnabled ? CGAffineTransformMakeScale(0.9f, 0.9f) : CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        _emojiLabel.alpha = emojiTargetAlpha;
        _fingerprintLabel.alpha = 1.0f - emojiTargetAlpha;
        
        _emojiLabel.transform = CGAffineTransformIdentity;
        _fingerprintLabel.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished)
    {
        _emojiLabel.userInteractionEnabled = emojiInteractionEnabled;
        _fingerprintLabel.userInteractionEnabled = !emojiInteractionEnabled;
    }];
}

- (void)setupTooltip
{
    return;
//    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
//        return;
//    
//    NSInteger displayed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TG_displayedEmojifySecretChatTooltip_v1"] integerValue];
//#if defined(INTERNAL_RELEASE)
//    //displayed = false;
//#endif
//    if (displayed > 2)
//        return;
//    
//    if (_tooltipContainerView != nil)
//        return;
//    
//    _tooltipTimer = [TGTimerTarget scheduledMainThreadTimerWithTarget:self action:@selector(tooltipTimerTick) interval:3.5 repeat:false];
//    
//    _tooltipContainerView = [[TGMenuContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.view addSubview:_tooltipContainerView];
//    
//    NSMutableArray *actions = [[NSMutableArray alloc] init];
//    [actions addObject:[[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"EncryptionKey.TapToEmojify"), @"title", nil]];
//    
//    [_tooltipContainerView.menuView setButtonsAndActions:actions watcherHandle:self.actionHandle];
//    [_tooltipContainerView.menuView sizeToFit];
//    _tooltipContainerView.menuView.buttonHighlightDisabled = true;
//    
//    CGRect frame = _fingerprintLabel.frame;
//    frame.origin.y += 10.0f;
//    [_tooltipContainerView showMenuFromRect:frame animated:false];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:@(displayed + 1) forKey:@"TG_displayedEmojifySecretChatTooltip_v1"];
}

- (void)tooltipTimerTick
{
    [_tooltipTimer invalidate];
    _tooltipTimer = nil;
    
    [_tooltipContainerView hideMenu];
    _tooltipContainerView = nil;
}

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"menuAction"])
    {
        [_tooltipTimer invalidate];
        _tooltipTimer = nil;
        
        [_tooltipContainerView hideMenu];
        _tooltipContainerView = nil;
    }
}

@end
