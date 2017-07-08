#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLchannels_AdminLogResults : NSObject <TLObject>

@property (nonatomic, retain) NSArray *events;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLchannels_AdminLogResults$channels_adminLogResults : TLchannels_AdminLogResults


@end

