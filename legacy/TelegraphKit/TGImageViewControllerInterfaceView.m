#import "TGImageViewControllerInterfaceView.h"

#import "TGHacks.h"
#import "TGDateUtils.h"
#import "TGImageUtils.h"
#import "TGStringUtils.h"

#import "TGImagePagingScrollView.h"
#import "TGImageViewPage.h"

#import "TGClockProgressView.h"

#import "TGObserverProxy.h"

#import "TGModernToolbarButton.h"
#import "TGModernBackToolbarButton.h"

#import "TGFont.h"

#import "TGButton.h"

#import "TGBackdropView.h"

@interface TGImageViewControllerInterfaceView ()
{
    float _navigationBarOffset;
}

@property (nonatomic, strong) TGButton *playButton;
@property (nonatomic, strong) TGButton *pauseButton;

@property (nonatomic, strong) UIView *controlsContainer;
@property (nonatomic, strong) UIView *progressContainer;

@property (nonatomic, strong) TGClockProgressView *clockProgressView;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) TGObserverProxy *statusBarWillChangeFrameProxy;

@end

@implementation TGImageViewControllerInterfaceView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame enableEditing:false disableActions:false];
}

- (id)initWithFrame:(CGRect)frame enableEditing:(bool)enableEditing disableActions:(bool)disableActions
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _navigationBarOffset = iosMajorVersion() >= 7 ? 0.0f : 20.0f;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _currentIndex = -1;
        
        _navigationBar = (TGToolbar *)[[UIView alloc] initWithFrame:CGRectMake(0, _navigationBarOffset, frame.size.width, 44 - _navigationBarOffset)];
        _navigationBar.backgroundColor = UIColorRGBA(0x000000, 0.6f);
        
        [self addSubview:_navigationBar];
        
        _enableEditing = enableEditing;
        
        _doneButton = [[TGModernBackToolbarButton alloc] init];
        [_doneButton sizeToFit];
        [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_navigationBar addSubview:_doneButton];
        
        [self _layoutNavigationBar];
        
        if (_enableEditing)
        {
            _editButton = [[TGModernToolbarButton alloc] init];
            _editButton.buttonTitle = TGLocalized(@"Common.Edit");
            [_editButton sizeToFit];
            _editButton.frame = CGRectOffset(_editButton.frame, _navigationBar.frame.size.width - _editButton.frame.size.width - 5, 7);
            _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [_editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_navigationBar addSubview:_editButton];
        }
        
        _counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 140) / 2), 11, 140, 20)];
        _counterLabel.textAlignment = UITextAlignmentCenter;
        _counterLabel.font = TGBoldSystemFontOfSize(17);
        _counterLabel.textColor = [UIColor whiteColor];
        _counterLabel.backgroundColor = [UIColor clearColor];
        [_navigationBar addSubview:_counterLabel];
        
        _bottomPanelView = (TGToolbar *)[[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 44)];
        _bottomPanelView.backgroundColor = UIColorRGBA(0x000000, 0.6f);
        
        _bottomPanelView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bottomPanelView];
        
        _controlsContainer = [[UIView alloc] initWithFrame:_bottomPanelView.bounds];
        _controlsContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_bottomPanelView addSubview:_controlsContainer];
        
        _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 220) / 2), 3, 220, 20)];
        _authorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _authorLabel.textAlignment = UITextAlignmentCenter;
        _authorLabel.font = TGBoldSystemFontOfSize(15);
        _authorLabel.textColor = [UIColor whiteColor];
        _authorLabel.backgroundColor = [UIColor clearColor];
        [_controlsContainer addSubview:_authorLabel];
        
        _dateLabel = [[TGDateLabel alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 140) / 2), 23, 140, 20)];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _dateLabel.textAlignment = UITextAlignmentCenter;
        _dateLabel.dateFont = TGSystemFontOfSize(13);
        _dateLabel.dateTextFont = _dateLabel.dateFont;
        _dateLabel.dateLabelFont = TGSystemFontOfSize(11);
        _dateLabel.textAlignment = UITextAlignmentCenter;
        _dateLabel.amWidth = 18;
        _dateLabel.pmWidth = 18;
        _dateLabel.dstOffset = 2;
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.backgroundColor = [UIColor clearColor];
        [_controlsContainer addSubview:_dateLabel];
        
        UIImage *playImage = [UIImage imageNamed:@"VideoPanelPlay.png"];
        UIImage *pauseImage = [UIImage imageNamed:@"VideoPanelPause.png"];
        
        _playButton = [[TGButton alloc] initWithFrame:CGRectMake(floorf((_bottomPanelView.frame.size.width - playImage.size.width) / 2), floorf((_bottomPanelView.frame.size.height - playImage.size.height) / 2), playImage.size.width, playImage.size.height)];
        _playButton.touchInset = CGSizeMake(8, 8);
        [_playButton setBackgroundImage:playImage forState:UIControlStateNormal];
        _playButton.exclusiveTouch = true;
        _playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_controlsContainer addSubview:_playButton];
        
        _pauseButton = [[TGButton alloc] initWithFrame:CGRectMake(floorf((_bottomPanelView.frame.size.width - pauseImage.size.width) / 2), floorf((_bottomPanelView.frame.size.height - pauseImage.size.height) / 2), playImage.size.width, pauseImage.size.height)];
        _pauseButton.touchInset = CGSizeMake(8, 8);
        [_pauseButton setBackgroundImage:pauseImage forState:UIControlStateNormal];
        _pauseButton.exclusiveTouch = true;
        _pauseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_controlsContainer addSubview:_pauseButton];
        
        _progressContainer = [[UIView alloc] initWithFrame:_controlsContainer.bounds];
        _progressContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _progressContainer.alpha = 0.0f;
        [_bottomPanelView addSubview:_progressContainer];
        
        _progressAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 220) / 2), 4, 220, 20)];
        _progressAuthorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _progressAuthorLabel.textAlignment = UITextAlignmentCenter;
        _progressAuthorLabel.font = TGBoldSystemFontOfSize(14);
        _progressAuthorLabel.textColor = [UIColor whiteColor];
        _progressAuthorLabel.shadowColor = UIColorRGBA(0x000000, 0.5f);
        _progressAuthorLabel.shadowOffset = CGSizeMake(0, -1);
        _progressAuthorLabel.backgroundColor = [UIColor clearColor];
        [_progressContainer addSubview:_progressAuthorLabel];
        
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.clipsToBounds = false;
        _progressLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _progressLabel.textAlignment = UITextAlignmentCenter;
        _progressLabel.font = TGSystemFontOfSize(13);
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.shadowColor = UIColorRGBA(0x000000, 0.5f);
        _progressLabel.shadowOffset = CGSizeMake(0, -1);
        _progressLabel.backgroundColor = [UIColor clearColor];
        [_progressContainer addSubview:_progressLabel];
        
        float retinaPixel = TGIsRetina() ? 0.5f : 0.0f;
        
        _clockProgressView = [[TGClockProgressView alloc] initWithWhite];
        _clockProgressView.frame = CGRectMake(-19, 1 + retinaPixel, 15, 15);
        [_progressLabel addSubview:_clockProgressView];
        
        if (!disableActions)
        {
        	UIImage *actionImage = [UIImage imageNamed:@"ActionsWhiteIcon.png"];
        	_actionButton = [[TGButton alloc] initWithFrame:CGRectMake(12, 8, actionImage.size.width, actionImage.size.height)];
            _actionButton.touchInset = CGSizeMake(16, 16);
        	_actionButton.exclusiveTouch = true;
        	[_actionButton setBackgroundImage:actionImage forState:UIControlStateNormal];
        	_actionButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        	[_actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        	[_bottomPanelView addSubview:_actionButton];
		}
        
        UIImage *deleteImage = [UIImage imageNamed:@"DeleteWhiteIcon.png"];
        _deleteButton = [[TGButton alloc] initWithFrame:CGRectMake(_bottomPanelView.frame.size.width - deleteImage.size.width - 15, 10, deleteImage.size.width, deleteImage.size.height)];
        _deleteButton.touchInset = CGSizeMake(16, 16);
        _deleteButton.exclusiveTouch = true;
        [_deleteButton setBackgroundImage:deleteImage forState:UIControlStateNormal];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_bottomPanelView addSubview:_deleteButton];
        
        _navigationBar.alpha = 0.0f;
        _bottomPanelView.alpha = 0.0f;
        
        _statusBarWillChangeFrameProxy = [[TGObserverProxy alloc] initWithTarget:self targetSelector:@selector(statusBarWillChangeFrame:) name:UIApplicationWillChangeStatusBarFrameNotification];
        
        [self updateStatusBarFrame:[[UIApplication sharedApplication] statusBarFrame]];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self _layoutNavigationBar];
}

