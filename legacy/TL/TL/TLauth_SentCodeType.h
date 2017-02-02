#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLauth_SentCodeType : NSObject <TLObject>


@end

@interface TLauth_SentCodeType$auth_sentCodeTypeApp : TLauth_SentCodeType

@property (nonatomic) int32_t length;

@end

@interface TLauth_SentCodeType$auth_sentCodeTypeSms : TLauth_SentCodeType

@property (nonatomic) int32_t length;

@end

@interface TLauth_SentCodeType$auth_sentCodeTypeCall : TLauth_SentCodeType

@property (nonatomic) int32_t length;

@end

@interface TLauth_SentCodeType$auth_sentCodeTypeFlashCall : TLauth_SentCodeType

@property (nonatomic, retain) NSString *pattern;

@end

