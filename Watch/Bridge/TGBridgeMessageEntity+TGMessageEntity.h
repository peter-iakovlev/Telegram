#import "TGBridgeMessageEntities.h"
#import "TGMessageEntity.h"

@interface TGBridgeMessageEntity (TGMessageEntity)

+ (TGBridgeMessageEntity *)entityWithTGMessageEntity:(TGMessageEntity *)entity;

@end
