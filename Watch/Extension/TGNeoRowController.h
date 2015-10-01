#import "WKInterfaceTable+TGDataDrivenTable.h"

@class TGBridgeMessage;
@class TGNeoMessageViewModel;
@class TGBridgeContext;

@interface TGNeoRowController : TGTableRowController

@property (nonatomic, copy) bool (^shouldRenderContent)(void);
@property (nonatomic, copy) bool (^shouldRenderOnMainThread)(void);
@property (nonatomic, copy) void (^animate)(void (^)(void));

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *bubbleGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *contentGroup;

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *headerWrapperGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *replyImageGroup;

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *mediaWrapperGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *imageGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *spinnerImage;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *videoButton;
@property (nonatomic, weak) IBOutlet WKInterfaceMap *map;

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *metaWrapperGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceGroup *avatarGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *avatarLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *audioButton;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *audioIcon;

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *statusGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *statusIcon;

@property (nonatomic, copy) void (^remotePressed)(void);

- (void)updateWithMessage:(TGBridgeMessage *)message context:(TGBridgeContext *)context index:(NSInteger)index channel:(bool)channel;
- (void)applyAdditionalLayoutForViewModel:(TGNeoMessageViewModel *)viewModel;

- (IBAction)remotePressedAction;

+ (Class)rowControllerClassForMessage:(TGBridgeMessage *)message;

@end
