#import "TGBridgeMessageEntitiesAttachment+TGMessageEntitiesAttachment.h"
#import "TGBridgeMessageEntity+TGMessageEntity.h"

@implementation TGBridgeMessageEntitiesAttachment (TGMessageEntitiesAttachment)

+ (TGBridgeMessageEntitiesAttachment *)attachmentWithTGMessageEntitiesAttachment:(TGMessageEntitiesAttachment *)attachment
{
    if (attachment == nil)
        return nil;
    
    TGBridgeMessageEntitiesAttachment *bridgeAttachment = [[TGBridgeMessageEntitiesAttachment alloc] init];
    
    NSMutableArray *bridgeEntities = [[NSMutableArray alloc] init];
    for (TGMessageEntity *entity in attachment.entities)
    {
        TGBridgeMessageEntity *bridgeEntity = [TGBridgeMessageEntity entityWithTGMessageEntity:entity];
        if (bridgeEntity != nil)
            [bridgeEntities addObject:bridgeEntity];
    }
    bridgeAttachment.entities = bridgeEntities;
    
    return bridgeAttachment;
}

@end
