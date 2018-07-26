#import "TGCollectionItem.h"

@class ASHandle;
@class TGConversation;

@interface TGConversationSwitchCollectionItem : TGCollectionItem

@property (nonatomic, strong) ASHandle *interfaceHandle;
@property (nonatomic, copy) void (^toggled)(bool value, TGConversationSwitchCollectionItem *item);

@property (nonatomic, strong) TGConversation *conversation;
@property (nonatomic) bool isOn;
@property (nonatomic) bool isEnabled;
@property (nonatomic) bool isPermission;
@property (nonatomic) bool fullSeparator;

- (instancetype)initWithConversation:(TGConversation *)conversation isOn:(bool)isOn;

- (void)setIsOn:(bool)isOn animated:(bool)animated;

@end
