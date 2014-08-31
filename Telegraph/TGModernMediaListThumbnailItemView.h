#import "TGModernMediaListItemContentView.h"

@class TGImageView;

@interface TGModernMediaListThumbnailItemView : TGModernMediaListItemContentView

@property (nonatomic, strong, readonly) TGImageView *imageView;

- (void)setImageUri:(NSString *)imageUri;

@end
