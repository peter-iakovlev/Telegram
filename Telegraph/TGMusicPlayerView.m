#import "TGMusicPlayerView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernButton.h"

#import "TGTelegraph.h"

#import "TGMusicPlayerController.h"

#import "TGNavigationController.h"

#import <pop/POP.h>

@interface TGMusicPlayerView ()
{
    __weak UINavigationController *_navigationController;
    
    UIView *_minimizedBar;
    UIButton *_minimizedButton;
    UIView *_minimizedBarStripe;
    UILabel *_titleLabel;
    UILabel *_performerLabel;
    UIView *_scrubbingIndicator;
    
    TGModernButton *_closeButton;
    TGModernButton *_pauseButton;
    TGModernButton *_playButton;
    
    id<SDisposable> _playerStatusDisposable;
    
    TGMusicPlayerStatus *_currentStatus;
    NSString *_title;
    NSString *_performer;
    CGFloat _playbackOffset;
    
    bool _updateLabelsLayout;
}

@end

@implementation TGMusicPlayerView

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self != nil)
    {
        _navigationController = navigationController;
        
        self.clipsToBounds = true;
        
        _minimizedBar = [[UIView alloc] init];
        _minimizedBar.backgroundColor = UIColorRGB(0xf7f7f7);
        _minimizedButton = [[UIButton alloc] init];
        [_minimizedButton addTarget:self action:@selector(minimizedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_minimizedBar addSubview:_minimizedButton];
        [self addSubview:_minimizedBar];
        
        _minimizedBarStripe = [[UIView alloc] init];
        _minimizedBarStripe.backgroundColor = UIColorRGB(0xb2b2b2);
        [_minimizedBar addSubview:_minimizedBarStripe];
        
        _closeButton = [[TGModernButton alloc] init];
        _closeButton.adjustsImageWhenHighlighted = false;
        [_closeButton setImage:[UIImage imageNamed:@"MusicPlayerMinimizedClose.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_minimizedBar addSubview:_closeButton];
        
        _playButton = [[TGModernButton alloc] init];
        _playButton.adjustsImageWhenHighlighted = false;
        [_playButton setImage:[UIImage imageNamed:@"MusicPlayerMinimizedPlay.png"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_minimizedBar addSubview:_playButton];
        _playButton.hidden = true;
        
        _pauseButton = [[TGModernButton alloc] init];
        _pauseButton.adjustsImageWhenHighlighted = false;
        [_pauseButton setImage:[UIImage imageNamed:@"MusicPlayerMinimizedPause.png"] forState:UIControlStateNormal];
        [_pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_minimizedBar addSubview:_pauseButton];
        _pauseButton.hidden = true;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(12.0f);
        [_minimizedBar addSubview:_titleLabel];
        
        _performerLabel = [[UILabel alloc] init];
        _performerLabel.backgroundColor = [UIColor clearColor];
        _performerLabel.textColor = UIColorRGB(0x8b8b8b);
        _performerLabel.font = TGSystemFontOfSize(10.0f);
        [_minimizedBar addSubview:_performerLabel];
        
        _scrubbingIndicator = [[UIView alloc] init];
        _scrubbingIndicator.backgroundColor = TGAccentColor();
        [_minimizedBar addSubview:_scrubbingIndicator];
        
        __weak TGMusicPlayerView *weakSelf = self;
        _playerStatusDisposable = [[TGTelegraphInstance.musicPlayer playingStatus] startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGMusicPlayerView *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                [strongSelf setStatus:status];
            }
        }];
        
        UISwipeGestureRecognizer *upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [_minimizedButton addGestureRecognizer:upSwipeGesture];
        
        _updateLabelsLayout = true;
    }
    return self;
}

- (void)dealloc
{
    [_playerStatusDisposable dispose];
}

- (void)setFrame:(CGRect)frame
{
    _updateLabelsLayout = ABS(frame.size.width - self.frame.size.width) > FLT_EPSILON;
    [super setFrame:frame];
    
    if (_updateLabelsLayout)
        [self setNeedsLayout];
}

- (void)setStatus:(TGMusicPlayerStatus *)status
{
    TGMusicPlayerStatus *previousStatus = _currentStatus;
    _currentStatus = status;
    if (!TGObjectCompare(status.item, previousStatus.item))
    {
        NSString *title = nil;
        NSString *performer = nil;
        for (id attribute in status.item.document.attributes)
        {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
            {
                title = ((TGDocumentAttributeAudio *)attribute).title;
                performer = ((TGDocumentAttributeAudio *)attribute).performer;
                
                break;
            }
        }
        
        if (title.length == 0)
        {
            title = status.item.document.fileName;
            if (title.length == 0)
                title = @"Unknown Track";
        }
        
        if (performer.length == 0)
            performer = @"Unknown Artist";
        
        if (status != nil)
        {
            if (!TGStringCompare(_title, title) || !TGStringCompare(_performer, performer))
            {
                _updateLabelsLayout = true;
                _title = title;
                _performer = performer;
                
                _titleLabel.text = title;
                _performerLabel.text = performer;
                
                [self setNeedsLayout];
            }
        }
    }
    
    static POPAnimatableProperty *property = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        property = [POPAnimatableProperty propertyWithName:@"playbackOffset" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGMusicPlayerView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_playbackOffset;
            };
            
            prop.writeBlock = ^(TGMusicPlayerView *strongSelf, CGFloat const *values)
            {
                strongSelf->_playbackOffset = values[0];
                [strongSelf layoutScrubbingIndicator];
            };
        }];
    });
    
    _playButton.hidden = !status.paused;
    _pauseButton.hidden = status.paused;
    
    if (status == nil || status.paused || status.duration < FLT_EPSILON)
    {
        [self pop_removeAnimationForKey:@"scrubbingIndicator"];
        
        _playbackOffset = status.offset;
        [self layoutScrubbingIndicator];
    }
    else
    {
        [self pop_removeAnimationForKey:@"scrubbingIndicator"];
        POPBasicAnimation *animation = [self pop_animationForKey:@"scrubbingIndicator"];
        if (animation == nil)
        {
            animation = [POPBasicAnimation linearAnimation];
            [animation setProperty:property];
            animation.removedOnCompletion = true;
            animation.fromValue = @(status.offset);
            animation.toValue = @(1.0f);
            animation.beginTime = status.timestamp;
            animation.duration = (1.0f - status.offset) * status.duration;
            [self pop_addAnimation:animation forKey:@"scrubbingIndicator"];
        }
    }
}

