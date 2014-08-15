#import "TGImageView.h"

@interface TGModernGalleryImageItemImageView : TGImageView

@property (nonatomic, copy) void (^progressChanged)(float);

@end
