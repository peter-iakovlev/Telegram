#import "WKInterfaceTable+TGDataDrivenTable.h"

@class TGBridgeChat;
@class TGBridgeContext;

@interface TGChatsRowController : TGTableRowController

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *avatarGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *avatarInitialsLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *nameLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *initialsLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *messageTextLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *mediaIcon;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *timeLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *unreadCountGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *unreadCountLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *readGroup;

- (void)updateWithChat:(TGBridgeChat *)chat context:(TGBridgeContext *)context;

- (void)hideUnreadCountBadge;

@end
