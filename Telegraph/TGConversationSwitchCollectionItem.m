#import "TGConversationSwitchCollectionItem.h"

#import <LegacyComponents/ASHandle.h>
#import <LegacyComponents/TGConversation.h>

#import "TGConversationSwitchCollectionItemView.h"

@interface TGConversationSwitchCollectionItem () <TGConversationSwitchCollectionItemViewDelegate>
{
    
}

@end

@implementation TGConversationSwitchCollectionItem

- (instancetype)initWithConversation:(TGConversation *)conversation isOn:(bool)isOn
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
        
        _conversation = conversation;
        _isOn = isOn;
        
        _isEnabled = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGConversationSwitchCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 48);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [((TGConversationSwitchCollectionItemView *)view) setFullSeparator:_fullSeparator];
    [((TGConversationSwitchCollectionItemView *)view) setConversation:_conversation];
    [((TGConversationSwitchCollectionItemView *)view) setIsOn:_isOn animated:false];
    [((TGConversationSwitchCollectionItemView *)view) setIsEnabled:_isEnabled];
    ((TGConversationSwitchCollectionItemView *)view).delegate = self;
}

- (void)unbindView
{
    ((TGConversationSwitchCollectionItemView *)[self boundView]).delegate = self;
    
    [super unbindView];
}

- (void)setConversation:(TGConversation *)conversation
{
    if (conversation != _conversation)
    {
        _conversation = conversation;
        
        if ([self boundView] != nil)
            [((TGConversationSwitchCollectionItemView *)[self boundView]) setConversation:_conversation];
    }
}

- (void)setIsOn:(bool)isOn
{
    [self setIsOn:isOn animated:true];
}

- (void)setIsOn:(bool)isOn animated:(bool)animated
{
    if (_isOn != isOn)
    {
        _isOn = isOn;
        
        if ([self boundView] != nil)
            [((TGConversationSwitchCollectionItemView *)[self boundView]) setIsOn:_isOn animated:animated];
    }
}

- (void)switchCollectionItemViewChangedValue:(TGConversationSwitchCollectionItemView *)switchItemView isOn:(bool)isOn
{
    if (switchItemView == [self boundView])
    {
        _isOn = isOn;
        
        if (_toggled)
            _toggled(isOn, self);
        [_interfaceHandle requestAction:@"switchItemChanged" options:@{@"item": self, @"value": @(_isOn)}];
    }
}

@end
