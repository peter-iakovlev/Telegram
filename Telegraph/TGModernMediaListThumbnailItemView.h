#import <LegacyComponents/TGModernMediaListItemContentView.h>

#import <SSignalKit/SSignalKit.h>

@class TGImageView;

@interface TGModernMediaListThumbnailItemView : TGModernMediaListItemContentView

@property (nonatomic, strong, readonly) TGImageView *imageView;

- (void)setImageUri:(NSString *)imageUri;
- (void)setImageUri:(NSString *)imageUri synchronously:(bool)synchronously;
- (void)setImageSignal:(SSignal *)signal;

@end
