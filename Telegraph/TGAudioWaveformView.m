#import "TGAudioWaveformView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGAudioWaveformContentView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) TGAudioWaveform *waveform;
@property (nonatomic) CGFloat peakHeight;

@end

@implementation TGAudioWaveformContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = false;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setWaveform:(TGAudioWaveform *)waveform {
    if (TGObjectCompare(_waveform, waveform)) {
        return;
    }
    
    _waveform = waveform;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)__unused rect {
    CGFloat sampleWidth = 2.0f;
    CGFloat halfSampleWidth = 1.0f;
    CGFloat distance = 1.0f;
    
    CGSize size = self.bounds.size;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _color.CGColor);
    
    if (_waveform == nil) {
        CGContextFillRect(context, CGRectMake(halfSampleWidth, size.height - sampleWidth, size.width - sampleWidth, sampleWidth));
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, size.height - sampleWidth, sampleWidth, sampleWidth));
        CGContextFillEllipseInRect(context, CGRectMake(size.width - sampleWidth, size.height - sampleWidth, sampleWidth, sampleWidth));
    } else {
        
        uint16_t *samples = (uint16_t *)_waveform.samples.bytes;
        int maxReadSamples = (int)_waveform.samples.length / 2;
        
        uint16_t maxSample = 0;
        for (int i = 0; i < maxReadSamples; i++) {
            //averageSample += ABS(samples[i]);
            if (maxSample < samples[i]) {
                maxSample = samples[i];
            }
        }
        //averageSample /= maxReadSamples;
        
        //CGFloat scale = averageSample * 1.9f;
        CGFloat scale = maxSample;
        if (scale < 1.0f) {
            scale = 1.0f;
        }
        int numSamples = (int)CGFloor(self.frame.size.width / (sampleWidth + distance));
        
        int16_t adjustedSamples[numSamples];
        memset(adjustedSamples, 0, numSamples * 2);
        for (int i = 0; i < maxReadSamples; i++) {
            int index = i * numSamples / maxReadSamples;
            int16_t sample = samples[i];
            if (sample < 0) {
                sample = -sample;
            }
            
            if (adjustedSamples[index] < sample) {
                adjustedSamples[index] = sample;
            }
        }
        
        for (int i = 0; i < numSamples; i++) {
            CGFloat offset = i * (sampleWidth + distance);
            
            int16_t peakSample = adjustedSamples[i];
            
            CGFloat sampleHeight = peakSample * _peakHeight / scale;
            if (ABS(sampleHeight) > _peakHeight) {
                if (sampleHeight < 0) {
                    sampleHeight = _peakHeight;
                } else {
                    sampleHeight = _peakHeight;
                }
            }
            
            CGFloat adjustedSampleHeight = sampleHeight - sampleWidth;
            if (adjustedSampleHeight <= sampleWidth + FLT_EPSILON) {
                CGContextFillEllipseInRect(context, CGRectMake(offset, size.height - sampleWidth, sampleWidth, sampleWidth));
                CGContextFillRect(context, CGRectMake(offset, size.height - halfSampleWidth, sampleWidth, halfSampleWidth));
            } else {
                CGRect adjustedRect = CGRectMake(offset, size.height - adjustedSampleHeight, sampleWidth, adjustedSampleHeight);
                CGContextFillRect(context, adjustedRect);
                CGContextFillEllipseInRect(context, CGRectMake(adjustedRect.origin.x, adjustedRect.origin.y - halfSampleWidth, sampleWidth, sampleWidth));
                CGContextFillEllipseInRect(context, CGRectMake(adjustedRect.origin.x, adjustedRect.origin.y + adjustedRect.size.height - halfSampleWidth, sampleWidth, sampleWidth));
            }
        }
    }
}

@end

@interface TGAudioWaveformView () {
    TGAudioWaveformContentView *_backgroundView;
    UIView *_foregroundClippingView;
    TGAudioWaveformContentView *_foregroundView;
}

@end

@implementation TGAudioWaveformView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _backgroundView = [[TGAudioWaveformContentView alloc] initWithFrame:self.bounds];
        _foregroundView = [[TGAudioWaveformContentView alloc] initWithFrame:self.bounds];
        _foregroundClippingView = [[UIView alloc] initWithFrame:self.bounds];
        _foregroundClippingView.clipsToBounds = true;
        [self addSubview:_backgroundView];
        [_foregroundClippingView addSubview:_foregroundView];
        [self addSubview:_foregroundClippingView];
        _peakHeight = 12.0f;
        _backgroundView.peakHeight = _peakHeight;
        _foregroundView.peakHeight = _peakHeight;
    }
    return self;
}

- (void)setPeakHeight:(CGFloat)peakHeight {
    _peakHeight = peakHeight;
    _backgroundView.peakHeight = _peakHeight;
    _foregroundView.peakHeight = _peakHeight;
}

- (UIView *)backgroundView {
    return _backgroundView;
}

- (UIView *)foregroundView {
    return _foregroundView;
}

- (UIView *)foregroundClippingView {
    return _foregroundClippingView;
}

- (void)setForegroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor {
    _foregroundView.color = foregroundColor;
    _backgroundView.color = backgroundColor;
}

- (void)setWaveform:(TGAudioWaveform *)waveform {
    [_backgroundView setWaveform:waveform];
    [_foregroundView setWaveform:waveform];
}

- (void)layoutSubviews {
}

@end
