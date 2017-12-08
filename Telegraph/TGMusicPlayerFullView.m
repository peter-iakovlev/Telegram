#import "TGMusicPlayerFullView.h"

#import <LegacyComponents/LegacyComponents.h>
#import "TGMusicPlayerModeButton.h"
#import "TGMusicPlayerScrubbingArea.h"
#import "TGMusicPlaylistCell.h"
#import "TGScrollIndicatorView.h"

#import "TGMusicPlayerItemSignals.h"
#import "TGMusicPlayer.h"
#import "TGTelegraph.h"

@interface TGMusicPlayerCollectionView : UICollectionView
{
    UIView *_whiteTailView;
}
@end


@interface TGMusicPlayerWrapperView : UIView

@end

@interface TGMusicPlayerFullView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{    
    UIView *_dimView;
    
    UIView *_containerView;

    TGModernButton *_arrowView;
    UIView *_panelView;
    UIView *_controlsView;
    TGMusicPlayerScrubbingArea *_scrubbingArea;
    UIImageView *_scrubbingBackground;
    UIImageView *_playbackScrubbingForeground;
    UIImageView *_downloadingScrubbingForeground;
    UIImageView *_scrubbingHandle;
    
    UILabel *_titleLabel;
    UILabel *_performerLabel;
    TGModernButton *_controlBackButton;
    TGModernButton *_controlForwardButton;
    TGModernButton *_controlPlayButton;
    TGModernButton *_controlPauseButton;
    TGMusicPlayerModeButton *_controlShuffleButton;
    TGMusicPlayerModeButton *_controlRepeatButton;
    TGModernButton *_actionsButton;
    
    UILabel *_positionLabel;
    int _positionLabelValue;
    UILabel *_durationLabel;
    int _durationLabelValue;
    
    bool _shouldBeginScrubbing;
    bool _scrubbing;
    CGPoint _scrubbingReferencePoint;
    CGFloat _scrubbingReferenceOffset;
    CGFloat _scrubbingOffset;
    
    CGFloat _playbackOffset;
    CGFloat _downloadProgress;
    
    id<SDisposable> _playerStatusDisposable;
    id<SDisposable> _playlistDisposable;
    
    TGMusicPlayerStatus *_currentStatus;
    TGMusicPlayerPlaylist *_currentPlaylist;
    NSString *_title;
    NSString *_performer;
    TGMusicPlayerItemPosition _currentItemPosition;
    
    TGImageView *_coverView;
    
    CGFloat _coverExpandProgress;
    
    UIImageView *_edgeView;
    UICollectionView *_collectionView;
    UIView *_separator;
    TGScrollIndicatorView *_scrollIndicator;
    
    bool _updateLabelsLayout;
    
    bool _presented;
    
    bool _scrollingPanel;
    CGFloat _panelScrollingReferencePoint;
    CGFloat _panelScrollingOffset;
    NSNumber *_previousContentOffset;
    
    id<LegacyComponentsContext> _context;
}
@end

@implementation TGMusicPlayerFullView

