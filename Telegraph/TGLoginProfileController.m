#import "TGLoginProfileController.h"

#import "TGToolbarButton.h"

#import "TGImageUtils.h"

#import "TGHacks.h"
#import "TGFont.h"

#import "UIDevice+PlatformInfo.h"

#import "TGImageUtils.h"

#import "TGAppDelegate.h"

#import "TGSignUpRequestBuilder.h"

#import "TGTelegraph.h"
#import "SGraphObjectNode.h"
#import "TGDatabase.h"

#import "TGLoginInactiveUserController.h"

#import "TGHighlightableButton.h"

#import "TGRemoteImageView.h"

#import "TGActivityIndicatorView.h"

#import "TGApplication.h"

#import "TGProgressWindow.h"

#import "TGTextField.h"

#import "TGActionSheet.h"

#import "TGAlertView.h"

#import "TGMediaAvatarMenuMixin.h"

#define TGAvatarActionSheetTag ((int)0xF3AEE8CC)
#define TGImageSourceActionSheetTag ((int)0x34281CB0)

@interface TGLoginProfileController () <UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>
{
    bool _dismissing;
    
    UIView *_grayBackground;
    UIView *_separatorView;
    UILabel *_titleLabel;
    UILabel *_noticeLabel;
    UIView *_firstNameSeparator;
    UIView *_lastNameSeparator;
    
    bool _didDisappear;
    
    TGMediaAvatarMenuMixin *_avatarMixin;
}

@property (nonatomic) bool showKeyboard;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *phoneCodeHash;
@property (nonatomic, strong) NSString *phoneCode;

@property (nonatomic, strong) TGHighlightableButton *addPhotoButton;
@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) TGTextField *firstNameField;
@property (nonatomic, strong) TGTextField *lastNameField;

@property (nonatomic) CGRect baseFirstNameFieldBackgroundFrame;
@property (nonatomic) CGRect baseFirstNameFieldFrame;
@property (nonatomic) CGRect baseLastNameBackgroundFrame;
@property (nonatomic) CGRect baseLastNameFieldFrame;

@property (nonatomic) bool inProgress;
@property (nonatomic) int currentActionIndex;

@property (nonatomic, strong) UIAlertView *currentAlert;
@property (nonatomic, strong) UIActionSheet *currentActionSheet;

@property (nonatomic, strong) UIImage *imageForPhotoUpload;
@property (nonatomic, strong) NSData *dataForPhotoUpload;

@property (nonatomic, strong) TGProgressWindow *progressWindow;

@end

@implementation TGLoginProfileController

- (id)initWithShowKeyboard:(bool)showKeyboard phoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneCode:(NSString *)phoneCode
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _showKeyboard = showKeyboard;
        _phoneNumber = phoneNumber;
        _phoneCodeHash = phoneCodeHash;
        _phoneCode = phoneCode;
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Next") style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonPressed)]];
        
        [ActionStageInstance() watchForPath:@"/tg/activation" watcher:self];
        [ActionStageInstance() watchForPath:@"/tg/contactListSynchronizationState" watcher:self];
    }
    return self;
}

