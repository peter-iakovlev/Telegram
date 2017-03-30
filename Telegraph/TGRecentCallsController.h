#import "TGViewController.h"

@interface TGRecentCallsController : TGViewController

@property (nonatomic, copy) void (^missedCountChanged)(NSInteger count);

- (instancetype)initWithController:(TGRecentCallsController *)controller;
- (void)clearData;

- (void)maybeSuggestEnableCallsTab:(bool)automatically;

@end
