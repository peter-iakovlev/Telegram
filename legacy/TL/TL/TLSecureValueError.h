#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSecureValueType;


@interface TLSecureValueError : NSObject <TLObject>

@property (nonatomic, retain) TLSecureValueType *type;
@property (nonatomic, retain) NSString *text;

@end


@interface TLSecureValueError$secureValueErrorData : TLSecureValueError

@property (nonatomic, retain) NSData *data_hash;
@property (nonatomic, retain) NSString *field;

@end

@interface TLSecureValueError$secureValueErrorFrontSide : TLSecureValueError

@property (nonatomic, retain) NSData *file_hash;

@end

@interface TLSecureValueError$secureValueErrorReverseSide : TLSecureValueError

@property (nonatomic, retain) NSData *file_hash;

@end

@interface TLSecureValueError$secureValueErrorSelfie : TLSecureValueError

@property (nonatomic, retain) NSData *file_hash;

@end

@interface TLSecureValueError$secureValueErrorFile : TLSecureValueError

@property (nonatomic, retain) NSData *file_hash;

@end

@interface TLSecureValueError$secureValueErrorFiles : TLSecureValueError

@property (nonatomic, retain) NSArray *file_hash;

@end
