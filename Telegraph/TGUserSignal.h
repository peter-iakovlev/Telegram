#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

@interface TGUserSignal : NSObject

+ (SSignal *)userWithUserId:(int32_t)userId;
+ (SSignal *)updatedUserCachedDataWithUserId:(int32_t)userId;
+ (SSignal *)groupsInCommon:(int32_t)userId;

@end