- (void)_layoutNavigationBar
{
    _navigationBar.frame = CGRectMake(0, _navigationBar.frame.origin.y, self.frame.size.width, (self.frame.size.width < 400 ? 44 : 32) + 20 - _navigationBarOffset);
    
    if (self.frame.size.width < 400)
    {
        _doneButton.frame = CGRectMake(8, _navigationBar.frame.size.height - 34, _doneButton.frame.size.width, _doneButton.frame.size.height);
        if (_editButton != nil)
        {
            _editButton.frame = CGRectMake(_navigationBar.frame.size.width - _editButton.frame.size.width - (iosMajorVersion() >= 7 ? 8 : 14), _navigationBar.frame.size.height - (iosMajorVersion() >= 7 ? 32 : 34), _editButton.frame.size.width, _editButton.frame.size.height);
        }
        
        _counterLabel.frame = CGRectMake(floorf((_navigationBar.frame.size.width - _counterLabel.frame.size.width) / 2), _navigationBar.frame.size.height - 34, _counterLabel.frame.size.width, _counterLabel.frame.size.height);
    }
    else
    {
        _doneButton.frame = CGRectMake(8, _navigationBar.frame.size.height - (iosMajorVersion() >= 7 ? 30 : 28), _doneButton.frame.size.width, _doneButton.frame.size.height);
        if (_editButton != nil)
        {
            _editButton.frame = CGRectMake(_navigationBar.frame.size.width - _editButton.frame.size.width - 16, _navigationBar.frame.size.height - 27, _editButton.frame.size.width, _editButton.frame.size.height);
        }
        
        _counterLabel.frame = CGRectMake(floorf((_navigationBar.frame.size.width - _counterLabel.frame.size.width) / 2), _navigationBar.frame.size.height - 28, _counterLabel.frame.size.width, _counterLabel.frame.size.height);
    }
}

