#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLBotCommand : NSObject <TLObject>

@property (nonatomic, retain) NSString *command;
@property (nonatomic, retain) NSString *n_description;

@end

@interface TLBotCommand$botCommand : TLBotCommand


@end

