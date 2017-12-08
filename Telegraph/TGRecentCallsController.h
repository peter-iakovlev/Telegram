#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGRecentCallsController : TGViewController

@property (nonatomic, copy) void (^missedCountChanged)(NSInteger count);
@property (nonatomic, strong) TGPresentation *presentation;

- (instancetype)initWithController:(TGRecentCallsController *)controller;
- (void)clearData;

- (void)initialize;

- (void)maybeSuggestEnableCallsTab:(bool)automatically;

@end
