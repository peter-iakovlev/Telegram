#import "TGCollectionMenuController.h"

@interface TGPrivacyCustomShareListController : TGCollectionMenuController

- (instancetype)initWithTitle:(NSString *)title contactSearchPlaceholder:(NSString *)contactSearchPlaceholder userIds:(NSArray *)userIds userIdsChanged:(void (^)(NSArray *))userIdsChanged;

+ (id)presentAddInterfaceWithTitle:(NSString *)title contactSearchPlaceholder:(NSString *)contactSearchPlaceholder onController:(UIViewController *)controller completion:(void (^)(NSArray *))completion;

@end