- (void)statusBarWillChangeFrame:(NSNotification *)notification
{
     CGRect statusBarFrame = [[[notification userInfo] objectForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.35 animations:^
    {
        [self controlsAlphaUpdated];
        [self updateStatusBarFrame:statusBarFrame];
    }];
}

- (void)updateStatusBarFrame:(CGRect)statusBarFrame
{
    [self _layoutNavigationBar];
    
    _navigationBar.frame = CGRectMake(0, _navigationBarOffset + MIN(statusBarFrame.size.width, statusBarFrame.size.height) - 20, _navigationBar.frame.size.width, _navigationBar.frame.size.height);
}

- (void)toggleShowHide
{
    bool show = _bottomPanelView.alpha < FLT_EPSILON;
    [self setActive:show duration:show ? 0.15 : 0.3];
}

- (float)controlsAlpha
{
    return _bottomPanelView.alpha;
}

- (void)controlsAlphaUpdated
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        [watcher actionStageActionRequested:@"controlsAlphaChanged" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithFloat:[self controlsAlpha]], @"alpha", nil]];
}

- (void)setActive:(bool)active duration:(NSTimeInterval)duration
{
    [self setActive:active duration:duration statusBar:true];
}

- (void)setActive:(bool)active duration:(NSTimeInterval)duration statusBar:(bool)statusBar
{
    if (active)
    {
        if (statusBar)
        {
            [UIView animateWithDuration:duration animations:^
            {
                [TGHacks setApplicationStatusBarAlpha:1.0f];
            }];
        }
        
        _bottomPanelView.hidden = false;
        _navigationBar.hidden = false;
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _bottomPanelView.alpha = 1.0f;
            _navigationBar.alpha = 1.0f;
            
            [self controlsAlphaUpdated];
        } completion:nil];
    }
    else
    {
        if (statusBar)
        {
            [UIView animateWithDuration:duration animations:^
            {
                [TGHacks setApplicationStatusBarAlpha:0.0f];
            }];
        }
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _bottomPanelView.alpha = 0.0f;
            _navigationBar.alpha = 0.0f;
            
            [self controlsAlphaUpdated];
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _bottomPanelView.hidden = true;
                _navigationBar.hidden = true;
            }
        }];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if ([result isKindOfClass:[UIButton class]])
        return result;
    
    return nil;
}

