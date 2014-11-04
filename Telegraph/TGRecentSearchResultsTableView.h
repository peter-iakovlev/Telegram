#import <UIKit/UIKit.h>

@interface TGRecentSearchResultsTableView : UITableView

@property (nonatomic, copy) void (^itemSelected)(NSString *);
@property (nonatomic, copy) void (^clearPressed)();
@property (nonatomic, strong) NSArray *items;

@end