- (instancetype)initWithFrame:(CGRect)frame context:(id<LegacyComponentsContext>)context
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _context = context;
        
        _dimView = [[UIView alloc] init];
        _dimView.alpha = 0.0f;
        _dimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        [self addSubview:_dimView];
        
        _containerView = [[TGMusicPlayerWrapperView alloc] init];
        _containerView.hidden = true;
        [self addSubview:_containerView];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.minimumLineSpacing = 0.0f;
        collectionLayout.minimumInteritemSpacing = 0.0f;

        _collectionView = [[TGMusicPlayerCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:collectionLayout];
        if (iosMajorVersion() >= 11)
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = false;
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.delaysContentTouches = false;
        _collectionView.canCancelContentTouches = true;
        [_collectionView registerClass:[TGMusicPlaylistCell class] forCellWithReuseIdentifier:TGMusicPlaylistCellKind];
        [_containerView addSubview:_collectionView];
        
        _panelView = [[UIView alloc] init];
        [_collectionView addSubview:_panelView];
        
        _edgeView = [[UIImageView alloc] initWithImage:[TGComponentsImageNamed(@"LocationPanelEdge") resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)]];
        _edgeView.highlightedImage = [TGComponentsImageNamed(@"LocationPanelEdge_Highlighted") resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
        _edgeView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, _edgeView.frame.size.height);
        [_panelView addSubview:_edgeView];
        
        _separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, TGScreenPixel)];
        _separator.alpha = 0.0f;
        _separator.backgroundColor = TGSeparatorColor();
        [_panelView addSubview:_separator];
        
        _controlsView = [[UIView alloc] init];
        _controlsView.backgroundColor = [UIColor whiteColor];
        [_panelView addSubview:_controlsView];
        
        _arrowView = [[TGModernButton alloc] init];
        _arrowView.adjustsImageWhenHighlighted = false;
        [_arrowView setImage:TGImageNamed(@"MusicPlayerArrow") forState:UIControlStateNormal];
        [_arrowView addTarget:self action:@selector(arrowPressed) forControlEvents:UIControlEventTouchUpInside];
        [_arrowView sizeToFit];
        [_panelView addSubview:_arrowView];
        
        static dispatch_once_t onceToken;
        static UIImage *moreImage;
        static UIImage *trackImage;
        static UIImage *handleImage;
        dispatch_once(&onceToken, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(19.0f, 5.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 5.0f, 5.0f));
            CGContextFillEllipseInRect(context, CGRectMake(7.0f, 0.0f, 5.0f, 5.0f));
            CGContextFillEllipseInRect(context, CGRectMake(14.0f, 0.0f, 5.0f, 5.0f));
            
            moreImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(3.0f, 3.0f), false, 0.0f);
            context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 3.0f, 3.0f));
            trackImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(6.0f, 6.0f), false, 0.0f);
            context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 6.0f, 6.0f));
            handleImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _scrubbingBackground = [[UIImageView alloc] initWithImage:[TGTintedImage(trackImage, UIColorRGB(0xcccccc)) resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.5f, 0.0f, 1.5f)]];
        [_controlsView addSubview:_scrubbingBackground];
        
        _playbackScrubbingForeground = [[UIImageView alloc] initWithImage:[TGTintedImage(trackImage, TGAccentColor()) resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.5f, 0.0f, 1.5f)]];
        [_controlsView addSubview:_playbackScrubbingForeground];
        
        _downloadingScrubbingForeground = [[UIImageView alloc] initWithImage:_playbackScrubbingForeground.image];
        [_controlsView addSubview:_downloadingScrubbingForeground];
        
        _scrubbingHandle = [[UIImageView alloc] initWithImage:handleImage];
        [_controlsView addSubview:_scrubbingHandle];
        
        _scrubbingArea = [[TGMusicPlayerScrubbingArea alloc] init];
        __weak TGMusicPlayerFullView *weakSelf = self;
        _scrubbingArea.didBeginDragging = ^(UITouch *touch)
        {
            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf beginScrubbingAtPoint:[strongSelf scrubbingLocationForTouch:touch]];
        };
        _scrubbingArea.willMove = ^(UITouch *touch)
        {
            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf continueScrubbingAtPoint:[strongSelf scrubbingLocationForTouch:touch]];
        };
        _scrubbingArea.didFinishDragging = ^
        {
            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf finishScrubbing];
        };
        _scrubbingArea.didCancelDragging = ^
        {
            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf cancelScrubbing];
        };
        [_controlsView addSubview:_scrubbingArea];
        
        _positionLabel = [[UILabel alloc] init];
        _positionLabel.backgroundColor = [UIColor whiteColor];
        _positionLabel.textColor = UIColorRGB(0x8d8e93);
        _positionLabel.font = TGSystemFontOfSize(13.0f);
        [_controlsView addSubview:_positionLabel];
        _positionLabelValue = INT_MIN;
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor whiteColor];
        _durationLabel.textColor = UIColorRGB(0x8d8e93);
        _durationLabel.font = TGSystemFontOfSize(13.0f);
        [_controlsView addSubview:_durationLabel];
        _durationLabelValue = INT_MIN;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(16.0f);
        [_controlsView addSubview:_titleLabel];
        
        _performerLabel = [[UILabel alloc] init];
        _performerLabel.backgroundColor = [UIColor whiteColor];
        _performerLabel.textColor = UIColorRGB(0x8d8e93);
        _performerLabel.font = TGSystemFontOfSize(12.0f);
        [_controlsView addSubview:_performerLabel];
        
        _coverView = [[TGImageView alloc] init];
        _coverView.backgroundColor = UIColorRGB(0xeeeeee);
        _coverView.clipsToBounds = true;
        _coverView.layer.cornerRadius = 7.0f;
        _coverView.userInteractionEnabled = true;
        [_controlsView addSubview:_coverView];
        
        if (iosMajorVersion() >= 11)
            _coverView.accessibilityIgnoresInvertColors = true;
        
        [_coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverTapped)]];
        
        UITapGestureRecognizer *dimTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimTapped:)];
        dimTapGestureRecognizer.delegate = self;
        [_collectionView addGestureRecognizer:dimTapGestureRecognizer];
        
        UIPanGestureRecognizer *swipeGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        swipeGestureRecognizer.delegate = self;
        [_collectionView addGestureRecognizer:swipeGestureRecognizer];
        
        _controlPlayButton = [[TGModernButton alloc] init];
        _controlPlayButton.adjustsImageWhenHighlighted = false;
        [_controlPlayButton setImage:TGImageNamed(@"MusicPlayerControlPlay.png") forState:UIControlStateNormal];
        [_controlPlayButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
        [_controlPlayButton addTarget:self action:@selector(controlPlay) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_controlPlayButton];
        
        _controlPauseButton = [[TGModernButton alloc] init];
        _controlPauseButton.adjustsImageWhenHighlighted = false;
        [_controlPauseButton setImage:TGImageNamed(@"MusicPlayerControlPause.png") forState:UIControlStateNormal];
        [_controlPauseButton addTarget:self action:@selector(controlPause) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_controlPauseButton];
        
        _controlBackButton = [[TGModernButton alloc] init];
        _controlBackButton.adjustsImageWhenHighlighted = false;
        [_controlBackButton setImage:TGImageNamed(@"MusicPlayerControlBack.png") forState:UIControlStateNormal];
        [_controlBackButton addTarget:self action:@selector(controlBack) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_controlBackButton];
        
        _controlForwardButton = [[TGModernButton alloc] init];
        _controlForwardButton.adjustsImageWhenHighlighted = false;
        [_controlForwardButton setImage:TGImageNamed(@"MusicPlayerControlForward.png") forState:UIControlStateNormal];
        [_controlForwardButton addTarget:self action:@selector(controlForward) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_controlForwardButton];
        
        _controlShuffleButton = [[TGMusicPlayerModeButton alloc] init];
        _controlShuffleButton.adjustsImageWhenHighlighted = false;
        [_controlShuffleButton setImage:TGImageNamed(@"MusicPlayerControlReverse.png") forState:UIControlStateNormal];
        [_controlShuffleButton addTarget:self action:@selector(controlOrder) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_controlShuffleButton];
        
        _controlRepeatButton = [[TGMusicPlayerModeButton alloc] init];
        _controlRepeatButton.adjustsImageWhenHighlighted = false;
        [_controlRepeatButton setImage:TGImageNamed(@"MusicPlayerControlRepeat.png") forState:UIControlStateNormal];
        [_controlRepeatButton addTarget:self action:@selector(controlRepeat) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_controlRepeatButton];
        
        _actionsButton = [[TGModernButton alloc] init];
        _actionsButton.adjustsImageWhenHighlighted = false;
        [_actionsButton setImage:moreImage forState:UIControlStateNormal];
        [_actionsButton addTarget:self action:@selector(actionsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_controlsView addSubview:_actionsButton];
        
        _currentItemPosition = (TGMusicPlayerItemPosition){.index = 0, .count = -1};
        
        _playerStatusDisposable = [[TGTelegraphInstance.musicPlayer playingStatus] startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setStatus:status];
        }];
        
        _playlistDisposable = [[TGTelegraphInstance.musicPlayer playlist] startWithNext:^(TGMusicPlayerPlaylist *playlist)
        {
            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setPlaylist:playlist];
        }];
        
        _updateLabelsLayout = true;
        
        _scrollIndicator = [[TGScrollIndicatorView alloc] init];
        [_scrollIndicator setHidden:true animated:false];
        [_collectionView addSubview:_scrollIndicator];
    }
    return self;
}

