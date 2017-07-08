#import "TGPickerSheet.h"

#import "TGOverlayControllerWindow.h"
#import "TGOverlayController.h"
#import "TGNavigationController.h"

#import "TGModernButton.h"
#import "TGFont.h"

#import "TGSecretTimerValueControllerItemView.h"
#import "TGPopoverController.h"

#import "TGLocalization.h"

@interface TGPickerSheetOverlayController () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    bool _dateMode;
    UIView *_backgroundView;
    UIView *_containerView;
    UIImageView *_containerBackgroundView;
    UIButton *_cancelButton;
    UIDatePicker *_datePicker;
    UIPickerView *_pickerView;
    TGModernButton *_doneButton;
    bool _banTimeout;
}

@property (nonatomic, strong) NSString *emptyValue;
@property (nonatomic, copy) void (^onDismiss)();
@property (nonatomic, copy) void (^onDone)(id item);
@property (nonatomic, copy) void (^onDate)(NSTimeInterval);
@property (nonatomic, strong) NSArray *timerValues;
@property (nonatomic) NSUInteger selectedIndex;

@end

@implementation TGPickerSheetOverlayController

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

- (instancetype)initWithDateMode:(bool)banTimeout {
    self = [super init];
    if (self != nil) {
        _dateMode = true;
        _banTimeout = banTimeout;
    }
    return self;
}

- (void)dealloc
{
    _pickerView.delegate = nil;
    _pickerView.dataSource = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.view.window.layer removeAnimationForKey:@"backgroundColor"];
    [CATransaction begin];
    [CATransaction setDisableActions:true];
    self.view.window.layer.backgroundColor = [UIColor clearColor].CGColor;
    [CATransaction commit];
    
    for (UIView *view in self.view.window.subviews)
    {
        if (view != self.view)
        {
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)loadView
{
    [super loadView];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = UIColorRGBA(0x000000, 0.4f);
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)]];
    [self.view addSubview:_backgroundView];
    
    CGFloat containerHeight = 216.0f + 32.0f;
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - containerHeight, self.view.frame.size.width, containerHeight)];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_containerView];
    
    CGFloat buttonInset = 10.0f;
    
    if (_dateMode) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0f, 32.0f + CGFloor((_containerView.frame.size.height - 44.0f - 216.0f) / 2.0f), _containerView.frame.size.width, 216.0)];
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:effectiveLocalization().code];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        
        if (_banTimeout) {
            _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            _datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:2.0];
        } else {
            _datePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:2.0];
            _datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:1376438400];
        }
        
        _datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_containerView addSubview:_datePicker];
    } else {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 32.0f + CGFloor((_containerView.frame.size.height - 44.0f - 216.0f) / 2.0f), _containerView.frame.size.width, 216.0)];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [_pickerView reloadAllComponents];
        [_containerView addSubview:_pickerView];
    }
    
    _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    [_cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, buttonInset, 0.0f, buttonInset)];
    _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_cancelButton setTitle:TGLocalized(@"Common.Cancel") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:TGAccentColor() forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = TGSystemFontOfSize(16.0f);
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_cancelButton];
    
    _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(_containerView.frame.size.width - 140.0f, 0.0f, 140.0f, 44.0f)];
    [_doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, buttonInset, 0.0f, buttonInset)];
    _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    if (_banTimeout) {
        [_doneButton setTitle:TGLocalized(@"Common.Done") forState:UIControlStateNormal];
    } else if (_dateMode) {
        [_doneButton setTitle:TGLocalized(@"Conversation.JumpToDate") forState:UIControlStateNormal];
    } else {
        [_doneButton setTitle:TGLocalized(@"Common.Done") forState:UIControlStateNormal];
    }
    [_doneButton setTitleColor:TGAccentColor() forState:UIControlStateNormal];
    _doneButton.titleLabel.font = TGBoldSystemFontOfSize(16.0f);
    [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_doneButton];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_onDismiss)
            _onDismiss();
    }
}

- (void)cancelButtonPressed
{
    if (_onDismiss)
        _onDismiss();
}

