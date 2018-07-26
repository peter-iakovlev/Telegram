#import <LegacyComponents/TGMenuSheetItemView.h>
#import <SSignalKit/SSignalKit.h>

@class TGPresentation;

@interface TGShareSearchItemView : TGMenuSheetItemView

@property (nonatomic, readonly) SMetaDisposable *disposable;

@property (nonatomic, assign) bool collapsed;

@property (nonatomic, copy) void (^dismissAction)(void);
@property (nonatomic, copy) void (^externalPressed)(void);
@property (nonatomic, copy) void (^didBeginSearch)(void);
@property (nonatomic, copy) void (^textChanged)(NSString *text);
@property (nonatomic, copy) void (^didEndSearch)(bool reload);

@property (nonatomic, strong) TGPresentation *presentation;

- (void)setSelectedPeerIds:(NSArray *)selectedPeerIds peers:(NSDictionary *)peers;
- (void)setShowActivity:(bool)activity;

- (void)finishSearch;

- (void)setExternalButtonHidden:(bool)hidden;

@end
