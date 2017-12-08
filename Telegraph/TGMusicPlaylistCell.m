#import "TGMusicPlaylistCell.h"

#import <LegacyComponents/TGFont.h>
#import <LegacyComponents/TGImageUtils.h>

#import <LegacyComponents/TGImageView.h>

#import "TGMusicPlayerItem.h"
#import "TGMusicPlayerItemSignals.h"

NSString *const TGMusicPlaylistCellKind = @"TGMusicPlaylistCell";
const CGFloat TGMusicPlaylistCellHeight = 56.0f;

@interface TGMusicNowPlayingIndicator : UIView
{
    UIView *_bar1;
    UIView *_bar2;
    UIView *_bar3;
    UIView *_bar4;
    
    bool _playing;
}

- (void)setPlaying:(bool)playing;

@end

@interface TGMusicPlaylistCell ()
{
    TGMusicPlayerItem *_item;
    
    UILabel *_titleLabel;
    UILabel *_performerLabel;
    UILabel *_durationLabel;
    UIView *_separatorView;
    
    TGImageView *_coverView;
    UIView *_dimView;
    TGMusicNowPlayingIndicator *_indicator;
    
    bool _hasCover;
}
@end

@implementation TGMusicPlaylistCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGSystemFontOfSize(16.0f);
        [self.contentView addSubview:_titleLabel];
        
        _performerLabel = [[UILabel alloc] init];
        _performerLabel.textColor = UIColorRGB(0x8b8b8b);
        _performerLabel.font = TGSystemFontOfSize(13.0f);
        [self.contentView addSubview:_performerLabel];
        
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = UIColorRGB(0x8b8b8b);
        _durationLabel.font = TGSystemFontOfSize(13.0f);
        [self.contentView addSubview:_durationLabel];
        
        _coverView = [[TGImageView alloc] init];
        _coverView.backgroundColor = UIColorRGB(0xeeeeee);
        _coverView.clipsToBounds = true;
        _coverView.layer.cornerRadius = 7.0f;
        [self.contentView addSubview:_coverView];
        
        if (iosMajorVersion() >= 11)
            _coverView.accessibilityIgnoresInvertColors = true;
        
        _dimView = [[UIView alloc] init];
        _dimView.backgroundColor = UIColorRGBA(0x000000, 0.6f);
        _dimView.hidden = true;
        [_coverView addSubview:_dimView];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, TGScreenPixel)];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.contentView addSubview:_separatorView];
    }
    return self;
}

- (void)prepareForReuse
{
    [_coverView reset];
}

- (void)setCurrent:(bool)current
{
    if (current && _indicator == nil)
    {
        _indicator = [[TGMusicNowPlayingIndicator alloc] init];
        [self addSubview:_indicator];
    }
    else if (!current && _indicator != nil)
    {
        [_indicator removeFromSuperview];
        _indicator = nil;
    }
    _dimView.hidden = !current;
    [self updateDimView];
    
    [self setNeedsLayout];
}

- (void)setPlaying:(bool)playing
{
    [_indicator setPlaying:playing];
}

- (TGMusicPlayerItem *)item
{
    return _item;
}

- (void)setItem:(TGMusicPlayerItem *)item
{
    _item = item;
    
    NSString *title = item.title;
    NSString *performer = item.performer;
    
    if (title.length == 0)
        title = @"Unknown Track";
    
    if (performer.length == 0)
        performer = @"Unknown Artist";
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    _performerLabel.text = performer;
    [_performerLabel sizeToFit];
    
    int duration = item.duration;
    NSString *durationString = @"";
    if (duration > 60 * 60)
        durationString = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", duration / (60 * 60), (duration % (60 * 60)) / 60, duration % 60];
    else
        durationString = [[NSString alloc] initWithFormat:@"%d:%02d", duration / 60, duration % 60];
    _durationLabel.text = durationString;
    [_durationLabel sizeToFit];
    
    [self setNeedsLayout];

    __weak TGMusicPlaylistCell *weakSelf = self;
    [_coverView setSignal:[[[TGMusicPlayerItemSignals albumArtForItem:item thumbnail:true] onNext:^(__unused id next) {
        TGDispatchOnMainThread(^
        {
            __strong TGMusicPlaylistCell *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_hasCover = true;
                [strongSelf updateDimView];
            }
        });
    }] catch:^(__unused id error)
    {
        TGDispatchOnMainThread(^
        {
            __strong TGMusicPlaylistCell *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_hasCover = false;
                [strongSelf updateDimView];
            }
        });
        return [SSignal single:TGImageNamed(@"MusicPlayerSmallAlbumArtPlaceholder")];
    }]];
}

