#import "TGInstantPageAudioView.h"

#import <SSignalKit/SSignalKit.h>

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGDocumentMediaAttachment.h"

#import "TGModernButton.h"

#import "TGMusicPlayer.h"
#import "TGTelegraph.h"

#import "TGMusicPlayerScrubbingArea.h"

#import <pop/POP.h>

#import "TGMusicPlayerItem.h"

#import "TGGenericPeerPlaylistSignals.h"

static UIImage *generatePlayButton(UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.65f);
    TGDrawSvgPath(context, @"M24,0.825 C11.2008009,0.825 0.825,11.2008009 0.825,24 C0.825,36.7991991 11.2008009,47.175 24,47.175 C36.7991991,47.175 47.175,36.7991991 47.175,24 C47.175,11.2008009 36.7991991,0.825 24,0.825 S");
    
    TGDrawSvgPath(context, @"M19,16.8681954 L19,32.1318046 L19,32.1318046 C19,32.6785665 19.4432381,33.1218046 19.99,33.1218046 C20.1882157,33.1218046 20.3818677,33.0623041 20.5458864,32.9510057 L31.7927564,25.319201 L31.7927564,25.319201 C32.2451886,25.0121934 32.3630786,24.3965458 32.056071,23.9441136 C31.9857457,23.8404762 31.8963938,23.7511243 31.7927564,23.680799 L20.5458864,16.0489943 L20.5458864,16.0489943 C20.0934542,15.7419868 19.4778066,15.8598767 19.170799,16.312309 C19.0595006,16.4763277 19,16.6699796 19,16.8681954 Z");
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIImage *generatePauseButton(UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(48.0f, 48.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.65f);
    TGDrawSvgPath(context, @"M24,0.825 C11.2008009,0.825 0.825,11.2008009 0.825,24 C0.825,36.7991991 11.2008009,47.175 24,47.175 C36.7991991,47.175 47.175,36.7991991 47.175,24 C47.175,11.2008009 36.7991991,0.825 24,0.825 S");
    
    TGDrawSvgPath(context, @"M17,16 L21,16 C21.5567619,16 22,16.4521029 22,17 L22,32 C22,32.5478971 21.5567619,33 21,33 L17,33 C16.4432381,33 16,32.5478971 16,32 L16,17 C16,16.4521029 16.4432381,16 17,16 Z");
    TGDrawSvgPath(context, @"M26.99,16 L31.01,16 C31.5567619,16 32,16.4432381 32,16.99 L32,32.01 C32,32.5567619 31.5567619,33 31.01,33 L26.99,33 C26.4432381,33 26,32.5567619 26,32.01 L26,16.99 C26,16.4432381 26.4432381,16 26.99,16 Z");
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@interface TGInstantPageAudioView () {
    TGInstantPagePresentation *_presentation;
    
    int32_t _duration;
    
    UILabel *_titleLabel;
    
    UIImage *_playImage;
    UIImage *_pauseImage;
    TGModernButton *_playPauseButton;
    
    id<SDisposable> _statusDisposable;
    TGMusicPlayerStatus *_currentStatus;
    
    TGMusicPlayerScrubbingArea *_scrubbingArea;
    UIView *_scrubbingBackground;
    UIView *_playbackScrubbingForeground;
    UIView *_downloadingScrubbingForeground;
    UIImageView *_scrubbingHandle;
    
    UILabel *_positionLabel;
    
    bool _ignoreLayout;
    int32_t _positionLabelValue;
    
    bool _scrubbing;
    CGPoint _scrubbingReferencePoint;
    CGFloat _scrubbingOffset;
    CGFloat _scrubbingReferenceOffset;
    CGFloat _playbackOffset;
    CGFloat _downloadProgress;
    
    void (^_openAudio)(TGDocumentMediaAttachment *);
}

@end

@implementation TGInstantPageAudioView

- (NSAttributedString *)titleAttributedStringForDocument:(TGDocumentMediaAttachment *)document presentation:(TGInstantPagePresentation *)presentation {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    
    NSString *artist = @"";
    NSString *title = @"";
    bool isVoice = false;
    for (id attribute in document.attributes) {
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
            isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
            if (!isVoice) {
                artist = ((TGDocumentAttributeAudio *)attribute).performer;
                title = ((TGDocumentAttributeAudio *)attribute).title;
            }
        }
    }
    
    if (isVoice) {
    } else if (artist.length != 0 && title.length != 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:artist attributes:@{NSForegroundColorAttributeName: presentation.textColor, NSFontAttributeName: TGSemiboldSystemFontOfSize(17.0f)}]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" — " attributes:@{NSForegroundColorAttributeName: presentation.textColor, NSFontAttributeName: TGSystemFontOfSize(17.0f)}]];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: presentation.textColor, NSFontAttributeName: TGSystemFontOfSize(17.0f)}]];
    } else if (artist.length != 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:artist attributes:@{NSForegroundColorAttributeName: presentation.textColor, NSFontAttributeName: TGSemiboldSystemFontOfSize(17.0f)}]];
    } else if (title.length != 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: presentation.textColor, NSFontAttributeName: TGSystemFontOfSize(17.0f)}]];
    }
    return text;
}

