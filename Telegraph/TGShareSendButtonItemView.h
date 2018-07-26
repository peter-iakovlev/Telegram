#import <LegacyComponents/TGMenuSheetItemView.h>

@class TGPresentation;

@interface TGShareSendButtonItemView : TGMenuSheetItemView

@property (nonatomic, assign) bool collapsed;

@property (nonatomic, copy) void (^didBeginEditingComment)(void);

@property (nonatomic, readonly) NSString *caption;
@property (nonatomic, strong) TGPresentation *presentation;

- (instancetype)initWithActionTitle:(NSString *)actionTitle action:(void (^)(void))action sendAction:(void (^)(NSString *caption))sendAction;

- (void)setSelectedCount:(NSInteger)count;

- (void)dismissCommentView;

@end
