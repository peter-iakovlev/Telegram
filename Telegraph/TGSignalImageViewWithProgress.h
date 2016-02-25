#import "TGSignalImageView.h"

@interface TGSignalImageViewWithProgress : TGSignalImageView

@property (nonatomic) bool manualProgress;

- (CGFloat)progress;
- (void)setProgress:(CGFloat)progress;
- (void)setProgress:(CGFloat)progress animated:(bool)animated;
- (void)setDownload;
- (void)setNone;
- (void)setPlay;

@end
