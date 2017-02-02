#import "TGMusicPlayerCompleteView.h"

#import "TGMusicPlayerScrubbingArea.h"

#import "TGImageUtils.h"
#import "TGImageBlur.h"
#import "TGFont.h"
#import "TGModernButton.h"
#import "TGMusicPlayerModeButton.h"

#import "TGMusicPlayer.h"
#import "TGTelegraph.h"
#import "TGImageView.h"

#import <pop/POP.h>

#import <MediaPlayer/MediaPlayer.h>

@interface TGMusicPlayerCompleteViewLayer : CALayer

@property (nonatomic) bool ignoreLayout;

@end

@implementation TGMusicPlayerCompleteViewLayer

- (void)setNeedsLayout
{
    if (!_ignoreLayout)
        [super setNeedsLayout];
}

@end

@interface TGMusicPlayerCompleteView ()
{
    UIView *_albumArtBackgroundView;
    UIImageView *_albumArtPlaceholderView;
    TGImageView *_albumArtImageView;
    UIImageView *_gradientView;
    
    UIView *_wrapperView;
    TGMusicPlayerScrubbingArea *_scrubbingArea;
    UIView *_scrubbingBackground;
    UIView *_playbackScrubbingForeground;
    UIView *_downloadingScrubbingForeground;
    UIImageView *_scrubbingHandle;
    
    UILabel *_titleLabel;
    UILabel *_performerLabel;
    TGModernButton *_controlBackButton;
    TGModernButton *_controlForwardButton;
    TGModernButton *_controlPlayButton;
    TGModernButton *_controlPauseButton;
    
    TGModernButton *_shareButton;
    TGMusicPlayerModeButton *_controlShuffleButton;
    TGMusicPlayerModeButton *_controlRepeatButton;
    TGModernButton *_playlistButton;
    
    TGModernButton *_dismissButton;
    
    UILabel *_positionLabel;
    int _positionLabelValue;
    UILabel *_durationLabel;
    int _durationLabelValue;
    
    int _progressLabelValueCurrent;
    int _progressLabelValueTotal;
    UILabel *_progressLabel;
    
    UIView *_volumeView;
    UIImageView *_volumeControlLeftIcon;
    UIImageView *_volumeControlRightIcon;
    
    bool _scrubbing;
    CGPoint _scrubbingReferencePoint;
    CGFloat _scrubbingReferenceOffset;
    CGFloat _scrubbingOffset;
    
    id<SDisposable> _playerStatusDisposable;
    
    TGMusicPlayerStatus *_currentStatus;
    NSString *_title;
    NSString *_performer;
    TGMusicPlayerItemPosition _currentItemPosition;
    
    CGFloat _playbackOffset;
    CGFloat _downloadProgress;
    
    bool _updateLabelsLayout;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@end

@implementation TGMusicPlayerCompleteView

+ (Class)layerClass
{
    return [TGMusicPlayerCompleteViewLayer class];
}

- (void)setIgnoreLayout:(bool)ignoreLayout
{
    ((TGMusicPlayerCompleteViewLayer *)self.layer).ignoreLayout = ignoreLayout;
}

- (bool)ignoreLayout
{
    return ((TGMusicPlayerCompleteViewLayer *)self.layer).ignoreLayout;
}

- (instancetype)initWithFrame:(CGRect)frame setTitle:(void (^)(NSString *))setTitle actionsEnabled:(void (^)(bool))actionsEnabled
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _setTitle = [setTitle copy];
        _actionsEnabled = [actionsEnabled copy];
        
        _albumArtBackgroundView = [[UIView alloc] init];
        _albumArtBackgroundView.backgroundColor = UIColorRGB(0xf0f0f4);
        [self addSubview:_albumArtBackgroundView];
        
        _albumArtPlaceholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MusicPlayerAlbumArtPlaceholder.png"]];
        [_albumArtBackgroundView addSubview:_albumArtPlaceholderView];
        
        _albumArtImageView = [[TGImageView alloc] init];
        [_albumArtBackgroundView addSubview:_albumArtImageView];
        
