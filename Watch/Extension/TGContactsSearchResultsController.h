#import "TGInterfaceController.h"

@class TGBridgeUser;

@interface TGContactsSearchResultsControllerContext : NSObject <TGInterfaceContext>

@property (nonatomic, strong) NSString *query;
@property (nonatomic, copy) void (^completionBlock)(TGBridgeUser *recipient);

@end

@interface TGContactsSearchResultsController : TGInterfaceController

@property (nonatomic, copy) IBOutlet WKInterfaceTable *table;

@end
