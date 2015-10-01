#import "TGInterfaceController.h"
#import "TGBridgeStateSignal.h"

@interface TGChatsController : TGInterfaceController

@property (nonatomic, weak) IBOutlet WKInterfaceTable *table;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *authAlertGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *authAlertImage;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *authAlertImageGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *authAlertLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *authAlertDescLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *activityIndicator;

+ (NSString *)stringForSyncState:(TGBridgeSynchronizationStateValue)value;

@end
