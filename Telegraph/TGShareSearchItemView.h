#import "TGMenuSheetItemView.h"
#import <SSignalKit/SSignalKit.h>

@interface TGShareSearchItemView : TGMenuSheetItemView

@property (nonatomic, readonly) SMetaDisposable *disposable;

@property (nonatomic, copy) void (^externalPressed)(void);
@property (nonatomic, copy) void (^didBeginSearch)(void);
@property (nonatomic, copy) void (^textChanged)(NSString *text);
@property (nonatomic, copy) void (^didEndSearch)(bool reload);

- (void)setSelectedPeerIds:(NSArray *)selectedPeerIds peers:(NSDictionary *)peers;
- (void)setShowActivity:(bool)activity;

- (void)finishSearch;

- (void)setExternalButtonHidden:(bool)hidden;

@end