- (UIImage *)handleImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(8.0f, 8.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 8.0f, 8.0f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (instancetype)initWithFrame:(CGRect)frame document:(TGDocumentMediaAttachment *)document presentation:(TGInstantPagePresentation *)presentation {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _document = document;
        _presentation = presentation;
        
        for (id attribute in document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                _duration = ((TGDocumentAttributeAudio *)attribute).duration;
            }
        }
        
        _positionLabelValue = -1;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17.0f);
        _titleLabel.attributedText = [self titleAttributedStringForDocument:_document presentation:_presentation];
        [self addSubview:_titleLabel];
        
        _positionLabel = [[UILabel alloc] init];
        _positionLabel.backgroundColor = [UIColor clearColor];
        _positionLabel.font = TGSystemFontOfSize(13.0f);
        _positionLabel.textColor = _presentation.textColor;
        [self addSubview:_positionLabel];
        
        _playPauseButton = [[TGModernButton alloc] init];
        _playImage = generatePlayButton(_presentation.textColor);
        _pauseImage = generatePauseButton(_presentation.textColor);
        [_playPauseButton setImage:_playImage forState:UIControlStateNormal];
        [_playPauseButton addTarget:self action:@selector(playPauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playPauseButton];
        
        _scrubbingBackground = [[UIView alloc] init];
        CGFloat backgroundAlpha = 0.1f;
        CGFloat brightness = 0.0f;
        [_presentation.textColor getHue:nil saturation:nil brightness:&brightness alpha:nil];
        if (brightness > 0.5f) {
            backgroundAlpha = 0.4f;
        }
        _scrubbingBackground.backgroundColor = [_presentation.textColor colorWithAlphaComponent:backgroundAlpha];
        [self addSubview:_scrubbingBackground];
        
        _playbackScrubbingForeground = [[UIView alloc] init];
        _playbackScrubbingForeground.backgroundColor = _presentation.textColor;
        [self addSubview:_playbackScrubbingForeground];
        
        _downloadingScrubbingForeground = [[UIView alloc] init];
        _downloadingScrubbingForeground.backgroundColor = _presentation.textColor;
        [self addSubview:_downloadingScrubbingForeground];
        
        _scrubbingHandle = [[UIImageView alloc] initWithImage:[self handleImageWithColor:_presentation.textColor]];
        _scrubbingHandle.hidden = true;
        [self addSubview:_scrubbingHandle];
        
        __weak TGInstantPageAudioView *weakSelf = self;
        
        _scrubbingArea = [[TGMusicPlayerScrubbingArea alloc] init];
        _scrubbingArea.userInteractionEnabled = false;
        _scrubbingArea.didBeginDragging = ^(UITouch *touch)
        {
            __strong TGInstantPageAudioView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf beginScrubbingAtPoint:[strongSelf scrubbingLocationForTouch:touch]];
            }
        };
        _scrubbingArea.willMove = ^(UITouch *touch)
        {
            __strong TGInstantPageAudioView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf continueScrubbingAtPoint:[strongSelf scrubbingLocationForTouch:touch]];
            }
        };
        _scrubbingArea.didFinishDragging = ^
        {
            __strong TGInstantPageAudioView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf finishScrubbing];
            }
        };
        _scrubbingArea.didCancelDragging = ^
        {
            __strong TGInstantPageAudioView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf cancelScrubbing];
            }
        };
        [self addSubview:_scrubbingArea];
        
        [self updatePresentation:presentation];
        
        _statusDisposable = [[[TGTelegraphInstance.musicPlayer playingStatus] deliverOn:[SQueue mainQueue]] startWithNext:^(TGMusicPlayerStatus *status) {
            __strong TGInstantPageAudioView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([status.item.media isKindOfClass:[TGDocumentMediaAttachment class]]) {
                    TGMusicPlayerStatus *itemStatus = nil;
                    if (((TGDocumentMediaAttachment *)status.item.media).documentId == document.documentId) {
                        itemStatus = status;
                    }
                    [strongSelf updateStatus:itemStatus];
                }
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_statusDisposable dispose];
}

