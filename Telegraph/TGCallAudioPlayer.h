#import <Foundation/Foundation.h>

@interface TGCallAudioPlayer : NSObject

- (void)stop;

+ (instancetype)playFileURL:(NSURL *)url loops:(NSInteger)loops completion:(void (^)(void))completion;

@end