- (void)dealloc
{
    [_playerStatusDisposable dispose];
}

- (void)setFrame:(CGRect)frame
{
    _updateLabelsLayout = ABS(self.frame.size.width - frame.size.width) > FLT_EPSILON;
    [super setFrame:frame];
    
    if (_updateLabelsLayout)
    {
        [self setNeedsLayout];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self scrollViewDidScroll:_collectionView];
        });
    }
}

- (void)setStatus:(TGMusicPlayerStatus *)status
{
    TGMusicPlayerStatus *previousStatus = _currentStatus;
    _currentStatus = status;
    
    if (_currentItemPosition.index != status.position.index || _currentItemPosition.count != status.position.count)
    {
        _currentItemPosition = status.position;
        [self updateCells];
    }
    
    if (previousStatus.paused != status.paused)
        [self updateCells];
    
    if (!TGObjectCompare(status.item.key, previousStatus.item.key))
    {
        NSString *title = status.item.title;
        NSString *performer = status.item.performer;
        
        if (title.length == 0)
            title = @"Unknown Track";
        
        if (performer.length == 0)
            performer = @"Unknown Artist";
        
        if (status != nil)
        {
            if (!TGStringCompare(_title, title) || !TGStringCompare(_performer, performer))
            {
                _title = title;
                _performer = performer;
                
                _updateLabelsLayout = true;
                
                _titleLabel.text = title;
                _performerLabel.text = performer;
                
                [self setNeedsLayout];
            }
        }
        
        [_coverView setSignal:[[TGMusicPlayerItemSignals albumArtForItem:status.item thumbnail:false] catch:^(__unused id error)
        {
            CGSize size = CGSizeMake(390.0f, 390.0f);
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIColorRGB(0xeeeeee) setFill];
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
            
            UIImage *icon = TGImageNamed(@"MusicPlayerAlbumArtPlaceholder");
            [icon drawAtPoint:CGPointMake((size.width - icon.size.width) / 2.0f - 10.0f, (size.height - icon.size.height) / 2.0f)];
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return [SSignal single:image];
        }]];
    }
    
    _controlPlayButton.hidden = !status.paused;
    _controlPauseButton.hidden = status.paused;
    
    if ([self reversePlaylistForOrderType:status.orderType] != [self reversePlaylistForOrderType:previousStatus.orderType])
        [_collectionView reloadData];
    
    if (status.orderType != previousStatus.orderType)
    {
        switch (status.orderType)
        {
            case TGMusicPlayerOrderTypeNewestFirst:
                [_controlShuffleButton setImage:TGImageNamed(@"MusicPlayerControlReverse.png") forState:UIControlStateNormal];
                _controlShuffleButton.selected = false;
                break;
                
            case TGMusicPlayerOrderTypeOldestFirst:
                [_controlShuffleButton setImage:TGImageNamed(@"MusicPlayerControlReverse.png") forState:UIControlStateNormal];
                _controlShuffleButton.selected = true;
                break;
                
            case TGMusicPlayerOrderTypeShuffle:
                [_controlShuffleButton setImage:TGImageNamed(@"MusicPlayerControlShuffle.png") forState:UIControlStateNormal];
                _controlShuffleButton.selected = true;
                break;
        }
    }
    if (status.repeatType != previousStatus.repeatType)
    {
        switch (status.repeatType)
        {
            case TGMusicPlayerRepeatTypeNone:
                [_controlRepeatButton setImage:TGImageNamed(@"MusicPlayerControlRepeat.png") forState:UIControlStateNormal];
                _controlRepeatButton.selected = false;
                break;
                
            case TGMusicPlayerRepeatTypeAll:
                [_controlRepeatButton setImage:TGImageNamed(@"MusicPlayerControlRepeat.png") forState:UIControlStateNormal];
                _controlRepeatButton.selected = true;
                break;
                
            case TGMusicPlayerRepeatTypeOne:
                [_controlRepeatButton setImage:TGImageNamed(@"MusicPlayerControlRepeatOne.png") forState:UIControlStateNormal];
                _controlRepeatButton.selected = true;
                break;
        }
    }
    
    CGFloat disabledAlpha = 0.6f;
    
    _scrubbingHandle.hidden = !status.downloadedStatus.downloaded;
    
    bool buttonsEnabled = status.downloadedStatus.downloaded;
    if (buttonsEnabled != _controlPlayButton.enabled)
    {
        _controlPlayButton.enabled = buttonsEnabled;
        _controlPauseButton.enabled = buttonsEnabled;
        _controlPlayButton.alpha = buttonsEnabled ? 1.0f : disabledAlpha;
        _controlPauseButton.alpha = buttonsEnabled ? 1.0f : disabledAlpha;
        _scrubbingArea.enabled = buttonsEnabled;
    }
    
    static POPAnimatableProperty *playbackOffsetProperty = nil;
    static POPAnimatableProperty *downloadProgressProperty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        playbackOffsetProperty = [POPAnimatableProperty propertyWithName:@"playbackOffset" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGMusicPlayerFullView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_playbackOffset;
            };
            
            prop.writeBlock = ^(TGMusicPlayerFullView *strongSelf, CGFloat const *values)
            {
                strongSelf->_playbackOffset = values[0];
                if (!strongSelf->_scrubbing)
                    [strongSelf layoutScrubbingIndicator];
            };
        }];
        
        downloadProgressProperty = [POPAnimatableProperty propertyWithName:@"downloadProgress" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGMusicPlayerFullView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_downloadProgress;
            };
            
            prop.writeBlock = ^(TGMusicPlayerFullView *strongSelf, CGFloat const *values)
            {
                strongSelf->_downloadProgress = values[0];
                [strongSelf layoutScrubbingIndicator];
            };
        }];
    });
    
    if (!status.downloadedStatus.downloaded)
    {
        if (status.downloadedStatus.downloading)
        {
            _downloadingScrubbingForeground.alpha = 1.0f;
            if (TGObjectCompare(previousStatus.item.key, status.item.key))
            {
                [self pop_removeAnimationForKey:@"downloadIndicator"];
                POPBasicAnimation *animation = [self pop_animationForKey:@"downloadIndicator"];
                if (animation == nil)
                {
                    animation = [POPBasicAnimation linearAnimation];
                    [animation setProperty:downloadProgressProperty];
                    animation.removedOnCompletion = true;
                    animation.fromValue = @(_downloadProgress);
                    animation.toValue = @(status.downloadedStatus.progress);
                    animation.beginTime = status.timestamp;
                    animation.duration = 0.25;
                    [self pop_addAnimation:animation forKey:@"downloadIndicator"];
                }
            }
            else
            {
                [self pop_removeAnimationForKey:@"downloadIndicator"];
                _downloadProgress = status.downloadedStatus.progress;
                [self layoutScrubbingIndicator];
            }
        }
        else
        {
            _downloadProgress = status.downloadedStatus.progress;
            _downloadingScrubbingForeground.alpha = 0.0f;
            [self layoutScrubbingIndicator];
        }
    }
    else
    {
        if (TGObjectCompare(previousStatus.item.key, status.item.key))
        {
            if (!previousStatus.downloadedStatus.downloaded)
            {
                [self pop_removeAnimationForKey:@"downloadIndicator"];
                POPBasicAnimation *animation = [self pop_animationForKey:@"downloadIndicator"];
                if (animation == nil)
                {
                    animation = [POPBasicAnimation linearAnimation];
                    [animation setProperty:downloadProgressProperty];
                    animation.removedOnCompletion = true;
                    animation.fromValue = @(_downloadProgress);
                    animation.toValue = @(1.0f);
                    animation.beginTime = status.timestamp;
                    animation.duration = 0.25;
                    
                    __weak TGMusicPlayerFullView *weakSelf = self;
                    animation.completionBlock = ^(__unused POPAnimation *animation, BOOL finished)
                    {
                        if (finished)
                        {
                            __strong TGMusicPlayerFullView *strongSelf = weakSelf;
                            if (strongSelf != nil)
                            {
                                [UIView animateWithDuration:0.3 animations:^
                                {
                                    strongSelf->_downloadingScrubbingForeground.alpha = 0.0f;
                                }];
                            }
                        }
                    };
                    [self pop_addAnimation:animation forKey:@"downloadIndicator"];
                }
            }
        }
        else
            _downloadingScrubbingForeground.alpha = 0.0f;
    }
    
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
            [animation setProperty:playbackOffsetProperty];
            animation.removedOnCompletion = true;
            _playbackOffset = status.offset;
            animation.fromValue = @(status.offset);
            animation.toValue = @(1.0f);
            animation.beginTime = status.timestamp;
            animation.duration = (1.0f - status.offset) * status.duration;
            [self pop_addAnimation:animation forKey:@"scrubbingIndicator"];
        }
    }
}

