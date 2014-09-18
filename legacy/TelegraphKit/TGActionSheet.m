#import "TGActionSheet.h"

#import "Freedom.h"

#import <objc/runtime.h>

@implementation TGActionSheetAction

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action
{
    return [self initWithTitle:title action:action type:TGActionSheetActionTypeGeneric];
}

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action type:(TGActionSheetActionType)type
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _action = action;
        _type = type;
    }
    return self;
}

@end

@interface TGActionSheet () <UIActionSheetDelegate>
{
    int _replacedIndex;
}

@property (nonatomic, weak) id target;
@property (nonatomic, copy) void (^actionBlock)(id target, NSString *action);
@property (nonatomic, strong) NSArray *actions;

@end

@implementation TGActionSheet

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions actionBlock:(void (^)(id target, NSString *action))actionBlock target:(id)target
{
    self = [super initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    if (self != nil)
    {
        self.delegate = self;
        _actions = actions;
        
        for (TGActionSheetAction *action in actions)
        {
            int buttonIndex = [self addButtonWithTitle:action.title];
            if (action.type == TGActionSheetActionTypeCancel)
                self.cancelButtonIndex = buttonIndex;
            else if (action.type == TGActionSheetActionTypeDestructive)
                self.destructiveButtonIndex = buttonIndex;
        }
        
        self.actionBlock = actionBlock;
        self.target = target;
        
        _replacedIndex = -1;
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)__unused actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_replacedIndex != -1)
        buttonIndex = _replacedIndex;
    
    id target = _target;
    if (target != nil && _actionBlock != nil)
    {
        _actionBlock(target, ((TGActionSheetAction *)_actions[buttonIndex]).action);
    }
}

- (BOOL)canBecomeFirstResponder
{
    return false;
}

- (BOOL)resignFirstResponder
{
    return false;
}

@end