- (void)updatePresentation:(TGInstantPagePresentation *)presentation {
    if ([presentation isEqual:_presentation]) {
        return;
    }
    
    _presentation = presentation;
    
    _titleLabel.attributedText = [self titleAttributedStringForDocument:_document presentation:_presentation];
    
    _playImage = generatePlayButton(_presentation.textColor);
    _pauseImage = generatePauseButton(_presentation.textColor);
    if (_currentStatus != nil && !_currentStatus.paused) {
        [_playPauseButton setImage:_pauseImage forState:UIControlStateNormal];
    } else {
        [_playPauseButton setImage:_playImage forState:UIControlStateNormal];
    }
    
    _positionLabel.textColor = _presentation.textColor;
    CGFloat backgroundAlpha = 0.1f;
    CGFloat brightness = 0.0f;
    [_presentation.textColor getHue:nil saturation:nil brightness:&brightness alpha:nil];
    if (brightness > 0.5f) {
        backgroundAlpha = 0.4f;
    }
    _scrubbingBackground.backgroundColor = [_presentation.textColor colorWithAlphaComponent:backgroundAlpha];
    _playbackScrubbingForeground.backgroundColor = _presentation.textColor;
    _downloadingScrubbingForeground.backgroundColor = _presentation.textColor;
    _scrubbingHandle.image = [self handleImageWithColor:_presentation.textColor];
    
    [self setNeedsLayout];
}

- (void)setIsVisible:(bool)__unused isVisible {
}

+ (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(18.0f, 17.0f, 18.0f, 17.0f);
}

+ (CGFloat)height {
    return 48.0f;
}