- (void)setPlaylist:(TGMusicPlayerPlaylist *)playlist
{
    if (playlist.voice)
    {
        [self dismissAnimated:true completion:nil];
        return;
    }
    
    _currentPlaylist = playlist;
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
    
    if (!_presented)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self layoutControls];
            [self setDimViewHidden:false animated:true];
            
            NSInteger count = _currentPlaylist.items.count > 1 ? _currentPlaylist.items.count : 0;
            CGFloat visibleHeight = _panelView.frame.size.height + MIN(4, count) * TGMusicPlaylistCellHeight;
            NSUInteger index = [self reversePlaylist] ? _currentItemPosition.count - _currentItemPosition.index - 1 : _currentItemPosition.index;
            
            [self applyViewOffset:visibleHeight];
            _containerView.hidden = false;
            
            [self animateSheetViewToPosition:0.0f velocity:0.0f present:true completion:^{}];

            if (index > 3)
            {
                CGFloat position = _panelView.frame.size.height + TGMusicPlaylistCellHeight * (index + 1) + (_collectionView.frame.size.height - _panelView.frame.size.height - TGMusicPlaylistCellHeight) / 2.0f;
                CGFloat maxPosition = _collectionView.contentSize.height - _collectionView.frame.size.height;
                CGFloat finalPosition = MIN(maxPosition, -_collectionView.contentInset.top + 10.0f + MAX(visibleHeight, position));
                [_collectionView setContentOffset:CGPointMake(0.0f, finalPosition) animated:false];
            }
            else
            {
                CGFloat offset = _safeAreaInset.bottom > FLT_EPSILON ? 2 * _safeAreaInset.bottom - 10.0f : 10.0f;
                [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top + visibleHeight + offset) animated:false];
            }
            
            TGDispatchAfter(0.3, dispatch_get_main_queue(), ^
            {
                _presented = true;
            });
        });
    }
}

