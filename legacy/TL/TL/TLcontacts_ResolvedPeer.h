#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLcontacts_ResolvedPeer : NSObject <TLObject>

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLcontacts_ResolvedPeer$contacts_resolvedPeer : TLcontacts_ResolvedPeer


@end

