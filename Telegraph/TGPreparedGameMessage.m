#import "TGPreparedGameMessage.h"

#import "TGMessage.h"

@implementation TGPreparedGameMessage

- (instancetype)initWithGame:(TGGameMediaAttachment *)game replyMessage:(TGMessage *)replyMessage replyMarkup:(TGReplyMarkupAttachment *)replyMarkup {
    self = [super init];
    if (self != nil) {
        _game = game;
        self.replyMessage = replyMessage;
        self.replyMarkup = replyMarkup;
    }
    return self;
}

- (TGMessage *)message
{
    TGMessage *message = [[TGMessage alloc] init];
    message.mid = self.mid;
    message.date = self.date;
    message.isBroadcast = self.isBroadcast;
    message.messageLifetime = self.messageLifetime;
    
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    [attachments addObject:_game];
    
    if (self.replyMessage != nil)
    {
        TGReplyMessageMediaAttachment *replyMedia = [[TGReplyMessageMediaAttachment alloc] init];
        replyMedia.replyMessageId = self.replyMessage.mid;
        replyMedia.replyMessage = self.replyMessage;
        [attachments addObject:replyMedia];
    }
    
    if (self.replyMarkup != nil) {
        [attachments addObject:self.replyMarkup];
    }
    
    if (self.botContextResult != nil) {
        [attachments addObject:self.botContextResult];
        
        [attachments addObject:[[TGViaUserAttachment alloc] initWithUserId:self.botContextResult.userId username:nil]];
    }
    
    message.mediaAttachments = attachments;
    
    return message;
}


@end