- (void)dealloc
{
    [self doUnloadView];
    
    _currentAlert.delegate = nil;
    _currentActionSheet.delegate = nil;
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (bool)shouldBeRemovedFromNavigationAfterHiding
{
    return true;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    _grayBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenSize.width, ([TGViewController isWidescreen] ? 131.0f : 90.0f))];
    _grayBackground.backgroundColor = UIColorRGB(0xf2f2f2);
    [self.view addSubview:_grayBackground];
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _grayBackground.frame.origin.y + _grayBackground.frame.size.height, screenSize.width, TGScreenPixel)];
    _separatorView.backgroundColor = TGSeparatorColor();
    [self.view addSubview:_separatorView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = TGIsPad() ? TGUltralightSystemFontOfSize(48.0f) : TGLightSystemFontOfSize(30.0f);
    _titleLabel.text = TGLocalized(@"Login.InfoTitle");
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(CGFloor((screenSize.width - _titleLabel.frame.size.width) / 2), [TGViewController isWidescreen] ? 71.0f : 48.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    [self.view addSubview:_titleLabel];
    
    static UIImage *buttonImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(110, 110), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 110.0f, 110.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 109.0f, 109.0f));
        
        buttonImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    _addPhotoButton = [[TGHighlightableButton alloc] initWithFrame:CGRectMake(10 + TGRetinaPixel, _separatorView.frame.origin.y + 11, buttonImage.size.width, buttonImage.size.height)];
    _addPhotoButton.exclusiveTouch = true;
    [_addPhotoButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [_addPhotoButton addTarget:self action:@selector(addPhotoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addPhotoButton];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + TGRetinaPixel, _separatorView.frame.origin.y + 11, 110, 110)];
    _avatarView.hidden = true;
    _avatarView.userInteractionEnabled = true;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)]];
    
    [self.view addSubview:_avatarView];
    
    UILabel *addPhotoLabelFirst = [[UILabel alloc] init];
    addPhotoLabelFirst.text = TGLocalized(@"Login.InfoAvatarAdd");
    addPhotoLabelFirst.font = TGSystemFontOfSize(15);
    addPhotoLabelFirst.backgroundColor = [UIColor clearColor];
    addPhotoLabelFirst.textColor = UIColorRGB(0xd9d9d9);
    [addPhotoLabelFirst sizeToFit];
    
    UILabel *addPhotoLabelSecond = [[UILabel alloc] init];
    addPhotoLabelSecond.text = TGLocalized(@"Login.InfoAvatarPhoto");
    addPhotoLabelSecond.font = TGSystemFontOfSize(15);
    addPhotoLabelSecond.backgroundColor = [UIColor clearColor];
    addPhotoLabelSecond.textColor = UIColorRGB(0xd9d9d9);
    [addPhotoLabelSecond sizeToFit];
    
    addPhotoLabelFirst.frame = CGRectIntegral(CGRectMake((_addPhotoButton.frame.size.width - addPhotoLabelFirst.frame.size.width) / 2, 36, addPhotoLabelFirst.frame.size.width, addPhotoLabelFirst.frame.size.height));
    addPhotoLabelSecond.frame = CGRectIntegral(CGRectMake((_addPhotoButton.frame.size.width - addPhotoLabelSecond.frame.size.width) / 2, 36 + 22, addPhotoLabelSecond.frame.size.width, addPhotoLabelSecond.frame.size.height));
    
    [_addPhotoButton addSubview:addPhotoLabelFirst];
    [_addPhotoButton addSubview:addPhotoLabelSecond];
    
    _firstNameSeparator = [[UIView alloc] initWithFrame:CGRectMake(134.0f, _separatorView.frame.origin.y + 64.0f, screenSize.width - 134.0f, TGScreenPixel)];
    _firstNameSeparator.backgroundColor = TGSeparatorColor();
    [self.view addSubview:_firstNameSeparator];
    
    _lastNameSeparator = [[UIView alloc] initWithFrame:CGRectMake(134.0f, _separatorView.frame.origin.y + 121.0f, screenSize.width - 134.0f, TGScreenPixel)];
    _lastNameSeparator.backgroundColor = TGSeparatorColor();
    [self.view addSubview:_lastNameSeparator];
    
    _firstNameField = [[TGTextField alloc] init];
    _firstNameField.font = TGSystemFontOfSize(20.0f);
    _firstNameField.backgroundColor = [UIColor clearColor];
    _firstNameField.textColor = [UIColor blackColor];
    _firstNameField.placeholder = TGLocalized(@"Login.InfoFirstNamePlaceholder");
    _firstNameField.keyboardType = UIKeyboardTypeDefault;
    _firstNameField.returnKeyType = UIReturnKeyNext;
    _firstNameField.delegate = self;
    _firstNameField.placeholderColor = UIColorRGB(0xc7c7cd);
    _firstNameField.placeholderFont = _firstNameField.font;
    _firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _firstNameField.frame = CGRectMake(135.0f, _firstNameSeparator.frame.origin.y - 56.0f, screenSize.width - 134.0f - 8.0f, 56.0f);
    [self.view addSubview:_firstNameField];
    
    _lastNameField = [[TGTextField alloc] init];
    _lastNameField.font = TGSystemFontOfSize(20.0f);
    _lastNameField.backgroundColor = [UIColor clearColor];
    _lastNameField.placeholder = TGLocalized(@"Login.InfoLastNamePlaceholder");
    _lastNameField.keyboardType = UIKeyboardTypeDefault;
    _lastNameField.returnKeyType = UIReturnKeyDone;
    _lastNameField.delegate = self;
    _lastNameField.placeholderColor = UIColorRGB(0xc7c7cd);
    _lastNameField.placeholderFont = _lastNameField.font;
    _lastNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _lastNameField.frame = CGRectMake(135.0f, _lastNameSeparator.frame.origin.y - 56.0f, screenSize.width - 134.0f - 8.0f, 56.0f);
    [self.view addSubview:_lastNameField];
    
    _noticeLabel = [[UILabel alloc] init];
    _noticeLabel.font = TGSystemFontOfSize(17.0f);
    _noticeLabel.textColor = UIColorRGB(0x999999);
    _noticeLabel.text = TGLocalized(@"Login.InfoHelp");
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.contentMode = UIViewContentModeCenter;
    _noticeLabel.numberOfLines = 0;
    CGSize noticeSize = [_noticeLabel sizeThatFits:CGSizeMake(200.0f, CGFLOAT_MAX)];
    _noticeLabel.frame = CGRectMake(CGFloor((screenSize.width - noticeSize.width) / 2.0f), [TGViewController isWidescreen] ? 274.0f : 218.0f, noticeSize.width, noticeSize.height);
    _noticeLabel.alpha = [TGViewController isWidescreen] ? 1.0f : 0.0f;
    [self.view addSubview:_noticeLabel];
    
    [self updateInterface:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return true;
}

