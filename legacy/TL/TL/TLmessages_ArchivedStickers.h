#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_ArchivedStickers : NSObject <TLObject>

@property (nonatomic) int32_t count;
@property (nonatomic, retain) NSArray *sets;

@end

@interface TLmessages_ArchivedStickers$messages_archivedStickers : TLmessages_ArchivedStickers


@end

