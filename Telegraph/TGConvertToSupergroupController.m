#import "TGConvertToSupergroupController.h"

#import "TGConversation.h"
#import "TGGroupManagementSignals.h"

#import "TGCommentCollectionItem.h"
#import "TGButtonCollectionItem.h"

#import "TGProgressWindow.h"
#import "TGInterfaceManager.h"

#import "TGAlertView.h"

@interface TGConvertToSupergroupController () {
    TGConversation *_conversation;
}

@end

@implementation TGConvertToSupergroupController

- (instancetype)initWithConversation:(TGConversation *)conversation {
    self = [super init];
    if (self != nil) {
        _conversation = conversation;
        
        self.title = TGLocalized(@"ConvertToSupergroup.Title");
        
        NSMutableArray *helpItems = [[NSMutableArray alloc] init];
        
        TGCommentCollectionItem *helpTitleItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"ConvertToSupergroup.HelpTitle")];
        [helpItems addObject:helpTitleItem];
        
        TGCommentCollectionItem *helpTextItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"ConvertToSupergroup.HelpText") paragraphSpacing:4.0f clearFormatting:false];
        helpTextItem.topInset -= 4.0f;
        [helpItems addObject:helpTextItem];
        
        TGCollectionMenuSection *helpSection = [[TGCollectionMenuSection alloc] initWithItems:helpItems];
        UIEdgeInsets helpSectionInsets = helpSection.insets;
        helpSectionInsets.top += 7.0f;
        helpSectionInsets.bottom = 12.0f;
        helpSection.insets = helpSectionInsets;
        [self.menuSections addSection:helpSection];
        
        NSMutableArray *actionItems = [[NSMutableArray alloc] init];
        TGButtonCollectionItem *convertItem = [[TGButtonCollectionItem alloc] initWithTitle:TGLocalized(@"GroupInfo.ConvertToSupergroup") action:@selector(convertPressed)];
        convertItem.deselectAutomatically = true;
        [actionItems addObject:convertItem];
        
        TGCommentCollectionItem *noticeItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"ConvertToSupergroup.Note")];
        [actionItems addObject:noticeItem];
        
        TGCollectionMenuSection *actionSection = [[TGCollectionMenuSection alloc] initWithItems:actionItems];
        UIEdgeInsets actionSectionInsets = actionSection.insets;
        actionSectionInsets.top = 0.0f;
        actionSection.insets = actionSectionInsets;
        [self.menuSections addSection:actionSection];
    }
    return self;
}

- (void)convertPressed {
    int64_t conversationId = _conversation.conversationId;
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Group.UpgradeConfirmation") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed) {
        if (okButtonPressed) {
            TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
            [progressWindow show:true];
            
            [[[[TGGroupManagementSignals migrateGroup:conversationId] deliverOn:[SQueue mainQueue]] onDispose:^{
                TGDispatchOnMainThread(^{
                    [progressWindow dismiss:true];
                });
            }] startWithNext:^(TGConversation *conversation) {
                [[TGInterfaceManager instance] navigateToConversationWithId:conversation.conversationId conversation:conversation];
            } error:^(__unused id error) {
            } completed:nil];
        }
    }] show];
}

@end