        _gradientView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MusicPlayerGradient"]];
        _gradientView.alpha = 0.0f;
        _gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _gradientView.frame = CGRectMake(0, 0, self.frame.size.width, _gradientView.frame.size.height);
        [_albumArtBackgroundView addSubview:_gradientView];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleArtTap:)];
        [_albumArtBackgroundView addGestureRecognizer:_tapGestureRecognizer];
        
        _wrapperView = [[UIView alloc] init];
        _wrapperView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_wrapperView];
        
        _scrubbingBackground = [[UIView alloc] init];
        _scrubbingBackground.backgroundColor = UIColorRGB(0xcccccc);
        [_wrapperView addSubview:_scrubbingBackground];
        
        _playbackScrubbingForeground = [[UIView alloc] init];
        _playbackScrubbingForeground.backgroundColor = TGAccentColor();
        [_wrapperView addSubview:_playbackScrubbingForeground];
        
        _downloadingScrubbingForeground = [[UIView alloc] init];
        _downloadingScrubbingForeground.backgroundColor = TGAccentColor();
        [_wrapperView addSubview:_downloadingScrubbingForeground];
        
        _scrubbingHandle = [[UIImageView alloc] initWithImage:[self handleImage]];
        [_wrapperView addSubview:_scrubbingHandle];
        
        _scrubbingArea = [[TGMusicPlayerScrubbingArea alloc] init];
        __weak TGMusicPlayerCompleteView *weakSelf = self;
        _scrubbingArea.didBeginDragging = ^(UITouch *touch)
        {
            __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf beginScrubbingAtPoint:[strongSelf scrubbingLocationForTouch:touch]];
        };
        _scrubbingArea.willMove = ^(UITouch *touch)
        {
            __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf continueScrubbingAtPoint:[strongSelf scrubbingLocationForTouch:touch]];
        };
        _scrubbingArea.didFinishDragging = ^
        {
            __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf finishScrubbing];
        };
        _scrubbingArea.didCancelDragging = ^
        {
            __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf cancelScrubbing];
        };
        [_wrapperView addSubview:_scrubbingArea];
        
        _positionLabel = [[UILabel alloc] init];
        _positionLabel.backgroundColor = [UIColor whiteColor];
        _positionLabel.textColor = UIColorRGB(0x474747);
        _positionLabel.font = TGSystemFontOfSize(12.0f);
        [_wrapperView addSubview:_positionLabel];
        _positionLabelValue = INT_MIN;
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor whiteColor];
        _durationLabel.textColor = UIColorRGB(0x474747);
        _durationLabel.font = TGSystemFontOfSize(12.0f);
        [_wrapperView addSubview:_durationLabel];
        _durationLabelValue = INT_MIN;
        
        static UIImage *minimumTrackImage = nil;
        static UIImage *maximumTrackImage = nil;
        static UIImage *dismissBackImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(4.0f, 2.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, UIColorRGB(0x7f7f7f).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 2.0f, 2.0f));
                CGContextFillEllipseInRect(context, CGRectMake(2.0f, 0.0f, 2.0f, 2.0f));
                CGContextFillRect(context, CGRectMake(1.0f, 0.0f, 2.0f, 2.0f));
                minimumTrackImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:2.0f topCapHeight:0.0f];
                UIGraphicsEndImageContext();
            }
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(4.0f, 2.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, UIColorRGB(0xd0d0d0).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 2.0f, 2.0f));
                CGContextFillEllipseInRect(context, CGRectMake(2.0f, 0.0f, 2.0f, 2.0f));
                CGContextFillRect(context, CGRectMake(1.0f, 0.0f, 2.0f, 2.0f));
                maximumTrackImage = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:2.0f topCapHeight:0.0f];
                UIGraphicsEndImageContext();
            }
            {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(24.0f, 24.0f), false, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetFillColorWithColor(context, UIColorRGB(0xd0d0d0).CGColor);
                CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 24.0f, 24.0f));
                dismissBackImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        });
        
        CGFloat titleFontSize = 16.0f + TGRetinaPixel;
        CGFloat performerFontSize = 12.0f;
        switch ([self interfaceType])
        {
            case TGMusicPlayerInterfaceExtraLarge:
                titleFontSize = 19.0f;
                performerFontSize = 13.0f;
                break;
            default:
                break;
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(titleFontSize);
        [_wrapperView addSubview:_titleLabel];
        
        _performerLabel = [[UILabel alloc] init];
        _performerLabel.backgroundColor = [UIColor whiteColor];
        _performerLabel.textColor = UIColorRGB(0x474747);
        _performerLabel.font = TGSystemFontOfSize(performerFontSize);
        [_wrapperView addSubview:_performerLabel];

        _controlPlayButton = [[TGModernButton alloc] init];
        [_controlPlayButton setImage:[UIImage imageNamed:@"MusicPlayerControlPlay.png"] forState:UIControlStateNormal];
        [_controlPlayButton setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
        [_controlPlayButton addTarget:self action:@selector(controlPlay) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlPlayButton];
        
        _controlPauseButton = [[TGModernButton alloc] init];
        [_controlPauseButton setImage:[UIImage imageNamed:@"MusicPlayerControlPause.png"] forState:UIControlStateNormal];
        [_controlPauseButton addTarget:self action:@selector(controlPause) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlPauseButton];
        
        _controlBackButton = [[TGModernButton alloc] init];
        [_controlBackButton setImage:[UIImage imageNamed:@"MusicPlayerControlBack.png"] forState:UIControlStateNormal];
        [_controlBackButton addTarget:self action:@selector(controlBack) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlBackButton];
        
        _controlForwardButton = [[TGModernButton alloc] init];
        [_controlForwardButton setImage:[UIImage imageNamed:@"MusicPlayerControlForward.png"] forState:UIControlStateNormal];
        [_controlForwardButton addTarget:self action:@selector(controlForward) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlForwardButton];
        
        _shareButton = [[TGModernButton alloc] init];
        [_shareButton setImage:[UIImage imageNamed:@"MusicPlayerShare.png"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_shareButton];
        
        _controlShuffleButton = [[TGMusicPlayerModeButton alloc] init];
        [_controlShuffleButton setImage:[UIImage imageNamed:@"MusicPlayerControlShuffle.png"] forState:UIControlStateNormal];
        [_controlShuffleButton addTarget:self action:@selector(controlShuffle) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlShuffleButton];
        
        _controlRepeatButton = [[TGMusicPlayerModeButton alloc] init];
        [_controlRepeatButton setImage:[UIImage imageNamed:@"MusicPlayerControlRepeat.png"] forState:UIControlStateNormal];
        [_controlRepeatButton addTarget:self action:@selector(controlRepeat) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_controlRepeatButton];
        
        _playlistButton = [[TGModernButton alloc] init];
        [_playlistButton setImage:[UIImage imageNamed:@"MusicPlayerPlaylist.png"] forState:UIControlStateNormal];
        [_playlistButton addTarget:self action:@selector(playlistButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_wrapperView addSubview:_playlistButton];
        
        if (!TGIsPad())
        {
            _dismissButton = [[TGModernButton alloc] init];
            [_dismissButton setBackgroundImage:dismissBackImage forState:UIControlStateNormal];
            [_dismissButton setImage:[UIImage imageNamed:@"MusicPlayerDismiss.png"] forState:UIControlStateNormal];
            [_dismissButton addTarget:self action:@selector(dismissButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_dismissButton];
        }
        
#if TARGET_IPHONE_SIMULATOR
        UISlider *sliderView = [[UISlider alloc] init];
        [sliderView setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
        [sliderView setMaximumTrackImage:maximumTrackImage forState:UIControlStateNormal];
        [sliderView setThumbImage:[UIImage imageNamed:@"VolumeControlSliderButton.png"] forState:UIControlStateNormal];
        [sliderView setValue:0.5f];
        _volumeView = sliderView;
        
#else
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        [volumeView setMinimumVolumeSliderImage:minimumTrackImage forState:UIControlStateNormal];
        [volumeView setMaximumVolumeSliderImage:maximumTrackImage forState:UIControlStateNormal];
        [volumeView setVolumeThumbImage:[UIImage imageNamed:@"VolumeControlSliderButton.png"] forState:UIControlStateNormal];
        volumeView.showsRouteButton = false;
        _volumeView = volumeView;
#endif
        [_wrapperView addSubview:_volumeView];
        
        _volumeControlLeftIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VolumeControlVolumeIcon.png"]];
        [_wrapperView addSubview:_volumeControlLeftIcon];
        _volumeControlRightIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VolumeControlVolumeUpIcon.png"]];
        [_wrapperView addSubview:_volumeControlRightIcon];
        
        _currentItemPosition = (TGMusicPlayerItemPosition){.index = 0, .count = -1};
        
        _playerStatusDisposable = [[TGTelegraphInstance.musicPlayer playingStatus] startWithNext:^(TGMusicPlayerStatus *status)
        {
            __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf setStatus:status];
        }];
        
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
    _updateLabelsLayout = ABS(self.frame.size.width - frame.size.width) > FLT_EPSILON;
    [super setFrame:frame];
    
    if (_updateLabelsLayout)
        [self setNeedsLayout];
}

- (CGPoint)scrubbingLocationForTouch:(UITouch *)touch
{
    return [touch locationInView:_scrubbingArea];
}

- (void)beginScrubbingAtPoint:(CGPoint)point
{
    _scrubbing = true;
    _scrubbingReferencePoint = point;
    _scrubbingOffset = _playbackOffset;
    _scrubbingReferenceOffset = _playbackOffset;
    [TGTelegraphInstance.musicPlayer controlPause];
}

- (void)continueScrubbingAtPoint:(CGPoint)point
{
    if (_scrubbingArea.frame.size.width > FLT_EPSILON)
    {
        _scrubbingOffset = MAX(0.0f, MIN(1.0f, _scrubbingReferenceOffset + (point.x - _scrubbingReferencePoint.x) / _scrubbingArea.frame.size.width));
        [self layoutScrubbingIndicator];
    }
}

- (void)finishScrubbing
{
    [TGTelegraphInstance.musicPlayer controlSeekToPosition:_scrubbingOffset];
    [TGTelegraphInstance.musicPlayer controlPlay];
    
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

- (void)setTopInset:(CGFloat)topInset
{
    _topInset = topInset;
    [self setNeedsLayout];
}

- (CGFloat)progressHeight
{
    return 4.0f;
}

- (CGSize)handleSize
{
    return CGSizeMake(2.0f, 16.0f);
}

- (UIImage *)handleImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0f, 4.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 2.0f, 2.0f, 2.0f));
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 2.0f, 3.0f));
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:0.0f topCapHeight:1.0f];
        UIGraphicsEndImageContext();
    });
    return image;
}

