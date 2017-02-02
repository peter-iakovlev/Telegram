#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLInputUser;

@interface TLInputGame : NSObject <TLObject>


@end

@interface TLInputGame$inputGameID : TLInputGame

@property (nonatomic) int64_t n_id;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputGame$inputGameShortName : TLInputGame

@property (nonatomic, retain) TLInputUser *bot_id;
@property (nonatomic, retain) NSString *short_name;

@end

