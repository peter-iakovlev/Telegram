#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLDocument;
@class TLBotInlineMessage;
@class TLPhoto;

@interface TLBotInlineResult : NSObject <TLObject>

@property (nonatomic, retain) NSString *n_id;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) TLBotInlineMessage *send_message;

@end

@interface TLBotInlineResult$botInlineMediaResultDocument : TLBotInlineResult

@property (nonatomic, retain) TLDocument *document;

@end

@interface TLBotInlineResult$botInlineMediaResultPhoto : TLBotInlineResult

@property (nonatomic, retain) TLPhoto *photo;

@end