- (void)controlPlay
{
    [TGTelegraphInstance.musicPlayer controlPlay];
}

- (void)controlPause
{
    [TGTelegraphInstance.musicPlayer controlPause];
}

- (void)controlBack
{
    [TGTelegraphInstance.musicPlayer controlPrevious];
}

- (void)controlForward
{
    [TGTelegraphInstance.musicPlayer controlNext];
}

- (void)controlOrder
{
    [TGTelegraphInstance.musicPlayer controlOrder];
}

- (void)controlRepeat
{
    [TGTelegraphInstance.musicPlayer controlRepeat];
}

- (void)actionsButtonPressed
{
    if (self.actionsPressed != nil)
        self.actionsPressed();
}

- (CGPoint)scrubbingLocationForTouch:(UITouch *)touch
{
    return [touch locationInView:_scrubbingArea];
}

- (void)beginScrubbingAtPoint:(CGPoint)point
{
    _shouldBeginScrubbing = true;
    _scrubbingReferencePoint = point;
    _scrubbingOffset = _playbackOffset;
    _scrubbingReferenceOffset = _playbackOffset;
}

- (void)continueScrubbingAtPoint:(CGPoint)point
{
    if (_shouldBeginScrubbing && !_scrubbing && fabs(point.x - _scrubbingReferencePoint.x) > 4.0f)
    {
        _shouldBeginScrubbing = false;
        _scrubbing = true;
        [TGTelegraphInstance.musicPlayer controlPause];
    }
    
    if (_scrubbing && _scrubbingArea.frame.size.width > FLT_EPSILON)
    {
        _scrubbingOffset = MAX(0.0f, MIN(1.0f, _scrubbingReferenceOffset + (point.x - _scrubbingReferencePoint.x) / _scrubbingArea.frame.size.width));
        [self layoutScrubbingIndicator];
    }
}

- (void)finishScrubbing
{
    if (_scrubbing)
    {
        [TGTelegraphInstance.musicPlayer controlSeekToPosition:_scrubbingOffset];
        [TGTelegraphInstance.musicPlayer controlPlay];
    }
    
    _shouldBeginScrubbing = false;
    _scrubbing = false;
    _playbackOffset = _scrubbingOffset;
    _scrubbingOffset = 0.0f;
    [self layoutScrubbingIndicator];
}

- (void)cancelScrubbing
{
    _scrubbing = false;
    _scrubbingOffset = 0.0f;
    [self layoutScrubbingIndicator];
    [TGTelegraphInstance.musicPlayer controlPlay];
}

#pragma mark -

- (void)applyViewOffset:(CGFloat)position
{
    _containerView.frame = CGRectMake(0.0f, position, _containerView.frame.size.width, _containerView.frame.size.height);
}

- (void)animateSheetViewToPosition:(CGFloat)position velocity:(CGFloat)velocity present:(bool)present completion:(void (^)(void))completion
{
    CGFloat animationVelocity = position > 0 ? fabs(velocity) / fabs(position - self.frame.origin.y) : 0;
    
    void (^changeBlock)(void) = ^
    {
        [self applyViewOffset:position];
    };
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    };
    
    CGFloat duration = 0.45;
    
    if (present)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent;
        if (iosMajorVersion() >= 7)
            options |= 7 << 16;
        [UIView animateWithDuration:0.3 delay:0.0 options:options animations:changeBlock completion:completionBlock];
    }
    else
    {
        if (iosMajorVersion() >= 7)
        {
            [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:animationVelocity options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowAnimatedContent animations:changeBlock completion:completionBlock];
        }
        else
        {
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:changeBlock completion:completionBlock];
        }
    }
}

