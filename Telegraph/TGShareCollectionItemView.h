#import "TGMenuSheetItemView.h"

@interface TGShareCollectionItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^selectionChanged)(NSArray *selectedPeerIds, NSDictionary *peers);
@property (nonatomic, copy) void (^searchResultSelected)();

@property (nonatomic, copy) void (^dismissCommentView)();

@property (nonatomic, readonly) NSArray *peerIds;
@property (nonatomic, assign) bool hasActionButton;

- (void)searchBegan;
- (void)searchEnded:(bool)reload;
- (void)setSearchQuery:(NSString *)searchQuery updateActivity:(void (^)(bool active))updateActivity;

- (void)setExpanded;

@end
