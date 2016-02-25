#import "TGShareSheetItemView.h"

@interface TGShareSheetSharePeersItemView : TGShareSheetItemView

@property (nonatomic, copy) void (^copyShareLink)();
@property (nonatomic, copy) void (^shareWithCaption)(NSArray<NSNumber *> *peerIds, NSString *caption);

@end
