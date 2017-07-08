#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGRemoteControlsManager : NSObject

+ (TGRemoteControlsManager *)instance;

- (id<SDisposable>)requestControlsWithPrevious:(void (^)())previous next:(void (^)())next play:(void (^)())play pause:(void (^)())pause position:(void (^)(NSTimeInterval position))position;

@end
