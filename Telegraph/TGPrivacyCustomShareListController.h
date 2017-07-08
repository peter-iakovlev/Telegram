#import "TGCollectionMenuController.h"

@interface TGPrivacyCustomShareListController : TGCollectionMenuController

- (instancetype)initWithTitle:(NSString *)title contactSearchPlaceholder:(NSString *)contactSearchPlaceholder userIds:(NSArray *)userIds dialogs:(bool)dialogs userIdsChanged:(void (^)(NSArray *))userIdsChanged;

+ (id)presentAddInterfaceWithTitle:(NSString *)title contactSearchPlaceholder:(NSString *)contactSearchPlaceholder onController:(UIViewController *)controller dialogs:(bool)dialogs completion:(void (^)(NSArray *))completion;

@end