- (void)doUnloadView
{
    _firstNameField.delegate = nil;
    _lastNameField.delegate = nil;
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setNeedsLayout];
    
    [super viewWillAppear:animated];
    
    if (_didDisappear)
        [_firstNameField becomeFirstResponder];
    
    [self updateInterface:self.interfaceOrientation];
}

- (void)viewDidLayoutSubviews
{
    if (!_firstNameField.isFirstResponder && !_lastNameField.isFirstResponder)
        [_firstNameField becomeFirstResponder];
    
    [super viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _dismissing = ![self.navigationController.viewControllers containsObject:self];
    
    _didDisappear = true;
    
    [super viewWillDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateInterface:toInterfaceOrientation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_dismissing)
        [TGAppDelegateInstance resetLoginState];
    
    [super viewDidDisappear:animated];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    //[self updateInterface:UIInterfaceOrientationPortrait];
}

- (void)updateInterface:(UIInterfaceOrientation)orientation
{
    CGFloat topOffset = 0.0f;
    CGFloat titleLabelOffset = 0.0f;
    CGFloat noticeLabelOffset = 0.0f;
    CGFloat countryButtonOffset = 0.0f;
    CGFloat sideInset = 0.0f;
    
    if (TGIsPad())
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            topOffset = 305.0f;
            titleLabelOffset = topOffset - 108.0f;
        }
        else
        {
            topOffset = 135.0f;
            titleLabelOffset = topOffset - 78.0f;
        }
        
        noticeLabelOffset = topOffset + 143.0f;
        countryButtonOffset = topOffset;
        sideInset = 130.0f;
    }
    else
    {
        topOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
        titleLabelOffset = [TGViewController isWidescreen] ? 71.0f : 48.0f;
        noticeLabelOffset = [TGViewController isWidescreen] ? 274.0f : 218.0f;
        countryButtonOffset = [TGViewController isWidescreen] ? 131.0f : 90.0f;
    }
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:orientation];
    
    _grayBackground.frame = CGRectMake(0.0f, 0.0f, screenSize.width, topOffset);
    _separatorView.frame = CGRectMake(0.0f, topOffset, screenSize.width, _separatorView.frame.size.height);
    
    _titleLabel.frame = CGRectMake(CGFloor((screenSize.width - _titleLabel.frame.size.width) / 2), titleLabelOffset, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
    _addPhotoButton.frame = CGRectMake(10 + TGRetinaPixel + sideInset, _separatorView.frame.origin.y + 11, _addPhotoButton.frame.size.width, _addPhotoButton.frame.size.height);
    
    _avatarView.frame = CGRectMake(10 + TGRetinaPixel + sideInset, _separatorView.frame.origin.y + 11, 110, 110);
    
    _firstNameSeparator.frame = CGRectMake(134.0f + sideInset, _separatorView.frame.origin.y + 64.0f, screenSize.width - 134.0f - sideInset * 2.0f, TGScreenPixel);
    
    _lastNameSeparator.frame = CGRectMake(134.0f + sideInset, _separatorView.frame.origin.y + 121.0f, screenSize.width - 134.0f - sideInset * 2.0f, TGScreenPixel);
    
    _firstNameField.frame = CGRectMake(135.0f + sideInset, _firstNameSeparator.frame.origin.y - 56.0f, screenSize.width - 134.0f - 8.0f - sideInset * 2.0f, 56.0f);
    
    _lastNameField.frame = CGRectMake(135.0f + sideInset, _lastNameSeparator.frame.origin.y - 56.0f, screenSize.width - 134.0f - 8.0f - sideInset * 2.0f, 56.0f);
    
    CGSize noticeSize = [_noticeLabel sizeThatFits:CGSizeMake(200.0f, CGFLOAT_MAX)];
    _noticeLabel.frame = CGRectMake(CGFloor((screenSize.width - noticeSize.width) / 2.0f), noticeLabelOffset, noticeSize.width, noticeSize.height);
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _firstNameField)
    {
        [_lastNameField becomeFirstResponder];
    }
    else if (textField == _lastNameField)
    {
        [self nextButtonPressed];
    }
    
    return false;
}

