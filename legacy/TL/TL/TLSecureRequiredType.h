#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLSecureValueType;

@interface TLSecureRequiredType : NSObject <TLObject>

@end

@interface TLSecureRequiredType$secureRequiredType : TLSecureRequiredType

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) TLSecureValueType *type;

@end


@interface TLSecureRequiredType$secureRequiredTypeOneOf : TLSecureRequiredType

@property (nonatomic, retain) NSArray *types;

@end