- (void)layoutScrubbingIndicator
{
    CGFloat indicatorHeight = 2.0f - TGRetinaPixel;
    _scrubbingIndicator.frame = CGRectMake(0.0f, 37.0f - indicatorHeight, TGRetinaFloor(self.frame.size.width *  _playbackOffset), indicatorHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor whiteColor];
    
    _minimizedBar.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 37.0f);
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    _minimizedBarStripe.frame = CGRectMake(0.0f, 37.0f - separatorHeight, self.frame.size.width, separatorHeight);
    _closeButton.frame = CGRectMake(self.frame.size.width - 44.0f, TGRetinaPixel, 44.0f, 36.0f);
    
    _pauseButton.frame = CGRectMake(0.0f, 0.0f, 46.0f, 36.0f);
    _playButton.frame = CGRectMake(0.0f, 0.0f, 48.0f, 36.0f);
    
    CGSize titleSize = _titleLabel.frame.size;
    CGSize performerSize = _performerLabel.frame.size;
    if (_updateLabelsLayout)
    {
        titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
        performerSize = [_performerLabel.text sizeWithFont:_performerLabel.font];
        CGFloat maxWidth = self.frame.size.width - 54.0f * 2.0f;
        titleSize.width = MIN(titleSize.width, maxWidth);
        performerSize.width = MIN(performerSize.width, maxWidth);
    }
    
    _titleLabel.frame = CGRectMake(CGFloor((self.frame.size.width - titleSize.width) / 2.0f), 4.0f, titleSize.width, titleSize.height);
    _performerLabel.frame = CGRectMake(CGFloor((self.frame.size.width - performerSize.width) / 2.0f), 20.0f - TGRetinaPixel, performerSize.width, performerSize.height);
    
    _minimizedButton.frame = CGRectMake(44.0f, 0.0f, _minimizedBar.frame.size.width - 44.0f * 2.0f, _minimizedBar.frame.size.height);
    
    [self layoutScrubbingIndicator];
}

- (void)closeButtonPressed
{
    [TGTelegraphInstance.musicPlayer setPlaylist:nil initialItemKey:nil];
}

- (void)pauseButtonPressed
{
    [TGTelegraphInstance.musicPlayer controlPause];
}

- (void)playButtonPressed
{
    [TGTelegraphInstance.musicPlayer controlPlay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect closeButtonFrame = CGRectOffset(_closeButton.frame, _minimizedBar.frame.origin.x, _minimizedBar.frame.origin.y);
    if (CGRectContainsPoint(closeButtonFrame, point))
    {
        return _closeButton;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)minimizedButtonPressed
{
    TGMusicPlayerController *controller = [[TGMusicPlayerController alloc] init];
    
    TGNavigationController *playerNavigationController = [TGNavigationController navigationControllerWithControllers:@[controller]];
    UINavigationController *navigationController = _navigationController;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        playerNavigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        playerNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        playerNavigationController.preferredContentSize = CGSizeMake(414.0f, 667.0f);
        
    } else {
        playerNavigationController.restrictLandscape = true;
    }
    [navigationController presentViewController:playerNavigationController animated:true completion:nil];
}

- (void)swipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //__strong TGNavigationController *navigationController = (TGNavigationController *)_navigationController;
        //[navigationController setMinimizePlayer:true];
    }
}

@end
