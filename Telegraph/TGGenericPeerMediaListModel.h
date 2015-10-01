#import "TGModernMediaListModel.h"

@interface TGGenericPeerMediaListModel : TGModernMediaListModel

- (instancetype)initWithPeerId:(int64_t)peerId allowActions:(bool)allowActions;

@end
