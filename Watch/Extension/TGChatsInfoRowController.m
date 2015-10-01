#import "TGChatsInfoRowController.h"
#import "TGChatInfo.h"

NSString *const TGChatsInfoRowIdentifier = @"TGChatsInfoRow";

@implementation TGChatsInfoRowController

- (void)updateWithChatInfo:(TGChatInfo *)chatInfo
{
    self.titleLabel.text = chatInfo.title;
    self.textLabel.text = chatInfo.text;
}

+ (NSString *)identifier
{
    return TGChatsInfoRowIdentifier;
}

@end
