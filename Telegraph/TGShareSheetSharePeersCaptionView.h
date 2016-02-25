#import <UIKit/UIKit.h>

@interface TGShareSheetSharePeersCaptionView : UIView

@property (nonatomic, copy) void (^heightChanged)(CGFloat height);

@property (nonatomic, strong, readonly) NSString *text;

@end
