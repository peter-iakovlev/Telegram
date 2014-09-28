#import <Foundation/Foundation.h>

@interface TGModernAnimatedImagePlayer : NSObject

@property (nonatomic, copy) void (^frameReady)(UIImage *);

- (instancetype)initWithSize:(CGSize)size path:(NSString *)path;

- (void)play;
- (void)stop;
- (void)pause;

@end
