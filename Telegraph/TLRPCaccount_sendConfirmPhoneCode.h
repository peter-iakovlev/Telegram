#import "TLMetaRpc.h"

//account.sendConfirmPhoneCode flags:# allow_flashcall:flags.0?true hash:string current_number:flags.0?Bool = auth.SentCode;
//account.confirmPhone phone_code_hash:string phone_code:string = Bool;

@interface TLRPCaccount_sendConfirmPhoneCode : TLMetaRpc

@property (nonatomic, strong) NSString *n_hash;

@end
