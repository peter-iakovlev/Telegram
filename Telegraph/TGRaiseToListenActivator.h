#import <Foundation/Foundation.h>

@class TGDataItem;
@class TGLiveUploadActorData;

@interface TGRaiseToListenActivator : NSObject

@property (nonatomic) bool enabled;
@property (nonatomic, readonly) bool activated;

- (instancetype)initWithShouldActivate:(bool (^)())shouldActivate activate:(void (^)())activate deactivate:(void (^)())deactivate;

@end
