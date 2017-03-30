#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputWebFileLocation : NSObject <TLObject>

@property (nonatomic, retain) NSString *url;
@property (nonatomic) int64_t access_hash;

@end

@interface TLInputWebFileLocation$inputWebFileLocation : TLInputWebFileLocation


@end

