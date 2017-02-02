#import "TGCallAlertView.h"

#import "TGAppDelegate.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGOverlayController.h"
#import "TGOverlayControllerWindow.h"

#import "TGModernButton.h"

const CGFloat TGCallAlertViewWidth = 270.0f;
const CGFloat TGCallAlertViewButtonHeight = 44.0f;

@interface TGCallAlertViewController : TGOverlayController
{
    TGCallAlertView *_alertView;
}

- (instancetype)initWithView:(TGCallAlertView *)view;

@end

@interface TGCallAlertView ()
{
    UIView *_dimView;
    UIView *_backgroundView;
    UILabel *_titleLabel;
    UILabel *_messageLabel;
    UIView *_customView;
    UIView *_horizontalSeparator;
    UIView *_verticalSeparator;
    TGModernButton *_cancelButton;
    TGModernButton *_doneButton;
    
    void (^_completionBlock)(bool);
}

@property (nonatomic, copy) void (^onDismiss)(void);

@end

@implementation TGCallAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool))completionBlock
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        self.alpha = 0.0f;
        
        _completionBlock = [completionBlock copy];
        
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = UIColorRGBA(0x000000, 0.4f);
        [self addSubview:_dimView];
        
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        _backgroundView.layer.rasterizationScale = TGScreenScaling();
        _backgroundView.layer.shouldRasterize = true;
        _backgroundView.layer.cornerRadius = 12.0f;
        _backgroundView.layer.masksToBounds = true;
        [self addSubview:_backgroundView];
        
        if (title.length > 0)
        {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.backgroundColor = [UIColor whiteColor];
            _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
            _titleLabel.numberOfLines = 0;
            _titleLabel.text = title;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.textColor = [UIColor blackColor];
            [_titleLabel sizeToFit];
            [_backgroundView addSubview:_titleLabel];
            
            CGSize size = [_titleLabel sizeThatFits:CGSizeMake(TGCallAlertViewWidth, FLT_MAX)];
            _titleLabel.frame = CGRectMake(0.0f, 0.0f, ceil(size.width), ceil(size.height));
        }
        
        if (customView != nil)
        {
            _customView = customView;
            [_backgroundView addSubview:_customView];
        }
        
        if (message.length > 0)
        {
            _messageLabel = [[UILabel alloc] init];
            _messageLabel.backgroundColor = [UIColor whiteColor];
            _messageLabel.font = TGSystemFontOfSize(13.0f);
            _messageLabel.numberOfLines = 0;
            _messageLabel.text = message;
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.textColor = [UIColor blackColor];
            [_messageLabel sizeToFit];
            [_backgroundView addSubview:_messageLabel];
            
            CGSize size = [_messageLabel sizeThatFits:CGSizeMake(TGCallAlertViewWidth, FLT_MAX)];
            _messageLabel.frame = CGRectMake(0.0f, 0.0f, ceil(size.width), ceil(size.height));
        }
        
        _cancelButton = [[TGModernButton alloc] init];
        _cancelButton.exclusiveTouch = true;
        _cancelButton.titleLabel.font = TGSystemFontOfSize(17.0f);
        _cancelButton.highlightBackgroundColor = UIColorRGB(0xebebeb);
        [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:TGAccentColor()];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_cancelButton];
        
        _horizontalSeparator = [[UIView alloc] init];
        _horizontalSeparator.backgroundColor = UIColorRGB(0xc3c3c8);
        _horizontalSeparator.userInteractionEnabled = false;
        [_backgroundView addSubview:_horizontalSeparator];
     
        if (doneButtonTitle.length > 0)
        {
            _doneButton = [[TGModernButton alloc] init];
            _doneButton.exclusiveTouch = true;
            _doneButton.titleLabel.font = TGBoldSystemFontOfSize(17.0f);
            _doneButton.highlightBackgroundColor = UIColorRGB(0xebebeb);
            [_doneButton setTitle:doneButtonTitle forState:UIControlStateNormal];
            [_doneButton setTitleColor:TGAccentColor()];
            [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [_backgroundView addSubview:_doneButton];
            
            _verticalSeparator = [[UIView alloc] init];
            _verticalSeparator.backgroundColor = UIColorRGB(0xc3c3c8);
            _verticalSeparator.userInteractionEnabled = false;
            [_backgroundView addSubview:_verticalSeparator];
        }
    }
    return self;
}

