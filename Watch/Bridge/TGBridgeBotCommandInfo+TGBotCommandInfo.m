#import "TGBridgeBotCommandInfo+TGBotCommandInfo.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGBridgeBotCommandInfo (TGBotCommandInfo)

+ (TGBridgeBotCommandInfo *)botCommandInfoWithTGBotCommandInfo:(TGBotComandInfo *)botCommandInfo
{
    if (botCommandInfo == nil)
        return nil;
    
    TGBridgeBotCommandInfo *bridgeCommandInfo = [[TGBridgeBotCommandInfo alloc] init];
    bridgeCommandInfo->_command = botCommandInfo.command;
    bridgeCommandInfo->_commandDescription = botCommandInfo.commandDescription;
    return bridgeCommandInfo;
}

@end
