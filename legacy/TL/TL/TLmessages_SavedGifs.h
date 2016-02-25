#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_SavedGifs : NSObject <TLObject>


@end

@interface TLmessages_SavedGifs$messages_savedGifsNotModified : TLmessages_SavedGifs


@end

@interface TLmessages_SavedGifs$messages_savedGifs : TLmessages_SavedGifs

@property (nonatomic) int32_t n_hash;
@property (nonatomic, retain) NSArray *gifs;

@end

