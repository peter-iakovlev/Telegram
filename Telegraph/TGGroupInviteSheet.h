#import "TGShareSheetWindow.h"

@interface TGGroupInviteSheet : TGShareSheetWindow

- (instancetype)initWithTitle:(NSString *)title photoUrlSmall:(NSString *)photoUrlSmall userCount:(NSInteger)userCount users:(NSArray *)users join:(void (^)())join;

@end