- (void)dismissAnimated:(bool)animated completion:(void (^)(void))completion
{
    if (animated)
    {
        [self setDimViewHidden:true animated:true];
        
        [self animateSheetViewToPosition:_collectionView.contentInset.top + _collectionView.contentOffset.y velocity:0.0 present:false completion:^
        {
           if (self.dismissed != nil)
               self.dismissed();
            
            if (completion != nil)
                completion();
        }];
    }
    else
    {
        if (self.dismissed != nil)
            self.dismissed();
        
        if (completion != nil)
            completion();
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return true;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
        if ([_panelView pointInside:[_panelView convertPoint:location fromView:gestureRecognizer.view] withEvent:nil])
            return false;
        
        for (UICollectionViewCell *cell in _collectionView.visibleCells)
        {
            if ([cell pointInside:[cell convertPoint:location fromView:gestureRecognizer.view] withEvent:nil])
                return false;
        }
        
        return true;
    }
    else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
        CGFloat screenHeight = [_context fullscreenBounds].size.height;
        CGFloat panelOffset = MAX(0, _collectionView.contentOffset.y + _collectionView.contentInset.top - screenHeight);
        if (panelOffset < FLT_EPSILON)
            return false;
        
        if (![_panelView pointInside:[_panelView convertPoint:location fromView:gestureRecognizer.view] withEvent:nil] || [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].y < -FLT_EPSILON)
            return false;
    }
    return true;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _collectionView.scrollEnabled = false;
        _panelScrollingReferencePoint = [gestureRecognizer locationInView:self].y;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat location = [gestureRecognizer locationInView:self].y;
        CGFloat delta = location - _panelScrollingReferencePoint;
        [self applyViewOffset:MAX(0, delta)];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGFloat location = [gestureRecognizer locationInView:self].y;
        CGFloat delta = location - _panelScrollingReferencePoint;
        
        if (delta > self.frame.size.height / 3.0f || [gestureRecognizer velocityInView:gestureRecognizer.view].y > 1000.0f)
        {
            [self dismissAnimated:true completion:nil];
        }
        else
        {
            _collectionView.scrollEnabled = true;
            [self animateSheetViewToPosition:0.0f velocity:0.0f present:true completion:nil];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        _collectionView.scrollEnabled = true;
    }
}

- (void)dimTapped:(UIGestureRecognizer *)__unused gestureRecognizer
{
    [self dismissAnimated:true completion:nil];
}

- (void)setDimViewHidden:(bool)hidden animated:(bool)animated
{
    void (^changeBlock)(void) = ^
    {
        _dimView.alpha = hidden ? 0.0f : 1.0f;
    };
    
    if (animated)
        [UIView animateWithDuration:0.25f animations:changeBlock];
    else
        changeBlock();
}

- (void)setSeparatorHidden:(bool)hidden animated:(bool)animated
{
    if ((hidden && _separator.alpha < FLT_EPSILON) || (!hidden && _separator.alpha > FLT_EPSILON))
        return;
    
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             _separator.alpha = hidden ? 0.0f : 1.0f;
         }];
    }
    else
    {
        _separator.alpha = hidden ? 0.0f : 1.0f;
    }
}

- (void)coverTapped
{
    [self setCoverZoomedIn:_coverExpandProgress < FLT_EPSILON animated:true];
}

- (void)arrowPressed
{
    [self dismissAnimated:true completion:nil];
}

- (void)setCoverZoomedIn:(bool)zoomedIn animated:(bool)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:7 << 16 animations:^
        {
            _coverExpandProgress = zoomedIn ? 1.0f : 0.0f;
            [self layoutSubviews];
        } completion:nil];
    }
    else
    {
        _coverExpandProgress = zoomedIn ? 1.0f : 0.0f;
        [self setNeedsLayout];
    }
}

#pragma mark -

- (void)updateCells
{
    for (TGMusicPlaylistCell *cell in _collectionView.visibleCells)
    {
        bool isCurrent = [cell.item.key isEqual:_currentStatus.item.key];
        [cell setCurrent:isCurrent];
        [cell setPlaying:isCurrent && !_currentStatus.paused];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGMusicPlaylistCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGMusicPlaylistCellKind forIndexPath:indexPath];
    NSUInteger index = [self reversePlaylist] ? _currentPlaylist.items.count - indexPath.row - 1 : indexPath.row;
    TGMusicPlayerItem *item = _currentPlaylist.items[index];
    [cell setItem:item];

    bool isCurrent = [item.key isEqual:_currentStatus.item.key];
    [cell setCurrent:isCurrent];
    [cell setPlaying:isCurrent && !_currentStatus.paused];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)__unused collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    CGRect panelFrame = [_panelView convertRect:_panelView.bounds toView:self];
    CGRect frame = [cell convertRect:cell.bounds toView:self];
    cell.hidden = frame.origin.y < panelFrame.origin.y + 64.0f;
}

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _currentPlaylist.items.count > 1 ? _currentPlaylist.items.count : 0;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [self reversePlaylist] ? _currentPlaylist.items.count - indexPath.row - 1 : indexPath.row;
    TGMusicPlayerItem *item = _currentPlaylist.items[index];
    [TGTelegraphInstance.musicPlayer playMediaFromItem:item];

    [collectionView deselectItemAtIndexPath:collectionView.indexPathsForSelectedItems.firstObject animated:true];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    return CGSizeMake(collectionView.frame.size.width, TGMusicPlaylistCellHeight);
}

- (bool)reversePlaylistForOrderType:(TGMusicPlayerOrderType)orderType
{
    return orderType == TGMusicPlayerOrderTypeNewestFirst;
}

- (bool)reversePlaylist
{
    return [self reversePlaylistForOrderType:_currentStatus.orderType];
}

#pragma mark -

- (CGFloat)progressHeight
{
    return 3.0f;
}

