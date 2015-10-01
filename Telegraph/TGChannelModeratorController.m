#import "TGChannelModeratorController.h"

#import "TGCheckCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGDatabase.h"
#import "TGChannelManagementSignals.h"
#import "TGButtonCollectionItem.h"

#import "TGChannelModeratorCollectionItem.h"

@interface TGChannelModeratorController () {
    TGConversation *_conversation;
    TGUser *_user;
    TGCachedConversationMember *_originalMember;
    TGCachedConversationMember *_member;
    
    TGCheckCollectionItem *_moderatorItem;
    TGCheckCollectionItem *_editorItem;
    TGCommentCollectionItem *_accessLevelHelpItem;
}

@end

@implementation TGChannelModeratorController

- (instancetype)initWithConversation:(TGConversation *)conversation user:(TGUser *)user member:(TGCachedConversationMember *)member {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
        _user = user;
        _originalMember = member;
        _member = member;
        
        self.title = TGLocalized(@"Channel.Moderator.Title");
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Done") style:UIBarButtonItemStyleDone target:self action:@selector(donePressed)]];
        
        TGChannelModeratorCollectionItem *userItem = [[TGChannelModeratorCollectionItem alloc] init];
        userItem.user = user;
        TGCollectionMenuSection *userSection = [[TGCollectionMenuSection alloc] initWithItems:@[userItem]];
        UIEdgeInsets insets = userSection.insets;
        insets.top = 35.0f;
        userSection.insets = insets;
        [self.menuSections addSection:userSection];
        
        TGHeaderCollectionItem *accessLevelHeader = [[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Moderator.AccessLevelHeader")];
        _moderatorItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Moderator.AccessLevelModerator") action:@selector(moderatorPressed)];
        _moderatorItem.isChecked = _member == nil || _member.role == TGChannelRoleModerator;
        _editorItem = [[TGCheckCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Moderator.AccessLevelEditor") action:@selector(editorPressed)];
        _editorItem.isChecked = !_moderatorItem.isChecked;
        _accessLevelHelpItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"")];
        
        TGCollectionMenuSection *accessLevelSection = [[TGCollectionMenuSection alloc] initWithItems:@[accessLevelHeader, _moderatorItem, _editorItem, _accessLevelHelpItem]];
        [self.menuSections addSection:accessLevelSection];
        
        if (_member != nil) {
            TGButtonCollectionItem *dismissItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"Channel.Moderator.AccessLevelRevoke") action:@selector(dismissPressed)];
            dismissItem.titleColor = TGDestructiveAccentColor();
            TGCollectionMenuSection *dismissModeratorSection = [[TGCollectionMenuSection alloc] initWithItems:@[dismissItem]];
            [self.menuSections addSection:dismissModeratorSection];
        }
        
        [self updateAccessLevelHelp];
    }
    return self;
}

- (void)updateAccessLevelHelp {
    if (_moderatorItem.isChecked) {
        [_accessLevelHelpItem setFormattedText:TGLocalized(@"Channel.Moderator.AccessLevelModeratorHelp")];
    } else {
        [_accessLevelHelpItem setFormattedText:TGLocalized(@"Channel.Moderator.AccessLevelEditorHelp")];
    }
    
    [self.collectionLayout invalidateLayout];
    [self.collectionView layoutSubviews];
}

- (void)donePressed {
    if (_done) {
        _done(_member);
    }
}

- (void)moderatorPressed {
    _member = [[TGCachedConversationMember alloc] initWithUid:_user.uid role:TGChannelRoleModerator timestamp:0];
    _editorItem.isChecked = false;
    _moderatorItem.isChecked = true;
    [self updateAccessLevelHelp];
}

- (void)editorPressed {
    _member = [[TGCachedConversationMember alloc] initWithUid:_user.uid role:TGChannelRolePublisher timestamp:0];
    _editorItem.isChecked = true;
    _moderatorItem.isChecked = false;
    [self updateAccessLevelHelp];
}

- (void)dismissPressed {
    if (_done) {
        _done(nil);
    }
}

@end