#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_inProgress)
        return false;
    
    if (textField == _firstNameField || textField == _lastNameField)
    {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (newText.length > 30)
            return false;
        return true;
    }
    
    return true;
}

#pragma mark -


- (void)setInProgress:(bool)inProgress
{
    if (_inProgress != inProgress)
    {
        _inProgress = inProgress;
        
        if (inProgress)
        {
            _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [_progressWindow show:true];
        }
        else
        {
            if (_progressWindow != nil)
            {
                [_progressWindow dismiss:true];
                _progressWindow = nil;
            }
        }
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)__unused recognizer
{

}

- (void)inputFirstNameBackgroundTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_firstNameField becomeFirstResponder];
    }
}

- (void)inputLastNameBackgroundTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [_lastNameField becomeFirstResponder];
    }
}

- (void)shakeView:(UIView *)v originalX:(CGFloat)originalX
{
    CGRect r = v.frame;
    r.origin.x = originalX;
    CGRect originalFrame = r;
    CGRect rFirst = r;
    rFirst.origin.x = r.origin.x + 4;
    r.origin.x = r.origin.x - 4;
    
    v.frame = v.frame;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionAutoreverse animations:^
    {
        v.frame = rFirst;
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            [UIView animateWithDuration:0.05 delay:0.0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^
            {
                [UIView setAnimationRepeatCount:3];
                v.frame = r;
            } completion:^(__unused BOOL finished)
            {
                v.frame = originalFrame;
            }];
        }
        else
            v.frame = originalFrame;
    }];
}

- (NSString *)cleanString:(NSString *)string
{
    if (string.length == 0)
        return @"";
    
    NSString *withoutWhitespace = [string stringByReplacingOccurrencesOfString:@" +" withString:@" "
                                                                       options:NSRegularExpressionSearch
                                                                         range:NSMakeRange(0, string.length)];
    withoutWhitespace = [withoutWhitespace stringByReplacingOccurrencesOfString:@"\n\n+" withString:@"\n\n"
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, withoutWhitespace.length)];
    return [withoutWhitespace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)nextButtonPressed
{
    if (_inProgress)
        return;
    
    NSString *firstNameText = [self cleanString:_firstNameField.text];
    NSString *lastNameText = [self cleanString:_lastNameField.text];
    
    if (firstNameText.length == 0)
    {
        CGFloat sideInset = 0.0f;
        
        if (TGIsPad())
        {
            sideInset = 130.0f;
        }
        
        [self shakeView:_firstNameField originalX:135.0f + sideInset];
    }
    else
    {
        self.inProgress = true;
        
        static int actionIndex = 0;
        _currentActionIndex = actionIndex++;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/service/auth/signUp/(%d)", _currentActionIndex] options:[NSDictionary dictionaryWithObjectsAndKeys:_phoneNumber, @"phoneNumber", _phoneCode, @"phoneCode", _phoneCodeHash, @"phoneCodeHash", firstNameText, @"firstName", lastNameText, @"lastName", nil] watcher:self];
    }
}

