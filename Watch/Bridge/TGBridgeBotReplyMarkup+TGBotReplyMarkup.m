#import "TGBridgeBotReplyMarkup+TGBotReplyMarkup.h"

#import "TGMessage.h"
#import "TGBridgeMessage+TGMessage.h"

#import "TGBotReplyMarkup.h"
#import "TGBotReplyMarkupRow.h"
#import "TGBotReplyMarkupButton.h"

@implementation TGBridgeBotReplyMarkup (TGBotReplyMarkup)

+ (TGBridgeBotReplyMarkup *)botReplyMarkupWithTGBotReplyMarkup:(TGBotReplyMarkup *)botReplyMarkup message:(TGMessage *)message
{
    if (botReplyMarkup == nil)
        return nil;
    
    TGBridgeBotReplyMarkup *bridgeReplyMarkup = [[TGBridgeBotReplyMarkup alloc] init];
    bridgeReplyMarkup->_userId = botReplyMarkup.userId;
    bridgeReplyMarkup->_messageId = botReplyMarkup.messageId;
    bridgeReplyMarkup->_alreadyActivated = botReplyMarkup.alreadyActivated;
    bridgeReplyMarkup->_hideKeyboardOnActivation = botReplyMarkup.hideKeyboardOnActivation;
    
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    for (TGBotReplyMarkupRow *row in botReplyMarkup.rows)
    {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        for (TGBridgeBotReplyMarkupButton *button in row.buttons)
            [buttons addObject:[[TGBridgeBotReplyMarkupButton alloc] initWithText:button.text]];
        
        [rows addObject:[[TGBridgeBotReplyMarkupRow alloc] initWithButtons:buttons]];
    }
    bridgeReplyMarkup->_rows = rows;
    
    if (message != nil && message.forceReply)
        bridgeReplyMarkup->_message =  [TGBridgeMessage messageWithTGMessage:message conversation:nil];
    
    return bridgeReplyMarkup;
}

@end