typedef enum {
    TGMusicPlayerInterfaceCompact = 0,
    TGMusicPlayerInterfaceMedium = 1,
    TGMusicPlayerInterfaceLarge = 2,
    TGMusicPlayerInterfaceExtraLarge = 3,
    TGMusicPlayerInterfacePad = 4
} TGMusicPlayerInterfaceType;

- (TGMusicPlayerInterfaceType)interfaceType
{
    CGSize screenSize = self.bounds.size;
    CGFloat screenHeight = MAX(screenSize.width, screenSize.height);
    
    if (fabs(667.0f - screenHeight) < FLT_EPSILON && TGIsPad())
        return TGMusicPlayerInterfacePad;
    if (screenHeight > 667.0f + FLT_EPSILON)
        return TGMusicPlayerInterfaceExtraLarge;
    else if (screenHeight > 568.0f + FLT_EPSILON)
        return TGMusicPlayerInterfaceLarge;
    else if (screenHeight > 480.0f + FLT_EPSILON)
        return TGMusicPlayerInterfaceMedium;
    else
        return TGMusicPlayerInterfaceCompact;
}

- (void)layoutScrubbingIndicator
{
    bool ignoreLayout = [self ignoreLayout];
    [self setIgnoreLayout:true];
    
    CGFloat displayOffset = _scrubbing ? _scrubbingOffset : _playbackOffset;
    
    CGFloat progressHeight = [self progressHeight];
    CGSize handleSize = [self handleSize];
    
    CGFloat side = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat handleOriginX = TGScreenPixelFloor((side - handleSize.width) * displayOffset);
    _playbackScrubbingForeground.frame = CGRectMake(0.0f, 0.0f, handleOriginX, progressHeight);
    _downloadingScrubbingForeground.frame = CGRectMake(0.0f, 0.0f, _downloadProgress * side, progressHeight);
    _scrubbingHandle.frame = CGRectMake(handleOriginX, 0.0f, handleSize.width, handleSize.height);
    
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
        _positionLabel.frame = CGRectMake(11.0f + TGRetinaPixel, 17.0f - TGRetinaPixel, _positionLabel.frame.size.width, _positionLabel.frame.size.height);
    }
    
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
        _durationLabel.frame = CGRectMake(side - 11.0f - TGRetinaPixel - _durationLabel.frame.size.width, 17.0f - TGRetinaPixel, _durationLabel.frame.size.width, _durationLabel.frame.size.height);
    }
    
    [self setIgnoreLayout:ignoreLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat side = MIN(self.frame.size.width, self.frame.size.height);
    side = MIN(side, 414.0f);
    CGFloat scrubbingHeight = 32.0f;
    CGFloat progressHeight = [self progressHeight];
    
    CGFloat albumArtHeight = side;
    CGSize albumArtImageSize = CGSizeZero;
    
    switch ([self interfaceType])
    {
        case TGMusicPlayerInterfaceCompact:
            albumArtHeight = 280.0f;
            albumArtImageSize = CGSizeMake(200.0f, 200.0f);
            break;
        default:
            albumArtHeight = side;
            albumArtImageSize = CGSizeMake(side, side);
            break;
    }
    
    _albumArtBackgroundView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, albumArtHeight + _topInset);
    CGSize filledSize = TGScaleToFill(albumArtImageSize, _albumArtBackgroundView.frame.size);
    _albumArtImageView.frame = CGRectMake(CGFloor((self.frame.size.width - filledSize.width) / 2.0f), _topInset + CGFloor((albumArtHeight - filledSize.height) / 2.0f), filledSize.width, filledSize.height);
    _albumArtPlaceholderView.frame = CGRectMake(CGFloor((self.frame.size.width - _albumArtPlaceholderView.frame.size.width) / 2.0f) - 8.0f, _topInset + CGFloor((albumArtHeight - _albumArtPlaceholderView.frame.size.height) / 2.0f), _albumArtPlaceholderView.frame.size.width, _albumArtPlaceholderView.frame.size.height);
    
    CGFloat albumArtEdge = CGRectGetMaxY(_albumArtBackgroundView.frame);
    
    _wrapperView.frame = CGRectMake(0, albumArtEdge, self.frame.size.width, self.frame.size.height - albumArtEdge);
    
    _scrubbingArea.frame = CGRectMake(0.0f, progressHeight / 2.0f - scrubbingHeight / 2.0f, _wrapperView.bounds.size.width, scrubbingHeight);
    _scrubbingBackground.frame = CGRectMake(0.0f, 0, _wrapperView.bounds.size.width, progressHeight);
    
    CGFloat titleOffset = albumArtEdge + 31.0f;
    CGFloat controlButtonsOffset = albumArtEdge + 76.0f;
    CGFloat controlButtonSize = 60.0f;
    CGFloat controlButtonSpread = 110.0f;
    CGFloat volumeControlBottomOffset = 58.0f;
    CGFloat volumeControlSideInset = 47.0f;
    CGFloat volumeControlOffset = 0.0f;
