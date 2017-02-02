#import "TGShareSheetItemView.h"

@interface TGGroupInviteSheetItemView : TGShareSheetItemView

- (instancetype)initWithTitle:(NSString *)title photoUrlSmall:(NSString *)photoUrlSmall userCount:(NSInteger)userCount users:(NSArray *)users;

@end
