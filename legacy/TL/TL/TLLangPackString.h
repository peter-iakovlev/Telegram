#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLLangPackString : NSObject <TLObject>

@property (nonatomic, retain) NSString *key;

@end

@interface TLLangPackString$langPackString : TLLangPackString

@property (nonatomic, retain) NSString *value;

@end

@interface TLLangPackString$langPackStringPluralized : TLLangPackString

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *zero_value;
@property (nonatomic, retain) NSString *one_value;
@property (nonatomic, retain) NSString *two_value;
@property (nonatomic, retain) NSString *few_value;
@property (nonatomic, retain) NSString *many_value;
@property (nonatomic, retain) NSString *other_value;

@end

@interface TLLangPackString$langPackStringDeleted : TLLangPackString


@end