- (void)addPhotoButtonPressed
{
    __weak TGLoginProfileController *weakSelf = self;
    _avatarMixin = [[TGMediaAvatarMenuMixin alloc] initWithParentController:self hasDeleteButton:false personalPhoto:true];
    _avatarMixin.didFinishWithImage = ^(UIImage *image)
    {
        __strong TGLoginProfileController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateProfileImage:image];
        strongSelf->_avatarMixin = nil;
    };
    _avatarMixin.didDismiss = ^
    {
        __strong TGLoginProfileController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_avatarMixin = nil;
    };
    [_avatarMixin present];
}

- (void)avatarTapped:(UITapGestureRecognizer *)__unused recognizer
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Login.InfoDeletePhoto") action:@"delete" type:TGActionSheetActionTypeDestructive]];
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(TGLoginProfileController *controller, NSString *action)
    {
        if ([action isEqualToString:@"delete"])
            [controller _deletePhoto];
    } target:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [actionSheet showInView:self.view];
    }
    else
    {
        [actionSheet showFromRect:[recognizer.view.superview convertRect:recognizer.view.frame toView:self.view] inView:self.view animated:true];
    }
}

- (void)_deletePhoto
{
    _addPhotoButton.alpha = 1.0f;
    _addPhotoButton.hidden = false;
    _avatarView.image = nil;
    _avatarView.alpha = 0.0f;
    _avatarView.hidden = true;
    _dataForPhotoUpload = nil;
    _imageForPhotoUpload = nil;
}

- (void)_updateProfileImage:(UIImage *)image
{
    if (image == nil)
        return;
    
    if (MIN(image.size.width, image.size.height) < 160.0f)
        image = TGScaleImageToPixelSize(image, CGSizeMake(160, 160));
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    if (imageData == nil)
        return;
    
    TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:110x110"];
    UIImage *avatarImage = filter(image);
    
    _avatarView.hidden = false;
    _avatarView.alpha = 1.0f;
    _addPhotoButton.hidden = true;
    _addPhotoButton.alpha = 0.0f;
    _avatarView.image = avatarImage;
    
    _dataForPhotoUpload = imageData;
    _imageForPhotoUpload = ([TGRemoteImageView imageProcessorForName:@"circle:64x64"])(image);
}

