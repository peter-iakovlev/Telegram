#import <Foundation/Foundation.h>

@class TGImageView;

@interface TGSharedMediaImageViewQueue : NSObject

- (void)enqueueImageView:(TGImageView *)imageView forUri:(NSString *)uri;
- (TGImageView *)dequeueImageViewForUri:(NSString *)uri;
- (void)resetEnqueuedImageViews;

@end