- (void)doneButtonPressed
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        [watcher actionStageActionRequested:@"animateDisappear" options:nil];
}

- (void)editButtonPressed
{
    [_watcherHandle requestAction:@"activateEditing" options:nil];
}

- (void)deleteButtonPressed
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        [watcher actionStageActionRequested:@"deletePage" options:nil];
}

- (void)actionButtonPressed
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        [watcher actionStageActionRequested:@"showActions" options:nil];
}

- (void)updateLabels
{
    NSString *counterText = nil;
    if (_customTitle != nil)
        counterText = _customTitle;
    else
    {
        if (_totalCount != 0 && _currentIndex >= 0)
            counterText = [[NSString alloc] initWithFormat:@"%@ %@ %@", [TGStringUtils stringWithLocalizedNumber:_reversed ? (_currentIndex + 1 + (_loadedCount != 0 ? (_totalCount - _loadedCount) : 0)) : (_totalCount - _currentIndex)], TGLocalized(@"Common.of"), [TGStringUtils stringWithLocalizedNumber:_totalCount]];
        else
            counterText = @"";
    }
    
    if (![_counterLabel.text isEqualToString:counterText])
    {
        if (_counterLabel.text.length == 0 && counterText.length != 0)
        {
            _counterLabel.alpha = 0.0f;
            [UIView animateWithDuration:0.2 animations:^
             {
                 _counterLabel.alpha = 1.0f;
             }];
        }
        
        _counterLabel.text = counterText;
        [self _layoutNavigationBar];
    }
    
    NSString *authorText = _author == nil ? @"" : _author.displayName;
    if (![_authorLabel.text isEqualToString:authorText])
    {
        _authorLabel.text = authorText;
        _progressAuthorLabel.text = authorText;
    }
    
    NSString *dateText = _date == 0 ? @"" : [TGDateUtils stringForApproximateDate:_date];
    if (![dateText isEqualToString:_dateLabel.rawDateText])
    {
        _dateLabel.dateText = dateText;
        [_dateLabel measureTextSize];
    }
    
    if (authorText.length > 0)
        _progressLabel.frame = CGRectMake(_progressLabel.frame.origin.x, 23, _progressLabel.frame.size.width, _progressLabel.frame.size.height);
    else
        _progressLabel.frame = CGRectMake(_progressLabel.frame.origin.x, 14, _progressLabel.frame.size.width, _progressLabel.frame.size.height);
}

