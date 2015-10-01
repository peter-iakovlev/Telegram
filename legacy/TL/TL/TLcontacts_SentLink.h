#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLmessages_Message;
@class TLcontacts_Link;

@interface TLcontacts_SentLink : NSObject <TLObject>

@property (nonatomic, retain) TLmessages_Message *message;
@property (nonatomic, retain) TLcontacts_Link *link;

@end

@interface TLcontacts_SentLink$contacts_sentLink : TLcontacts_SentLink


@end

