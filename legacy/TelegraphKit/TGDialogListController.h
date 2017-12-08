#import <UIKit/UIKit.h>

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>

extern NSString *authorNameYou;

@class TGDialogListCompanion;
@class TGModernConversationTitlePanel;

@class TGPresentation;

@interface TGDialogListController : TGViewController <ASWatcher>

@property (nonatomic, copy) void (^debugReady)(void);

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@property (nonatomic, strong) TGDialogListCompanion *dialogListCompanion;

@property (nonatomic) bool canLoadMore;

@property (nonatomic) bool doNotHideSearchAutomatically;

@property (nonatomic) bool isDisplayingSearch;

@property (nonatomic, strong) TGPresentation *presentation;

+ (void)setLastAppearedConversationId:(int64_t)conversationId;

+ (void)setDebugDoNotJump:(bool)debugDoNotJump;
+ (bool)debugDoNotJump;

- (id)initWithCompanion:(TGDialogListCompanion *)companion;

- (void)startSearch;

- (void)resetState;
- (void)dialogListFullyReloaded:(NSArray *)items;
- (void)updateConversations:(NSDictionary *)dict;
- (void)dialogListItemsChanged:(NSArray *)insertedIndices insertedItems:(NSArray *)insertedItems updatedIndices:(NSArray *)updatedIndices updatedItems:(NSArray *)updatedItems removedIndices:(NSArray *)removedIndices;

- (void)requestSavedMessagesTooltip;

- (void)selectConversationWithId:(int64_t)conversationId;

- (void)searchResultsReloaded:(NSDictionary *)items searchString:(NSString *)searchString;

- (void)titleStateUpdated:(NSString *)text isLoading:(bool)isLoading isProxy:(bool)isProxy;

- (void)userTypingInConversationUpdated:(int64_t)conversationId typingString:(NSString *)typingString;

- (void)updateDatabasePassword;

- (void)updateSearchConversations:(NSArray *)conversations;

- (void)setCurrentTitlePanel:(TGModernConversationTitlePanel *)titlePanel;

- (void)setDimmed:(bool)dimmed animated:(bool)animated keyboardSnapshot:(UIView *)keyboardSnapshot restoringFocus:(bool)restoringFocus;

@end
