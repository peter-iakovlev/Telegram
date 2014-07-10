#import <Foundation/Foundation.h>

#import "PSCoding.h"
#import "TGUserUUID.h"

@class TGMtFileLocation;

@interface TGUserModel : NSObject <PSCoding>

@property (nonatomic, strong, readonly) TGUserUUID *uuid;

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;

@property (nonatomic, strong, readonly) TGMtFileLocation *avatarSmallLocation;
@property (nonatomic, strong, readonly) TGMtFileLocation *avatarLargeLocation;

- (instancetype)initWithUserId:(int32_t)userId firstName:(NSString *)firstName lastName:(NSString *)lastName avatarSmallLocation:(TGMtFileLocation *)avatarSmallLocation avatarLargeLocation:(TGMtFileLocation *)avatarLargeLocation;

@end
