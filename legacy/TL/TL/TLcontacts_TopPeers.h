#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLcontacts_TopPeers : NSObject <TLObject>


@end

@interface TLcontacts_TopPeers$contacts_topPeersNotModified : TLcontacts_TopPeers


@end

@interface TLcontacts_TopPeers$contacts_topPeers : TLcontacts_TopPeers

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