- (void)cancelButtonPressed
{
    [self dismiss:false];
}

- (void)doneButtonPressed
{
    [self dismiss:true];
}

- (void)present
{
    [UIView animateWithDuration:0.2 animations:^
    {
        self.alpha = 1.0f;
    }];
    
    _backgroundView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        _backgroundView.transform = CGAffineTransformIdentity;
    } completion:^(__unused BOOL finished)
    {
        
    }];
}

- (void)dismiss:(bool)done
{
    self.userInteractionEnabled = false;
    
    [UIView animateWithDuration:0.2 animations:^
    {
        self.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (_onDismiss != nil)
            _onDismiss();
    }];
    
    if (_completionBlock != nil)
        _completionBlock(done);
}

- (void)layoutSubviews
{
    _dimView.frame = self.bounds;
    
    CGFloat width = TGCallAlertViewWidth;
    CGFloat height = 20.0f;
    
    if (_titleLabel != nil)
    {
        _titleLabel.frame = CGRectMake((width - _titleLabel.frame.size.width) / 2.0f, height, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    
        height = CGRectGetMaxY(_titleLabel.frame);
        
        if (_customView != nil || _messageLabel != nil)
            height += 13.0f;
    }
    
    if (_customView != nil)
    {
        _customView.frame = CGRectMake((width - _customView.frame.size.width) / 2.0f, height, _customView.frame.size.width, _customView.frame.size.height);
        
        height = CGRectGetMaxY(_customView.frame);
        
        if (_messageLabel != nil)
            height += 15.0f;
    }
    
    if (_messageLabel != nil)
    {
        _messageLabel.frame = CGRectMake((width - _messageLabel.frame.size.width) / 2.0f, height, _messageLabel.frame.size.width, _messageLabel.frame.size.height);
        
        height = CGRectGetMaxY(_messageLabel.frame);
    }
    
    height += 20.0f;
    
    CGFloat separatorThickness = (TGScreenScaling() == 2) ? 0.5f : 1.0f;
    _horizontalSeparator.frame = CGRectMake(0, height, width, separatorThickness);
    _verticalSeparator.frame = CGRectMake(width / 2.0f, height, separatorThickness, TGCallAlertViewButtonHeight);
    
    CGFloat cancelWidth = _doneButton != nil ? width / 2.0f : width;
    
    _cancelButton.frame = CGRectMake(0, CGRectGetMaxY(_horizontalSeparator.frame), cancelWidth, TGCallAlertViewButtonHeight);
    _doneButton.frame = CGRectMake(width / 2.0f, CGRectGetMaxY(_horizontalSeparator.frame), width / 2.0f, TGCallAlertViewButtonHeight);
    
    height = CGRectGetMaxY(_verticalSeparator.frame);
    
    _backgroundView.frame = CGRectMake((self.bounds.size.width - width) / 2.0f, ceil((self.bounds.size.height - height) / 2.0f), width, height);
}

+ (TGCallAlertView *)presentAlertWithTitle:(NSString *)title message:(NSString *)message customView:(UIView *)customView cancelButtonTitle:(NSString *)cancelButtonTitle doneButtonTitle:(NSString *)doneButtonTitle completionBlock:(void (^)(bool))completionBlock
{
    TGCallAlertView *alertView = [[TGCallAlertView alloc] initWithTitle:title message:message customView:customView cancelButtonTitle:cancelButtonTitle doneButtonTitle:doneButtonTitle completionBlock:completionBlock];
    TGCallAlertViewController *controller = [[TGCallAlertViewController alloc] initWithView:alertView];
    TGOverlayControllerWindow *window = [[TGOverlayControllerWindow alloc] initWithParentController:TGAppDelegateInstance.rootController contentController:controller];
    window.hidden = false;
    
    return alertView;
}

@end


@implementation TGCallAlertViewController

@dynamic view;

- (instancetype)initWithView:(TGCallAlertView *)view
{
    self = [super init];
    if (self != nil)
    {
        __weak TGCallAlertViewController *weakSelf = self;
        _alertView = view;
        _alertView.onDismiss = ^
        {
            __strong TGCallAlertViewController *strongSelf = weakSelf;
            [strongSelf dismiss];
        };
    }
    return self;
}

- (void)loadView
{
    self.view = _alertView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_alertView present];
}

@end
