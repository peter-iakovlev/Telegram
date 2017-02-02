#import "TGGroupInviteSheet.h"

#import "TGGroupInviteSheetItemView.h"
#import "TGShareSheetButtonItemView.h"

@implementation TGGroupInviteSheet

- (instancetype)initWithTitle:(NSString *)title photoUrlSmall:(NSString *)photoUrlSmall userCount:(NSInteger)userCount users:(NSArray *)users join:(void (^)())join {
    self = [super init];
    if (self != nil) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        TGGroupInviteSheetItemView *inviteItem = [[TGGroupInviteSheetItemView alloc] initWithTitle:title photoUrlSmall:photoUrlSmall userCount:userCount users:users];
        [items addObject:inviteItem];
        
        __weak TGGroupInviteSheet *weakSelf = self;
        TGShareSheetButtonItemView *clearButtonItem = [[TGShareSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Invitation.JoinGroup") pressed:^ {
            if (join) {
                join();
            }
            
            __strong TGGroupInviteSheet *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf.view.cancel();
            }
        }];
        [items addObject:clearButtonItem];
        
        self.view.items = items;
    }
    return self;
}

@end