#if TARGET_IPHONE_SIMULATOR
#else
    volumeControlOffset = 16.0f;
#endif
    
    switch ([self interfaceType])
    {
        case TGMusicPlayerInterfaceCompact:
            titleOffset = 30.0f;
            controlButtonsOffset = 74;
            volumeControlBottomOffset = 78.0f;
            break;
        case TGMusicPlayerInterfaceMedium:
            titleOffset = 31.0f;
            controlButtonsOffset = 88.0f;
            volumeControlBottomOffset = 98.0f;
            break;
        case TGMusicPlayerInterfaceLarge:
            titleOffset = 51.0f;
            controlButtonsOffset = 116.0f;
            volumeControlBottomOffset = 102.0f;
            volumeControlSideInset = 76.0f;
            break;
        case TGMusicPlayerInterfaceExtraLarge:
            titleOffset = 59.0f;
            controlButtonsOffset = 120.0f;
            volumeControlBottomOffset = 122.0f;
            volumeControlSideInset = 86.0f;
            break;
        case TGMusicPlayerInterfacePad:
            titleOffset = 51.0f;
            controlButtonsOffset = 96.0f;
            volumeControlBottomOffset = 59.0f;
            volumeControlSideInset = 76.0f;
            break;
    }
    
    CGSize titleSize = _titleLabel.frame.size;
    CGSize performerSize = _performerLabel.frame.size;
    
    if (self.preview)
        titleOffset = 19.0f;
    
    if (_updateLabelsLayout)
    {
        _updateLabelsLayout = false;
        titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font];
        performerSize = [_performerLabel.text sizeWithFont:_performerLabel.font];
        CGFloat maxWidth = _wrapperView.bounds.size.width - 32.0f;
        if (self.preview)
            maxWidth -= 80;
        titleSize.width = MIN(titleSize.width, maxWidth);
        performerSize.width = MIN(performerSize.width, maxWidth);
    }
    
    _titleLabel.frame = CGRectMake(CGFloor((_wrapperView.bounds.size.width - titleSize.width) / 2.0f), titleOffset + TGRetinaPixel, titleSize.width, titleSize.height);
    _performerLabel.frame = CGRectMake(CGFloor((_wrapperView.bounds.size.width - performerSize.width) / 2.0f), titleOffset + titleSize.height + 6.0f, performerSize.width, performerSize.height);
    
    _controlPauseButton.frame = _controlPlayButton.frame = CGRectMake(CGFloor((_wrapperView.bounds.size.width - controlButtonSize) / 2.0f), controlButtonsOffset, controlButtonSize, controlButtonSize);
    _controlBackButton.frame = CGRectMake(CGFloor((_wrapperView.bounds.size.width - controlButtonSpread) / 2.0f) - controlButtonSize, controlButtonsOffset, controlButtonSize, controlButtonSize);
    _controlForwardButton.frame = CGRectMake(CGFloor((_wrapperView.bounds.size.width + controlButtonSpread) / 2.0f), controlButtonsOffset, controlButtonSize, controlButtonSize);
    
    CGSize modeButtonSize = CGSizeMake(28.0f, 21.0f);
    
    if ([self interfaceType] == TGMusicPlayerInterfacePad)
    {
        _controlShuffleButton.frame = CGRectMake(16.0f, _controlPlayButton.frame.origin.y + 19.0f, modeButtonSize.width, modeButtonSize.height);
        _controlRepeatButton.frame = CGRectMake(_wrapperView.bounds.size.width - 44.0f, _controlShuffleButton.frame.origin.y, modeButtonSize.width, modeButtonSize.height);
    }
    else
    {
        CGFloat segment = _wrapperView.frame.size.width / 3.0f;
        CGFloat yOffset = -10.0f;
        _shareButton.frame = CGRectMake(8.0f, _wrapperView.frame.size.height - modeButtonSize.height + yOffset, modeButtonSize.width, modeButtonSize.height);
        _controlShuffleButton.frame = CGRectMake(8.0f + ceil(segment - modeButtonSize.width / 2.0f), _wrapperView.frame.size.height - modeButtonSize.height + yOffset, modeButtonSize.width, modeButtonSize.height);
        _controlRepeatButton.frame = CGRectMake(-8.0f + ceil(_wrapperView.frame.size.width - segment - modeButtonSize.width / 2.0f), _controlShuffleButton.frame.origin.y, modeButtonSize.width, modeButtonSize.height);
        _playlistButton.frame = CGRectMake(-8.0f + _wrapperView.frame.size.width - modeButtonSize.width, _wrapperView.frame.size.height - modeButtonSize.height + yOffset, modeButtonSize.width, modeButtonSize.height);
    }
    
    _dismissButton.frame = CGRectMake(12.0f, 28.0f, 24.0f, 24.0f);
    
    [UIView performWithoutAnimation:^
    {
        _volumeView.frame = CGRectMake(volumeControlSideInset, _wrapperView.frame.size.height - volumeControlBottomOffset + volumeControlOffset, _wrapperView.bounds.size.width - volumeControlSideInset * 2.0f, 50.0f);
    }];
    _volumeControlLeftIcon.frame = CGRectMake(_volumeView.frame.origin.x - 16.0f, _volumeView.frame.origin.y + 20.0f - volumeControlOffset, _volumeControlLeftIcon.frame.size.width, _volumeControlLeftIcon.frame.size.height);
    _volumeControlRightIcon.frame = CGRectMake(CGRectGetMaxX(_volumeView.frame) + 8.0f, _volumeView.frame.origin.y + 18.0f - volumeControlOffset, _volumeControlRightIcon.frame.size.width, _volumeControlRightIcon.frame.size.height);
    
    [self layoutScrubbingIndicator];
}

