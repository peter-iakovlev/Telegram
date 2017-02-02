#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLWebPage : NSObject <TLObject>


@end

@interface TLWebPage$webPageEmpty : TLWebPage

@property (nonatomic) int64_t n_id;

@end

@interface TLWebPage$webPagePending : TLWebPage

@property (nonatomic) int64_t n_id;
@property (nonatomic) int32_t date;

@end

@interface TLWebPage$webPage : TLWebPage


@end

@interface TLWebPage$webPageNotModified : TLWebPage


@end

