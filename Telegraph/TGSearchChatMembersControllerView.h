#import <UIKit/UIKit.h>

@class TGUser;
@class TGCachedConversationMember;

@interface TGSearchChatMembersControllerView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;

- (instancetype)initWithFrame:(CGRect)frame updateNavigationBarHidden:(void (^)(bool hidden, bool animated))updateNavigationBarHidden peerId:(int64_t)peerId accessHash:(int64_t)accessHash includeContacts:(bool)includeContacts completion:(void (^)(TGUser *, TGCachedConversationMember *member))completion;

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset controllerInset:(UIEdgeInsets)controllerInset navigationBarShouldBeHidden:(bool)navigationBarShouldBeHidden;

- (void)setUsers:(NSArray<TGUser *> *)users memberDatas:(NSDictionary<NSNumber *, TGCachedConversationMember *> *)memberDatas;

@end