#pragma mark -

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)__unused result
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/service/auth/signUp/(%d)", _currentActionIndex]])
    {
        if (resultCode == ASStatusSuccess && _dataForPhotoUpload != nil)
        {
            NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
            
            uint8_t fileId[32];
            arc4random_buf(&fileId, 32);
            
            NSMutableString *filePath = [[NSMutableString alloc] init];
            for (int i = 0; i < 32; i++)
            {
                [filePath appendFormat:@"%02x", fileId[i]];
            }
            
            NSString *tmpImagesPath = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"upload"];
            static NSFileManager *fileManager = nil;
            if (fileManager == nil)
                fileManager = [[NSFileManager alloc] init];
            NSError *error = nil;
            [fileManager createDirectoryAtPath:tmpImagesPath withIntermediateDirectories:true attributes:nil error:&error];
            NSString *absoluteFilePath = [tmpImagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", filePath]];
            [_dataForPhotoUpload writeToFile:absoluteFilePath atomically:true];
            
            [options setObject:filePath forKey:@"originalFileUrl"];
            [options setObject:_imageForPhotoUpload forKey:@"currentPhoto"];
            
            NSString *action = [[NSString alloc] initWithFormat:@"/tg/timeline/(%d)/uploadPhoto/(%@)", TGTelegraphInstance.clientUserId, filePath];
            [ActionStageInstance() requestActor:action options:options watcher:TGTelegraphInstance];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (resultCode == ASStatusSuccess)
            {
                if ([[((SGraphObjectNode *)result).object objectForKey:@"activated"] boolValue])
                {
                    self.inProgress = false;
                    
                    [TGAppDelegateInstance presentMainController];
                }
            }
            else
            {
                self.inProgress = false;
                
                NSString *errorText = @"Unknown error";
                if (resultCode == TGSignUpResultInvalidToken)
                    errorText = TGLocalized(@"Login.InvalidCodeError");
                else if (resultCode == TGSignUpResultNetworkError)
                    errorText = TGLocalized(@"Login.NetworkError");
                else if (resultCode == TGSignUpResultTokenExpired)
                    errorText = TGLocalized(@"Login.CodeExpiredError");
                else if (resultCode == TGSignUpResultFloodWait)
                    errorText = TGLocalized(@"Login.CodeFloodError");
                else if (resultCode == TGSignUpResultInvalidFirstName)
                    errorText = TGLocalized(@"Login.InvalidFirstNameError");
                else if (resultCode == TGSignUpResultInvalidLastName)
                    errorText = TGLocalized(@"Login.InvalidLastNameError");
                
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:TGLocalized(@"Common.OK") otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/activation"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if ([((SGraphObjectNode *)resource).object boolValue])
                [TGAppDelegateInstance presentMainController];
            else
            {
                if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[TGLoginInactiveUserController class]])
                {
                    TGLoginInactiveUserController *inactiveUserController = [[TGLoginInactiveUserController alloc] init];
                    [self.navigationController pushViewController:inactiveUserController animated:true];
                }
            }
        });
    }
    else if ([path isEqualToString:@"/tg/contactListSynchronizationState"])
    {
        if (![((SGraphObjectNode *)resource).object boolValue])
        {
            bool activated = [TGDatabaseInstance() haveRemoteContactUids];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                if (activated)
                    [TGAppDelegateInstance presentMainController];
                else
                {
                    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[TGLoginInactiveUserController class]])
                    {
                        TGLoginInactiveUserController *inactiveUserController = [[TGLoginInactiveUserController alloc] init];
                        [self.navigationController pushViewController:inactiveUserController animated:true];
                    }
                    else
                        self.inProgress = false;
                }
            });
        }
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)__unused options
{
    if ([action isEqualToString:@"dismissCamera"])
    {
#if TG_USE_CUSTOM_CAMERA
        if (_cameraWindow != nil)
        {
            [_cameraWindow dismiss];
            _cameraWindow = nil;
        }
#endif
    }
    else if ([action isEqualToString:@"cameraCompleted"])
    {
#if TG_USE_CUSTOM_CAMERA
        if (_cameraWindow != nil)
        {
            NSData *imageData = [options objectForKey:@"imageData"];
            UIImage *image = [options objectForKey:@"image"];
            
            if (imageData == nil)
                return;
            
            TGImageProcessor filter = [TGRemoteImageView imageProcessorForName:@"circle:110x110"];
            UIImage *toImage = filter(image);
            
            [_avatarView viewWithTag:123].alpha = 0.0f;
            
            [_cameraWindow dismissToRect:[_avatarView convertRect:_avatarView.bounds toView:self.view.window] fromImage:image toImage:toImage toView:self.view aboveView:_avatarView interfaceOrientation:self.interfaceOrientation];
            _cameraWindow = nil;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0.29 * TGAnimationSpeedFactor()) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                _avatarView.hidden = false;
                _avatarView.alpha = 1.0f;
                _addPhotoButton.hidden = true;
                _addPhotoButton.alpha = 0.0f;
                _avatarView.image = toImage;
                
                _dataForPhotoUpload = imageData;
                _imageForPhotoUpload = ([TGRemoteImageView imageProcessorForName:@"circle:64x64"])(image);
                
                [UIView animateWithDuration:0.25 animations:^
                {
                    [_avatarView viewWithTag:123].alpha = 1.0f;
                }];
            });
        }
#endif
    }
}

@end
