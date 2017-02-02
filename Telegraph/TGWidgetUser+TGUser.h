#import "TGWidgetUser.h"

@class TGUser;

@interface TGWidgetUser (TGUser)

+ (instancetype)userWithTGUser:(TGUser *)user avatarPath:(NSString *)avatarPath;

@end
