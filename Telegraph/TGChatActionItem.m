#import "TGChatActionItem.h"

@implementation TGChatActionItem

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon alt:(NSString *)alt subitems:(NSArray *)subitmes action:(void (^)(void))action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _icon = icon;
        _alt = alt;
        _subitems = subitmes;
        _action = [action copy];
    }
    return self;
}

@end
