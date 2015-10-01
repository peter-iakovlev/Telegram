#import "PSCoding.h"

@interface TGLinkPreviewsContentProperty : NSObject <PSCoding>

@property (nonatomic, readonly) bool disableLinkPreviews;

- (instancetype)initWithDisableLinkPreviews:(bool)disableLinkPreviews;

@end