- (void)setTotalCount:(int)totalCount loadedCount:(int)loadedCount
{
    _totalCount = totalCount;
    _loadedCount = loadedCount;
    
    [self updateLabels];
}

- (void)setCurrentIndex:(int)currentIndex author:(TGUser *)author date:(int)date
{
    bool updated = false;
    if (_currentIndex != currentIndex)
    {
        _currentIndex = currentIndex;
        updated = true;
    }
    
    if (_author != author)
    {
        _author = author;
        updated = true;
    }
    
    if (_date != date)
    {
        _date = date;
        updated = true;
    }
    
    if (updated)
        [self updateLabels];
}

- (void)setCurrentIndex:(int)currentIndex totalCount:(int)totalCount loadedCount:(int)loadedCount author:(TGUser *)author date:(int)date
{
    _currentIndex = currentIndex;
    _totalCount = totalCount;
    _loadedCount = loadedCount;
    _author = author;
    _date = date;
    
    [self updateLabels];
}

- (void)setPageHandle:(ASHandle *)pageHandle
{
    if (_pageHandle != nil)
        [_pageHandle requestAction:@"bindInterfaceView" options:nil];
    
    _pageHandle = pageHandle;
    
    if (_pageHandle != nil)
    {
        [_pageHandle requestAction:@"bindInterfaceView" options:_actionHandle];
    }
}

- (void)setPlayerControlsVisible:(bool)visible paused:(bool)paused
{
    _playButton.alpha = visible ? 1.0f : 0.0f;
    _pauseButton.alpha = _playButton.alpha;
    _authorLabel.alpha = visible ? 0.0f : 1.0f;
    _dateLabel.alpha = visible ? 0.0f : 1.0f;
    
    _playButton.hidden = !paused;
    _pauseButton.hidden = !_playButton.hidden;
}

- (void)setDownloadControlsVisible:(bool)visible
{
    _controlsContainer.alpha = visible ? 0.0f : 1.0f;
    _progressContainer.alpha = visible ? 1.0f : 0.0f;
    
    if (visible)
    {
        NSString *progressText = (_playButton.alpha > FLT_EPSILON) ? TGLocalized(@"Preview.LoadingVideo") : TGLocalized(@"Preview.LoadingImage");
        if (![progressText isEqualToString:_progressLabel.text])
        {
            _progressLabel.text = progressText;
            [_progressLabel sizeToFit];
            
            _progressLabel.frame = CGRectMake(floorf((_bottomPanelView.frame.size.width - _progressLabel.frame.size.width) / 2) + 10, _progressLabel.frame.origin.y, _progressLabel.frame.size.width, _progressLabel.frame.size.height);
        }
    }
    
    if (_clockProgressView.isAnimating != visible)
    {
        if (visible)
            [_clockProgressView startAnimating];
        else
            [_clockProgressView stopAnimating];
    }
}

- (void)playButtonPressed
{
    [_pageHandle requestAction:@"playMedia" options:nil];
}

- (void)pauseButtonPressed
{
    [_pageHandle requestAction:@"pauseMedia" options:nil];    
}

- (void)setCustomTitle:(NSString *)customTitle
{
    if ((_customTitle != nil) != (customTitle != nil) || (_customTitle != nil && ![_customTitle isEqualToString:customTitle]))
    {
        _customTitle = customTitle;
        
        [self updateLabels];
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"bindPage"])
    {
        [self setPageHandle:options];
    }
    else if ([action isEqualToString:@"mediaPlaybackState"])
    {
        [self setPlayerControlsVisible:[[options objectForKey:@"mediaIsPlayable"] boolValue] paused:![[options objectForKey:@"isPlaying"] boolValue]];
    }
    else if ([action isEqualToString:@"mediaDownloadState"])
    {
        [self setDownloadControlsVisible:[[options objectForKey:@"downloadProgressVisible"] boolValue]];
    }
}

@end