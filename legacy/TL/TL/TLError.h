#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLError : NSObject <TLObject>

@property (nonatomic) int32_t code;

@end

@interface TLError$error : TLError

@property (nonatomic, retain) NSString *text;

@end

@interface TLError$richError : TLError

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *n_description;
@property (nonatomic, retain) NSString *debug;
@property (nonatomic, retain) NSString *request_params;

@end