- (void)doneButtonPressed
{
    if (_dateMode && _onDate) { {
        _onDate([_datePicker.date timeIntervalSince1970]);
    }
    } else if (!_dateMode && _onDone) {
        NSInteger index = [_pickerView selectedRowInComponent:0];
        if (index >= 0 && index < (NSInteger)_timerValues.count)
        {
            _onDone(_timerValues[index]);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_dateMode) {
        
    } else {
        [_pickerView reloadAllComponents];
        [_pickerView selectRow:_selectedIndex inComponent:0 animated:false];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)__unused pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)__unused pickerView numberOfRowsInComponent:(NSInteger)__unused component
{
    return _timerValues.count;
}

- (UIView *)pickerView:(UIPickerView *)__unused pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)__unused component reusingView:(TGSecretTimerValueControllerItemView *)view
{
    if (view != nil)
    {
        view.emptyValue = _emptyValue;
        view.seconds = [_timerValues[row] intValue];
        return view;
    }
    
    TGSecretTimerValueControllerItemView *newView = [[TGSecretTimerValueControllerItemView alloc] init];
    newView.emptyValue = _emptyValue;
    newView.seconds = [_timerValues[row] intValue];
    return newView;
}

- (void)animateIn
{
    _containerView.frame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, _containerView.frame.size.height);
    _backgroundView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.12 delay:0.0 options:(7 << 16) | UIViewAnimationOptionAllowUserInteraction animations:^
    {
        _containerView.frame = CGRectMake(0.0f, self.view.frame.size.height - _containerView.frame.size.height, self.view.frame.size.width, _containerView.frame.size.height);
        _backgroundView.alpha = 1.0f;
    } completion:nil];
}

- (void)animateOut:(void (^)())completion
{
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
        _containerView.frame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, _containerView.frame.size.height);
        _backgroundView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion)
            completion();
    }];
}

@end

@interface TGPickerSheetPopoverContentController : TGViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *_pickerView;
}

@property (nonatomic, strong) NSString *emptyValue;
@property (nonatomic, copy) void (^onDismiss)();
@property (nonatomic, copy) void (^onDone)(id item);
@property (nonatomic, strong) NSArray *timerValues;
@property (nonatomic) NSUInteger selectedIndex;

@end

@implementation TGPickerSheetPopoverContentController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)]];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)]];
    }
    return self;
}

- (void)dealloc
{
    _pickerView.delegate = nil;
    _pickerView.dataSource = nil;
}

- (void)cancelButtonPressed
{
    if (_onDismiss)
        _onDismiss();
}

- (void)doneButtonPressed
{
    if (_onDone)
    {
        NSInteger index = [_pickerView selectedRowInComponent:0];
        if (index >= 0 && index < (NSInteger)_timerValues.count)
        {
            _onDone(_timerValues[index]);
        }
    }
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(320.0f, 216.0f);
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 216.0)];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [_pickerView reloadAllComponents];
    [self.view addSubview:_pickerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:_selectedIndex inComponent:0 animated:false];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:_selectedIndex inComponent:0 animated:false];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)__unused pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)__unused pickerView numberOfRowsInComponent:(NSInteger)__unused component
{
    return _timerValues.count;
}

- (UIView *)pickerView:(UIPickerView *)__unused pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)__unused component reusingView:(TGSecretTimerValueControllerItemView *)view
{
    if (view != nil)
    {
        view.emptyValue = _emptyValue;
        view.seconds = [_timerValues[row] intValue];
        return view;
    }
    
    TGSecretTimerValueControllerItemView *newView = [[TGSecretTimerValueControllerItemView alloc] init];
    newView.emptyValue = _emptyValue;
    newView.seconds = [_timerValues[row] intValue];
    return newView;
}

@end

@interface TGPickerSheetPopoverController : TGPopoverController

@end

@implementation TGPickerSheetPopoverController

- (instancetype)initWithEmptyValue:(NSString *)emptyValue
{
    TGPickerSheetPopoverContentController *contentController = [[TGPickerSheetPopoverContentController alloc] init];
    contentController.emptyValue = emptyValue;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[contentController]];
    navigationController.presentationStyle = TGNavigationControllerPresentationStyleRootInPopover;
    self = [super initWithContentViewController:navigationController];
    if (self != nil)
    {
        if (iosMajorVersion() < 8)
            self.popoverContentSize = [contentController preferredContentSize];
    }
    return self;
}

