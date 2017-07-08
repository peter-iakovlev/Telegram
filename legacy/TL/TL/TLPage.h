#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLPage : NSObject <TLObject>

@property (nonatomic, retain) NSArray *blocks;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) NSArray *documents;

@end

@interface TLPage$pagePart : TLPage


@end

@interface TLPage$pageFull : TLPage


@end

