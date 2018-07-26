#import "TGEditableCollectionItemView.h"
#import <SSignalKit/SSignalKit.h>

@interface TGPassportFileCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, copy) void (^removeRequested)();

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;
- (void)setIcon:(UIImage *)icon;
- (void)setImageSignal:(SSignal *)signal;
- (void)setIsRequired:(bool)isRequired;
- (void)setImageViewHidden:(bool)hidden;
- (void)setProgressSignal:(SSignal *)progressSignal;
- (void)setCalculatedSize:(CGSize)calculatedSize;

- (CGSize)imageSize;
- (UIView *)imageView;

@end