- (TGPickerSheetPopoverContentController *)pickerSheetContentController
{
    return (TGPickerSheetPopoverContentController *)(((TGNavigationController *)self.contentViewController).topViewController);
}

@end

@interface TGPickerSheet ()
{
    bool _dateSelection;
    NSArray *_items;
    NSUInteger _selectedIndex;
    
    TGOverlayControllerWindow *_controllerWindow;
    TGPickerSheetPopoverController *_popoverController;
    
    void (^_action)(id);
    void (^_dateAction)(NSTimeInterval);
    bool _banTimeout;
}

@end

@implementation TGPickerSheet

- (instancetype)initWithItems:(NSArray *)items selectedIndex:(NSUInteger)selectedIndex action:(void (^)(id item))action
{
    self = [super init];
    if (self != nil)
    {
        _items = items;
        _selectedIndex = selectedIndex;
        _action = [action copy];
    }
    return self;
}

- (instancetype)initWithDateSelection:(void (^)(NSTimeInterval item))action banTimeout:(bool)banTimeout {
    self = [super init];
    if (self != nil) {
        _dateSelection = true;
        _dateAction = [action copy];
        _banTimeout = banTimeout;
    }
    return self;
}

- (void)show
{
    if (_controllerWindow == nil)
    {
        _controllerWindow = [[TGOverlayControllerWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _controllerWindow.windowLevel = UIWindowLevelAlert;
        _controllerWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controllerWindow.hidden = false;
        if (_dateSelection) {
            _controllerWindow.rootViewController = [[TGPickerSheetOverlayController alloc] initWithDateMode:_banTimeout];
        } else {
            _controllerWindow.rootViewController = [[TGPickerSheetOverlayController alloc] init];
        }
        __weak TGPickerSheet *weakSelf = self;
        ((TGPickerSheetOverlayController *)_controllerWindow.rootViewController).emptyValue = _emptyValue;
        ((TGPickerSheetOverlayController *)_controllerWindow.rootViewController).timerValues = _items;
        ((TGPickerSheetOverlayController *)_controllerWindow.rootViewController).selectedIndex = _selectedIndex;
        
        ((TGPickerSheetOverlayController *)_controllerWindow.rootViewController).onDismiss = ^
        {
            __strong TGPickerSheet *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf dismiss];
        };
        
        ((TGPickerSheetOverlayController *)_controllerWindow.rootViewController).onDone = ^(id item)
        {
            __strong TGPickerSheet *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_action)
                    strongSelf->_action(item);
                
                [strongSelf dismiss];
            }
        };
        ((TGPickerSheetOverlayController *)_controllerWindow.rootViewController).onDate = ^(NSTimeInterval date)
        {
            __strong TGPickerSheet *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_dateAction)
                    strongSelf->_dateAction(date);
                
                [strongSelf dismiss];
            }
        };
        
        [((TGPickerSheetOverlayController *)_controllerWindow.rootViewController) animateIn];
    }
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        _popoverController = [[TGPickerSheetPopoverController alloc] initWithEmptyValue:_emptyValue];
        
        __weak TGPickerSheet *weakSelf = self;
        _popoverController.pickerSheetContentController.timerValues = _items;
        _popoverController.pickerSheetContentController.selectedIndex = _selectedIndex;
        
        _popoverController.pickerSheetContentController.onDismiss = ^
        {
            __strong TGPickerSheet *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf dismiss];
        };
        
        _popoverController.pickerSheetContentController.onDone = ^(id item)
        {
            __strong TGPickerSheet *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_action)
                    strongSelf->_action(item);
                
                [strongSelf dismiss];
            }
        };
        
        [_popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
    }
}

- (void)dismiss
{
    if (_controllerWindow != nil)
    {
        __weak TGPickerSheet *weakSelf = self;
        [((TGPickerSheetOverlayController *)_controllerWindow.rootViewController) animateOut:^
        {
            __strong TGPickerSheet *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_controllerWindow.hidden = true;
                strongSelf->_controllerWindow = nil;
            }
        }];
    }
    
    if (_popoverController != nil)
    {
        [_popoverController dismissPopoverAnimated:true];
    }
}

@end
