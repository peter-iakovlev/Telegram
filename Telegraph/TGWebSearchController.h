#import "TGViewController.h"

@class TGImageInfo;

@interface TGWebSearchController : TGViewController

@property (nonatomic, copy) void (^completion)(NSArray *);

+ (void)clearRecents;
+ (void)addRecentSelectedItems:(NSArray *)items;

@end
