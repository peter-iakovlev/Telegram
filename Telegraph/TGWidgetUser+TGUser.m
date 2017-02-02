#import "TGWidgetUser.h"
#import "TGUser.h"

@implementation TGWidgetUser (TGUser)

+ (instancetype)userWithTGUser:(TGUser *)user avatarPath:(NSString *)avatarPath
{
    TGWidgetUser *widgetUser = [[TGWidgetUser alloc] init];
    widgetUser->_identifier = user.uid;
    widgetUser->_firstName = user.firstName;
    widgetUser->_lastName = user.lastName;
    widgetUser->_avatarPath = avatarPath;
    return widgetUser;
}

@end