- (CGSize)handleSize
{
    return CGSizeMake(6.0f, 6.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self layoutControls];
    
    CGFloat previousOffset = scrollView.contentOffset.y;
    if (_previousContentOffset != nil)
        previousOffset = _previousContentOffset.doubleValue;
    _previousContentOffset = @(scrollView.contentOffset.y);
    
    CGRect panelFrame = [_panelView convertRect:_panelView.bounds toView:self];
    for (UICollectionViewCell *cell in _collectionView.visibleCells)
    {
        CGRect frame = [cell convertRect:cell.bounds toView:self];
        cell.hidden = frame.origin.y < panelFrame.origin.y + 64.0f;
    }
    
    if (scrollView.isTracking && _coverExpandProgress > 1.0f - FLT_EPSILON && fabs(scrollView.contentOffset.y - previousOffset) > FLT_EPSILON)
        [self setCoverZoomedIn:false animated:true];
    
    if (_presented && !scrollView.isTracking && scrollView.contentOffset.y < -scrollView.contentInset.top + _panelView.frame.size.height)
        [self dismissAnimated:true completion:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && scrollView.contentOffset.y < -scrollView.contentInset.top + _panelView.frame.size.height)
        [self dismissAnimated:true completion:nil];
    
    _previousContentOffset = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView
{
    _previousContentOffset = nil;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)__unused scrollView
{
    _previousContentOffset = nil;
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self layoutSubviews];
}

- (void)layoutScrubbingIndicator
{
    CGFloat displayOffset = _scrubbing ? _scrubbingOffset : _playbackOffset;
    
    CGFloat progressHeight = [self progressHeight];
    CGSize handleSize = [self handleSize];
    
    CGFloat screenWidth = TGIsPad() ? 414.0f : self.frame.size.width;
    
    CGFloat padding = 20.0f;
    CGFloat side = screenWidth - padding * 2.0f;
    CGFloat handleOriginX = TGScreenPixelFloor((side - handleSize.width) * displayOffset);
    _playbackScrubbingForeground.frame = CGRectMake(padding, _scrubbingBackground.frame.origin.y, handleOriginX, progressHeight);
    _downloadingScrubbingForeground.frame = CGRectMake(padding, _scrubbingBackground.frame.origin.y, _downloadProgress * side, progressHeight);
    _scrubbingHandle.frame = CGRectMake(padding + handleOriginX - 1.5f, _scrubbingBackground.frame.origin.y - 1.0f - TGScreenPixel, handleSize.width, handleSize.height);
    
    int positionLabelValue = (int)(displayOffset * _currentStatus.duration);
    int durationLabelValue = (int)(_currentStatus.duration) - positionLabelValue;
    
    if (_positionLabelValue != positionLabelValue)
    {
        _positionLabelValue = positionLabelValue;
        
        if (positionLabelValue > 60 * 60)
        {
            _positionLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", positionLabelValue / (60 * 60), (positionLabelValue % (60 * 60)) / 60, positionLabelValue % 60];
        }
        else
        {
            _positionLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", positionLabelValue / 60, positionLabelValue % 60];
        }
        [_positionLabel sizeToFit];
    }
    _positionLabel.frame = CGRectMake(padding, _scrubbingBackground.frame.origin.y + 8.0f, _positionLabel.frame.size.width, _positionLabel.frame.size.height);
    
    if (_durationLabelValue != durationLabelValue)
    {
        _durationLabelValue = durationLabelValue;
        
        if (durationLabelValue > 60 * 60)
        {
            _durationLabel.text = [[NSString alloc] initWithFormat:@"-%d:%02d:%02d", durationLabelValue / (60 * 60), (durationLabelValue % (60 * 60)) / 60, durationLabelValue % 60];
        }
        else
        {
            _durationLabel.text = [[NSString alloc] initWithFormat:@"-%d:%02d", durationLabelValue / 60, durationLabelValue % 60];
        }
        [_durationLabel sizeToFit];
    }
    _durationLabel.frame = CGRectMake(padding + side - _durationLabel.frame.size.width, _scrubbingBackground.frame.origin.y + 8.0f, _durationLabel.frame.size.width, _durationLabel.frame.size.height);
}

