#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLPeer;

@interface TLTopPeer : NSObject <TLObject>

@property (nonatomic, retain) TLPeer *peer;
@property (nonatomic) double rating;

@end

@interface TLTopPeer$topPeer : TLTopPeer


@end

