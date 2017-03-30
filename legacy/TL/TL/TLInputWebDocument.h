#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputWebDocument : NSObject <TLObject>

@property (nonatomic, retain) NSString *url;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString *mime_type;
@property (nonatomic, retain) NSArray *attributes;

@end

@interface TLInputWebDocument$inputWebDocument : TLInputWebDocument


@end

