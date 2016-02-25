#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_FoundGifs : NSObject <TLObject>

@property (nonatomic) int32_t next_offset;
@property (nonatomic, retain) NSArray *results;

@end

@interface TLmessages_FoundGifs$messages_foundGifs : TLmessages_FoundGifs


@end

