#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;
@class TLMessageMedia;

@interface TLMessage : NSObject <TLObject>

@property (nonatomic) int32_t n_id;

@end

@interface TLMessage$messageEmpty : TLMessage


@end

@interface TLMessage$message : TLMessage

@property (nonatomic) int32_t flags;
@property (nonatomic) int32_t from_id;
@property (nonatomic, retain) TLPeer *to_id;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) TLMessageMedia *media;

@end

