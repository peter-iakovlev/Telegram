#import <Foundation/Foundation.h>

@interface TGModernAnimatedImagePlayer : NSObject

@property (nonatomic, copy) void (^frameReady)(UIImage *);

- (instancetype)initWithPath:(NSString *)path;

- (void)play;
- (void)stop;
- (void)pause;

@end