- (void)updateStatus:(TGMusicPlayerStatus *)status {
    if (status != _currentStatus) {
        _scrubbingArea.userInteractionEnabled = _currentStatus != nil;
        
        TGMusicPlayerStatus *previousStatus = _currentStatus;
        bool wasPlaying = _currentStatus != nil && !_currentStatus.paused;
        bool isPlaying = status != nil && !status.paused;
        _currentStatus = status;
        
        if (wasPlaying != isPlaying) {
            if (isPlaying) {
                [_playPauseButton setImage:_pauseImage forState:UIControlStateNormal];
            } else {
                [_playPauseButton setImage:_playImage forState:UIControlStateNormal];
            }
        }
        
        _scrubbingHandle.hidden = _currentStatus == nil || !status.downloadedStatus.downloaded;
        
        __weak TGInstantPageAudioView *weakSelf = self;
        
        static POPAnimatableProperty *playbackOffsetProperty = nil;
        static POPAnimatableProperty *downloadProgressProperty = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^ {
            playbackOffsetProperty = [POPAnimatableProperty propertyWithName:@"playbackOffset" initializer:^(POPMutableAnimatableProperty *prop)
            {
                prop.readBlock = ^(TGInstantPageAudioView *strongSelf, CGFloat *values)
                {
                    values[0] = strongSelf->_playbackOffset;
                };
                
                prop.writeBlock = ^(TGInstantPageAudioView *strongSelf, CGFloat const *values)
                {
                    strongSelf->_playbackOffset = values[0];
                    if (!strongSelf->_scrubbing)
                        [strongSelf layoutScrubbingIndicator];
                };
            }];
            
            downloadProgressProperty = [POPAnimatableProperty propertyWithName:@"downloadProgress" initializer:^(POPMutableAnimatableProperty *prop)
            {
                prop.readBlock = ^(TGInstantPageAudioView *strongSelf, CGFloat *values)
                {
                    values[0] = strongSelf->_downloadProgress;
                };
                
                prop.writeBlock = ^(TGInstantPageAudioView *strongSelf, CGFloat const *values)
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
                if (true)
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
            if (true)
            {
                if (previousStatus != nil && !previousStatus.downloadedStatus.downloaded)
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
                        
                        animation.completionBlock = ^(__unused POPAnimation *animation, BOOL finished)
                        {
                            if (finished)
                            {
                                __strong TGInstantPageAudioView *strongSelf = weakSelf;
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
}

- (void)layoutSubviews {
    if (_ignoreLayout) {
        return;
    }
    
    CGSize size = self.bounds.size;
    UIEdgeInsets insets = [TGInstantPageAudioView insets];
    
    CGFloat leftInset = 46.0f + 10.0f;
    CGFloat rightInset = 0.0f;
    
    CGFloat maxTitleWidth = size.width - insets.left - leftInset - rightInset - insets.right;
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(maxTitleWidth, CGFLOAT_MAX)];
    titleSize.width = MIN(maxTitleWidth, titleSize.width);
    _titleLabel.frame = CGRectMake(insets.left + leftInset, 2.0f, titleSize.width, titleSize.height);
    
    _playPauseButton.frame = CGRectMake(insets.left, 0.0f, 48.0f, 48.0f);
    
    [self layoutScrubbingIndicator];
}

- (void)layoutScrubbingIndicator {
    bool ignoreLayout = _ignoreLayout;
    _ignoreLayout = true;
    
    UIEdgeInsets insets = [TGInstantPageAudioView insets];
    CGFloat leftInset = 46.0f + 10.0f;
    
    CGFloat topOffset = 0.0f;
    if (_titleLabel.attributedText.length == 0) {
        topOffset = -10.0f;
    }
    
    CGFloat displayOffset = _scrubbing ? _scrubbingOffset : _playbackOffset;
    
    int positionLabelValue = (int)(displayOffset * _currentStatus.duration);
    if (_currentStatus == nil || !_currentStatus.downloadedStatus.downloaded) {
        positionLabelValue = _duration;
    }
    if (_positionLabelValue != positionLabelValue) {
        _positionLabelValue = positionLabelValue;
        
        if (positionLabelValue > 60 * 60) {
            _positionLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", positionLabelValue / (60 * 60), (positionLabelValue % (60 * 60)) / 60, positionLabelValue % 60];
        } else {
            _positionLabel.text = [[NSString alloc] initWithFormat:@"%d:%02d", positionLabelValue / 60, positionLabelValue % 60];
        }
        [_positionLabel sizeToFit];
    }
    
    CGFloat positionLabelWidth = MAX(_positionLabel.frame.size.width, 32.0f) + 5.0f;
    
    CGFloat progressHeight = 2.0f;
    CGSize handleSize = CGSizeMake(8.0f, 8.0f);
    
    _scrubbingBackground.frame = CGRectMake(insets.left + leftInset + positionLabelWidth, 33.0f + topOffset, self.bounds.size.width - (insets.left + leftInset + positionLabelWidth) - insets.right, progressHeight);
    
    _scrubbingArea.frame = CGRectMake(insets.left + leftInset + positionLabelWidth, 33.0f - 5.0f + topOffset, self.bounds.size.width - (insets.left + leftInset + positionLabelWidth) - insets.right, progressHeight + 10.0f);
    
    CGPoint origin = _scrubbingBackground.frame.origin;
    CGFloat side = _scrubbingBackground.frame.size.width;
    CGFloat handleOriginX = TGScreenPixelFloor((side - handleSize.width) * displayOffset);
    _playbackScrubbingForeground.frame = CGRectMake(origin.x, origin.y, handleOriginX, progressHeight);
    _downloadingScrubbingForeground.frame = CGRectMake(origin.x, origin.y, _downloadProgress * side, progressHeight);
    _scrubbingHandle.frame = CGRectMake(origin.x + handleOriginX, origin.y + CGFloor((progressHeight - handleSize.height) / 2.0f), handleSize.width, handleSize.height);
    
    _positionLabel.frame = CGRectMake(origin.x - positionLabelWidth, origin.y - 7.0f, _positionLabel.frame.size.width, _positionLabel.frame.size.height);
    
    _ignoreLayout = ignoreLayout;
}

- (void)playPauseButtonPressed {
    if (_currentStatus != nil) {
        if (_currentStatus.paused) {
            [TGTelegraphInstance.musicPlayer controlPlay];
        } else {
            [TGTelegraphInstance.musicPlayer controlPause];
        }
    } else {
        if (_openAudio) {
            _openAudio(_document);
        }
    }
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

- (CGPoint)scrubbingLocationForTouch:(UITouch *)touch {
    return [touch locationInView:_scrubbingArea];
}

- (void)setOpenAudio:(void (^)(TGDocumentMediaAttachment *))openAudio {
    _openAudio = [openAudio copy];
}

@end
