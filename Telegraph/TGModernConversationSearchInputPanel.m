#import "TGModernConversationSearchInputPanel.h"

#import <LegacyComponents/TGImageUtils.h>
#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGModernButton.h>

@interface TGModernConversationSearchInputPanel ()
{
    CALayer *_stripeLayer;
    
    UIEdgeInsets _safeAreaInset;
    
    UIView *_backgroundView;
    TGModernButton *_nextButton;
    TGModernButton *_previousButton;
    UIActivityIndicatorView *_activityIndicator;
    TGModernButton *_doneButton;
    
    NSUInteger _offset;
    NSUInteger _count;
    UILabel *_countLabel;
    
    TGModernButton *_calendarButton;
    TGModernButton *_searchByNameButton;
    
    bool _none;
}

@end

@implementation TGModernConversationSearchInputPanel

- (CGFloat)baseHeight
{
    static CGFloat value = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 45.0f : 56.0f;
    });
    
    return value;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, [self baseHeight])];
    if (self)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColorRGB(0xf7f7f7);
        [self addSubview:_backgroundView];
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        _nextButton = [[TGModernButton alloc] init];
        [_nextButton setImage:TGImageNamed(@"InlineSearchUp.png") forState:UIControlStateNormal];
        [_nextButton setImage:TGImageNamed(@"InlineSearchUpDisabled.png") forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(nextPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
        
        _previousButton = [[TGModernButton alloc] init];
        [_previousButton setImage:TGImageNamed(@"InlineSearchDown.png") forState:UIControlStateNormal];
        [_previousButton setImage:TGImageNamed(@"InlineSearchDownDisabled.png") forState:UIControlStateDisabled];
        [_previousButton addTarget:self action:@selector(previousPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_previousButton];
        
        _calendarButton = [[TGModernButton alloc] init];
        [_calendarButton setImage:TGImageNamed(@"ConversationSearchCalendar.png") forState:UIControlStateNormal];
        _calendarButton.modernHighlight = true;
        [_calendarButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0)];
        [self addSubview:_calendarButton];
        [_calendarButton addTarget:self action:@selector(calendarButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _searchByNameButton = [[TGModernButton alloc] init];
        [_searchByNameButton setImage:TGImageNamed(@"ConversationSearchUser.png") forState:UIControlStateNormal];
        _searchByNameButton.modernHighlight = true;
        [_searchByNameButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0)];
        [self addSubview:_searchByNameButton];
        [_searchByNameButton addTarget:self action:@selector(searchByNamePressed) forControlEvents:UIControlEventTouchUpInside];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //[self addSubview:_activityIndicator];
        _activityIndicator.hidden = true;
        
        _doneButton = [[TGModernButton alloc] init];
        [_doneButton setTitleColor:TGAccentColor()];
        [_doneButton setTitle:TGLocalized(@"Common.Done") forState:UIControlStateNormal];
        _doneButton.titleLabel.font = TGMediumSystemFontOfSize(15.0f);
        [_doneButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_doneButton];
        
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor blackColor];
        _countLabel.font = TGSystemFontOfSize(15.0f);
        [self addSubview:_countLabel];
        
        [self updateInterface];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setNext:(void (^)())next
{
    _next = [next copy];
    
    [self updateInterface];
}

- (void)setPrevious:(void (^)())previous
{
    _previous = [previous copy];
    
    [self updateInterface];
}

- (void)setOffset:(NSUInteger)offset count:(NSUInteger)count
{
    if (_count != count || _offset != offset)
    {
        _offset = offset;
        _count = count;
        
        [self updateInterface];
    }
}

- (void)setNone {
    if (!_none) {
        _none = true;
        [self updateInterface];
    }
}

- (void)setEnableCalendar:(bool)enableCalendar {
    _enableCalendar = enableCalendar;
    
    [self updateInterface];
}

- (void)setEnableSearchByName:(bool)enableSearchByName {
    _enableSearchByName = enableSearchByName;
    
    [self updateInterface];
}

- (void)setInProgress:(bool)inProgress
{
    if (_inProgress != inProgress)
    {
        _inProgress = inProgress;
        
        [self updateInterface];
    }
}

- (void)setIsSearching:(bool)isSearching
{
    if (_isSearching != isSearching)
    {
        _isSearching = isSearching;
        
        [self updateInterface];
    }
}

- (void)updateInterface
{
    _nextButton.hidden = _none;
    _previousButton.hidden = _none;
    _countLabel.hidden = _none;
    
    if (_count != 0 && _offset + 1 < _count && !_inProgress)
    {
        _nextButton.enabled = true;
    }
    else
    {
        _nextButton.enabled = false;
    }
    
    if (_count != 0 && _offset > 0 && !_inProgress)
    {
        _previousButton.enabled = true;
    }
    else
    {
        _previousButton.enabled = false;
    }
    
    _doneButton.hidden = true;
    _countLabel.hidden = _none || _inProgress || !_isSearching;
    
    if (_inProgress != !_activityIndicator.hidden)
    {
        _activityIndicator.hidden = !_inProgress;
        if (_inProgress)
            [_activityIndicator startAnimating];
        else
            [_activityIndicator stopAnimating];
    }
    
    if (_count == 0)
        _countLabel.text = TGLocalized(@"Conversation.SearchNoResults");
    else
    {
        _countLabel.text = [[NSString alloc] initWithFormat:@"%d %@ %d", (int)_offset + 1, TGLocalized(@"Common.of"), (int)_count];
    }
    [_countLabel sizeToFit];
    
    _calendarButton.hidden = _none || !_enableCalendar;
    _searchByNameButton.hidden = _none || !_enableSearchByName;
    
    [self setNeedsLayout];
}

- (void)adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:animationCurve contentAreaHeight:contentAreaHeight safeAreaInset:safeAreaInset];
}

