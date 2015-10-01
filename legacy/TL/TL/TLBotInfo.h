#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLBotInfo : NSObject <TLObject>


@end

@interface TLBotInfo$botInfoEmpty : TLBotInfo


@end

@interface TLBotInfo$botInfo : TLBotInfo

@property (nonatomic) int32_t user_id;
@property (nonatomic) int32_t version;
@property (nonatomic, retain) NSString *share_text;
@property (nonatomic, retain) NSString *n_description;
@property (nonatomic, retain) NSArray *commands;

@end