- (void)updateDimView
{
    _dimView.backgroundColor = _hasCover ? UIColorRGBA(0x000000, 0.6) : UIColorRGB(0x5f5f5f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = 84.0f;
    
    _coverView.frame = CGRectMake(20.0f, 4.0f, 48.0f, 48.0f);
    _dimView.frame = _coverView.bounds;
    _indicator.frame = CGRectMake(35.0f, 28.0f, 18.0f, 10.0f);
    _separatorView.frame = CGRectMake(padding, self.frame.size.height - _separatorView.frame.size.height, self.frame.size.width - padding, _separatorView.frame.size.height);
    
    _durationLabel.frame = CGRectMake(self.frame.size.width - _durationLabel.frame.size.width - 20.0f, 8.0f, _durationLabel.frame.size.width, _durationLabel.frame.size.height);
    _titleLabel.frame = CGRectMake(padding, 8.0f, MIN(_titleLabel.frame.size.width, self.frame.size.width - padding - _durationLabel.frame.size.width - 20.0f - 8.0f), _titleLabel.frame.size.height);
    _performerLabel.frame = CGRectMake(padding, CGRectGetMaxY(_titleLabel.frame) + 4.0f + TGScreenPixel, MIN(_performerLabel.frame.size.width, self.frame.size.width - padding - 12.0f), _performerLabel.frame.size.height);
}

@end


@implementation TGMusicNowPlayingIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _bar1 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 3.0f, 13.0f)];
        _bar1.backgroundColor = [UIColor whiteColor];
        _bar1.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        _bar1.transform = CGAffineTransformMakeScale(1.0f, 0.2f);
        [self addSubview:_bar1];
        
        _bar2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_bar1.frame) + 2.0f, 0.0f, 3.0f, 13.0f)];
        _bar2.backgroundColor = [UIColor whiteColor];
        _bar2.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        _bar2.transform = CGAffineTransformMakeScale(1.0f, 0.2f);
        [self addSubview:_bar2];
        
        _bar3 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_bar2.frame) + 2.0f, 0.0f, 3.0f, 13.0f)];
        _bar3.backgroundColor = [UIColor whiteColor];
        _bar3.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        _bar3.transform = CGAffineTransformMakeScale(1.0f, 0.2f);
        [self addSubview:_bar3];
        
        _bar4 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_bar3.frame) + 2.0f, 0.0f, 3.0f, 13.0f)];
        _bar4.backgroundColor = [UIColor whiteColor];
        _bar4.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        _bar4.transform = CGAffineTransformMakeScale(1.0f, 0.2f);
        [self addSubview:_bar4];
    }
    return self;
}

- (void)setPlaying:(bool)playing
{
    bool wasPlaying = _playing;
    _playing = playing;
    
    for (UIView *bar in self.subviews)
    {
        if (playing)
        {
            double randValueMul = ((double)arc4random() / UINT32_MAX);
            double randDurationMul = ((double)arc4random() / UINT32_MAX);
            
            CABasicAnimation *barAnimation;
            barAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
            barAnimation.toValue = @(0.5f + 0.5f * randValueMul);
            barAnimation.autoreverses = true;
            barAnimation.duration = 0.25 + 0.25 * randDurationMul;
            barAnimation.repeatCount = HUGE_VALF;
            barAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            
            [bar.layer removeAllAnimations];
            [bar.layer addAnimation:barAnimation forKey:@"barPlayAnimation"];
        }
        else
        {
            if (wasPlaying)
            {
                CABasicAnimation *barAnimation;
                barAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
                barAnimation.fromValue = @([[bar.layer.presentationLayer valueForKeyPath: @"transform.scale.y"] floatValue]);
                barAnimation.toValue = @(0.2f);
                barAnimation.duration = 0.25;
                //barAnimation.beginTime = CACurrentMediaTime() + 0.1;
         
                [bar.layer removeAllAnimations];
                [bar.layer addAnimation:barAnimation forKey:@"barStopAnimation"];
            }
            else
            {
                [bar.layer removeAllAnimations];
            }
        }
    }
}

@end
