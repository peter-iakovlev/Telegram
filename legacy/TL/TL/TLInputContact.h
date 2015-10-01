#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLInputContact : NSObject <TLObject>

@property (nonatomic) int64_t client_id;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;

@end

@interface TLInputContact$inputPhoneContact : TLInputContact


@end

