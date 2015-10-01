#import "WKInterfaceTable+TGDataDrivenTable.h"

@class TGChatInfo;

@interface TGChatsInfoRowController : TGTableRowController

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *textLabel;

- (void)updateWithChatInfo:(TGChatInfo *)chatInfo;

@end