- (void)_adjustForSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration animationCurve:(int)animationCurve contentAreaHeight:(CGFloat)__unused contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    
    dispatch_block_t block = ^
    {
        CGSize messageAreaSize = size;
        CGFloat safeAreaHeight = keyboardHeight > FLT_EPSILON ? 0.0f : safeAreaInset.bottom;
        
        self.frame = CGRectMake(0, messageAreaSize.height - keyboardHeight - [self baseHeight] - safeAreaHeight, messageAreaSize.width, [self baseHeight]);
        [self layoutSubviews];
    };
    
    if (duration > DBL_EPSILON)
        [UIView animateWithDuration:duration delay:0 options:animationCurve << 16 animations:block completion:nil];
    else
        block();
}

- (void)changeToSize:(CGSize)size keyboardHeight:(CGFloat)keyboardHeight duration:(NSTimeInterval)duration contentAreaHeight:(CGFloat)contentAreaHeight safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    [self _adjustForSize:size keyboardHeight:keyboardHeight duration:duration animationCurve:0 contentAreaHeight:contentAreaHeight safeAreaInset:safeAreaInset];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)__unused event
{
    CGRect extendedRect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height + _safeAreaInset.bottom);
    return CGRectContainsPoint(extendedRect, point);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height + _safeAreaInset.bottom);
    
    _stripeLayer.frame = CGRectMake(0.0f, -TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.frame.size.width - _doneButton.frame.size.width - 12.0f - _safeAreaInset.right, 0.0f, _doneButton.frame.size.width + 6.0f, [self baseHeight]);
    
    _previousButton.frame = CGRectMake(12.0f + _safeAreaInset.left, 0.0f, 40.0f, [self baseHeight]);
    _nextButton.frame = CGRectMake(12.0f + 43.0f + _safeAreaInset.left, 0.0f, 40.0f, [self baseHeight]);
    
    _countLabel.frame = CGRectMake(105.0f + _safeAreaInset.left, CGFloor(([self baseHeight] - _countLabel.frame.size.height) / 2.0f), _countLabel.frame.size.width, _countLabel.frame.size.height);
    
    _activityIndicator.frame = CGRectMake(self.frame.size.width - _activityIndicator.frame.size.width - 8.0f, CGFloor(([self baseHeight] - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
    
    _calendarButton.frame = CGRectMake(self.frame.size.width - 60.0f - _safeAreaInset.right, 0.0f, 60.0f, [self baseHeight]);
    _searchByNameButton.frame = CGRectMake(self.frame.size.width - 60.0f * 2.0f - _safeAreaInset.right, 0.0f, 60.0f, [self baseHeight]);
}

- (void)nextPressed
{
    if (_next)
        _next();
}

- (void)previousPressed
{
    if (_previous)
        _previous();
}

- (void)donePressed
{
    if (_done)
        _done();
}

- (void)calendarButtonPressed {
    if (_calendar) {
        _calendar();
    }
}

- (void)searchByNamePressed {
    if (_searchByName) {
        _searchByName();
    }
}

@end
