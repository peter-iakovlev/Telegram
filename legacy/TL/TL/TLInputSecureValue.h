#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSecureValueType;
@class TLSecureData;
@class TLSecurePlainData;
@class TLInputSecureFile;

@interface TLInputSecureValue : NSObject <TLObject>

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLSecureValueType *type;
@property (nonatomic, retain) TLSecureData *data;
@property (nonatomic, retain) TLInputSecureFile *front_side;
@property (nonatomic, retain) TLInputSecureFile *reverse_side;
@property (nonatomic, retain) TLInputSecureFile *selfie;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, retain) TLSecurePlainData *plain_data;


@end

@interface TLInputSecureValue$inputSecureValueMeta : TLInputSecureValue

@end