- (void)layoutControls
{
    CGFloat side = MIN(self.frame.size.width, self.frame.size.height);
    side = MIN(side, 414.0f);
    
    CGFloat screenWidth = TGIsPad() ? 414.0f : (self.frame.size.width - _safeAreaInset.left - _safeAreaInset.right);
    if (TGIsPad())
        side = screenWidth;
    
    CGFloat scrubbingHeight = 32.0f;
    CGFloat progressHeight = [self progressHeight];
    
    CGFloat albumArtHeight = side;
    CGSize albumArtImageSize = CGSizeZero;
    
    albumArtHeight = 280.0f;
    albumArtImageSize = CGSizeMake(200.0f, 200.0f);
    
    _edgeView.frame = CGRectMake(0.0f, 0.0f, screenWidth, _edgeView.frame.size.height);
    
    CGFloat largeCoverSize = side - 20.0f * 2.0f;
    CGFloat largeCoverSpace = largeCoverSize + 20.0f;
    CGFloat scrubberOffset = 94.0f + largeCoverSpace * _coverExpandProgress;
    CGFloat controlsHeight = 230.0f - _edgeView.frame.size.height + largeCoverSpace * _coverExpandProgress;
    _controlsView.frame = CGRectMake(0.0f, _edgeView.frame.size.height, screenWidth, controlsHeight);
    
    CGFloat screenHeight = [_context fullscreenBounds].size.height;
    CGFloat panelHeight = _controlsView.frame.size.height + _edgeView.frame.size.height;
    
    CGFloat contentInset = panelHeight + screenHeight + (_safeAreaInset.top > FLT_EPSILON ? _safeAreaInset.top - 10.0f : 10.0f);
    if (fabs(_collectionView.contentInset.top - contentInset) > FLT_EPSILON || fabs(_collectionView.contentInset.bottom - _safeAreaInset.bottom) > FLT_EPSILON)
        _collectionView.contentInset = UIEdgeInsetsMake(contentInset, 0.0f, _safeAreaInset.bottom, 0.0f);
    
    CGFloat panelOffset = MAX(0, _collectionView.contentOffset.y + _collectionView.contentInset.top - screenHeight);
    [self setSeparatorHidden:panelOffset < FLT_EPSILON animated:true];
        
    _panelView.frame = CGRectMake(0.0f, -panelHeight + panelOffset, screenWidth, panelHeight);
    _arrowView.frame = CGRectMake((_panelView.frame.size.width - _arrowView.frame.size.width) / 2.0f, 22.0f, _arrowView.frame.size.width, _arrowView.frame.size.height);
    
    _scrubbingArea.frame = CGRectMake(0.0f, scrubberOffset + progressHeight / 2.0f - scrubbingHeight / 2.0f, _controlsView.bounds.size.width, scrubbingHeight);
    _scrubbingBackground.frame = CGRectMake(20.0f, scrubberOffset, _controlsView.bounds.size.width - 20.0f * 2.0f, progressHeight);
    
    CGFloat titleOffset = 27.0f + largeCoverSpace * _coverExpandProgress;
    CGFloat controlButtonsOffset = scrubberOffset + 35.0f;
    CGFloat controlButtonSize = 60.0f;
    CGFloat controlButtonSpread = 142.0f;
    if ([_context fullscreenBounds].size.width <= 320)
        controlButtonSpread = 100.0f;
    
    CGSize titleSize = _titleLabel.frame.size;
    CGSize performerSize = _performerLabel.frame.size;
    
    if (_updateLabelsLayout)
    {
        _updateLabelsLayout = false;
        titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
        performerSize = [_performerLabel.text sizeWithFont:_performerLabel.font];
        CGFloat maxWidth = _controlsView.bounds.size.width - 68.0f * 2.0f;
        titleSize.width = MIN(titleSize.width, maxWidth);
        performerSize.width = MIN(performerSize.width, maxWidth);
    }
    
    _coverView.frame = CGRectMake(20.0f, 24.0f, 48.0f + (largeCoverSize - 48.0f) * _coverExpandProgress, 48.0f + (largeCoverSize - 48.0f) * _coverExpandProgress);
    
    CGFloat titleX = 85.0f + (CGFloor((_controlsView.bounds.size.width - titleSize.width) / 2.0f) - 85.0f) * _coverExpandProgress;
    CGFloat performerX = 85.0f + (CGFloor((_controlsView.bounds.size.width - performerSize.width) / 2.0f) - 85.0f) * _coverExpandProgress;
    
    _titleLabel.frame = CGRectMake(titleX, titleOffset, titleSize.width, titleSize.height);
    _performerLabel.frame = CGRectMake(performerX, titleOffset + titleSize.height + 6.0f, performerSize.width, performerSize.height);
    
    _controlPauseButton.frame = _controlPlayButton.frame = CGRectMake(CGFloor((_controlsView.bounds.size.width - controlButtonSize) / 2.0f), controlButtonsOffset, controlButtonSize, controlButtonSize);
    _controlBackButton.frame = CGRectMake(CGFloor((_controlsView.bounds.size.width - controlButtonSpread) / 2.0f) - controlButtonSize, controlButtonsOffset, controlButtonSize, controlButtonSize);
    _controlForwardButton.frame = CGRectMake(CGFloor((_controlsView.bounds.size.width + controlButtonSpread) / 2.0f), controlButtonsOffset, controlButtonSize, controlButtonSize);
    
    CGSize modeButtonSize = CGSizeMake(28.0f, 21.0f);
    _controlShuffleButton.frame = CGRectMake(16.0f, _controlPlayButton.frame.origin.y + 19.0f, modeButtonSize.width, modeButtonSize.height);
    _controlRepeatButton.frame = CGRectMake(_controlsView.bounds.size.width - 44.0f, _controlShuffleButton.frame.origin.y, modeButtonSize.width, modeButtonSize.height);
    
    _actionsButton.frame = CGRectMake(_controlsView.bounds.size.width - 51.0f, titleOffset - 1.0f, 44.0f, 44.0f);
    
    _separator.frame = CGRectMake(0.0f, CGRectGetMaxY(_controlsView.frame), _containerView.bounds.size.width, TGScreenPixel);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!TGIsPad() && self.frame.size.width > self.frame.size.height)
        _coverExpandProgress = 0.0f;
    
    _dimView.frame = self.bounds;
    _containerView.frame = self.bounds;
    
    [self layoutControls];
    
    CGFloat screenWidth = TGIsPad() ? 414.0f : (self.frame.size.width - _safeAreaInset.left - _safeAreaInset.right);
    CGFloat collectonViewWidth = _collectionView.frame.size.width;
    _collectionView.frame = CGRectMake(floor((self.frame.size.width - screenWidth) / 2.0f), 0.0f, screenWidth, self.frame.size.height);
    
    if (fabs(collectonViewWidth - _collectionView.frame.size.width) > FLT_EPSILON)
        [_collectionView.collectionViewLayout invalidateLayout];
    
    [self layoutScrubbingIndicator];
}

- (UIButton *)actionsButton
{
    return _actionsButton;
}

@end


@implementation TGMusicPlayerCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self != nil)
    {
        _whiteTailView = [[UIView alloc] init];
        _whiteTailView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_whiteTailView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _whiteTailView.frame = CGRectMake(0.0f, self.contentSize.height, self.frame.size.width, 1000.0f);
}

- (BOOL)pointInside:(CGPoint)__unused point withEvent:(UIEvent *)__unused event
{
    return true;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view
{
    return true;
}

@end


@implementation TGMusicPlayerWrapperView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self)
        return nil;
    
    return result;
}

@end