- (void)setStatus:(TGMusicPlayerStatus *)status
{
    TGMusicPlayerStatus *previousStatus = _currentStatus;
    _currentStatus = status;
    
    if (_currentItemPosition.index != status.position.index || _currentItemPosition.count != status.position.count)
    {
        _currentItemPosition = status.position;
        NSString *title = [[NSString alloc] initWithFormat:@"%d %@ %d", (int)_currentItemPosition.index + 1, TGLocalized(@"Common.of"), (int)_currentItemPosition.count];
        if (_setTitle)
            _setTitle(title);
    }
    
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
    }
    
    if (status.albumArtSync != previousStatus.albumArtSync)
    {
        [_albumArtImageView reset];
        if (status.albumArtSync != nil)
        {
            _albumArtImageView.contentMode = UIViewContentModeScaleAspectFill;
            __weak TGMusicPlayerCompleteView *weakSelf = self;
            [_albumArtImageView setSignal:[[[status.albumArtSync deliverOn:[SQueue mainQueue]] onNext:^(id next)
            {
                __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
                if (![next isKindOfClass:[UIImage class]] || strongSelf == nil || strongSelf.statusBarStyleChange == nil)
                    return;
                
                [[SQueue concurrentDefaultQueue] dispatch:^
                {
                    bool isDark = [strongSelf isDarkAlbumArtwork:next];
                    [[SQueue mainQueue] dispatch:^
                    {
                        strongSelf.statusBarStyleChange(isDark);
                    }];
                }];
            }] onError:^(__unused id error)
            {
                __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
                if (strongSelf != nil && strongSelf.statusBarStyleChange != nil)
                    strongSelf.statusBarStyleChange(false);
            }]];
        }
        else
        {
            if (self.statusBarStyleChange != nil)
                self.statusBarStyleChange(false);
        }
    }
    
    _controlPlayButton.hidden = !status.paused;
    _controlPauseButton.hidden = status.paused;
    
    _controlShuffleButton.selected = status.shuffle;
    if (status.repeatType != previousStatus.repeatType)
    {
        switch (status.repeatType)
        {
            case TGMusicPlayerRepeatTypeNone:
                [_controlRepeatButton setImage:[UIImage imageNamed:@"MusicPlayerControlRepeat.png"] forState:UIControlStateNormal];
                _controlRepeatButton.selected = false;
                break;
                
            case TGMusicPlayerRepeatTypeAll:
                [_controlRepeatButton setImage:[UIImage imageNamed:@"MusicPlayerControlRepeat.png"] forState:UIControlStateNormal];
                _controlRepeatButton.selected = true;
                break;
                
            case TGMusicPlayerRepeatTypeOne:
                [_controlRepeatButton setImage:[UIImage imageNamed:@"MusicPlayerControlRepeatOne.png"] forState:UIControlStateNormal];
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
        
        _shareButton.enabled = buttonsEnabled;
        _shareButton.alpha = buttonsEnabled ? 1.0f : disabledAlpha;
        
        if (_actionsEnabled) {
            _actionsEnabled(buttonsEnabled);
        }
    }
    
    static POPAnimatableProperty *playbackOffsetProperty = nil;
    static POPAnimatableProperty *downloadProgressProperty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        playbackOffsetProperty = [POPAnimatableProperty propertyWithName:@"playbackOffset" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGMusicPlayerCompleteView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_playbackOffset;
            };
            
            prop.writeBlock = ^(TGMusicPlayerCompleteView *strongSelf, CGFloat const *values)
            {
                strongSelf->_playbackOffset = values[0];
                if (!strongSelf->_scrubbing)
                    [strongSelf layoutScrubbingIndicator];
            };
        }];
        
        downloadProgressProperty = [POPAnimatableProperty propertyWithName:@"downloadProgress" initializer:^(POPMutableAnimatableProperty *prop)
        {
            prop.readBlock = ^(TGMusicPlayerCompleteView *strongSelf, CGFloat *values)
            {
                values[0] = strongSelf->_downloadProgress;
            };
            
            prop.writeBlock = ^(TGMusicPlayerCompleteView *strongSelf, CGFloat const *values)
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
                    
                    __weak TGMusicPlayerCompleteView *weakSelf = self;
                    animation.completionBlock = ^(__unused POPAnimation *animation, BOOL finished)
                    {
                        if (finished)
                        {
                            __strong TGMusicPlayerCompleteView *strongSelf = weakSelf;
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

- (bool)isDarkAlbumArtwork:(UIImage *)image
{
    if (image == nil)
        return false;
    
    
    CGSize imageSize = image.size;
    CGFloat edge = imageSize.height * 20.0f / self.frame.size.height;
    CGSize topEdgeSize = CGSizeMake(image.size.width, floor(MIN(imageSize.height, edge)));
    CGSize scaledSize = TGScaleToFill(topEdgeSize, CGSizeMake(10.0f, 10.0f));
    
    UIImage *topEdge = TGFixOrientationAndCrop(image, CGRectMake(0, 0, topEdgeSize.width, topEdgeSize.height), scaledSize);
    
    uint32_t colorValue;
    TGPlainImageAverageColor(topEdge, &colorValue);
    
    UIColor *averageColor = UIColorRGB(colorValue);
    const CGFloat *RGB = CGColorGetComponents(averageColor.CGColor);
    
    return ((0.2126f * RGB[0] + 0.7152f * RGB[1] + 0.0722f * RGB[2]) < 0.5f);
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

- (void)controlShuffle
{
    [TGTelegraphInstance.musicPlayer controlShuffle];
}

- (void)controlRepeat
{
    [TGTelegraphInstance.musicPlayer controlRepeat];
}

- (void)shareButtonPressed
{
    if (self.actionsPressed != nil)
        self.actionsPressed();
}

- (void)playlistButtonPressed
{
    if (self.playlistPressed != nil)
        self.playlistPressed();
}

- (void)dismissButtonPressed
{
    if (self.dismissPressed != nil)
        self.dismissPressed();
}

- (void)dismissToRect:(CGRect)__unused rect completion:(void (^)(void))completion
{
    self.backgroundColor = [UIColor clearColor];
    
    _albumArtBackgroundView.backgroundColor = [UIColor clearColor];
    _albumArtPlaceholderView.hidden = true;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 animations:^
    {
        _wrapperView.frame = CGRectOffset(_wrapperView.frame, 0, _wrapperView.frame.size.height);
        _albumArtImageView.frame = CGRectMake(10, 149, 42, 42);
    } completion:^(__unused BOOL finished)
    {
       if (completion != nil)
           completion();
    }];
}

- (void)handleArtTap:(UITapGestureRecognizer *)__unused gestureRecognizer
{
    if (!self.preview)
        return;
    
    if (_currentStatus.paused)
        [self controlPlay];
    else
        [self controlPause];
}

- (bool)isSwipeGestureAllowedAtPoint:(CGPoint)point
{
    return !CGRectContainsPoint(CGRectInset([_scrubbingArea.superview convertRect:_scrubbingArea.frame toView:self], -20, -10), point);
}

- (void)setPreview:(bool)preview
{
    _preview = preview;
    _dismissButton.hidden = preview;
}

- (void)setGradientAlpha:(CGFloat)alpha
{
    _gradientView.alpha = alpha;
}

@end
