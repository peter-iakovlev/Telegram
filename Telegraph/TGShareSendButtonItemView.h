#import "TGMenuSheetItemView.h"

@interface TGShareSendButtonItemView : TGMenuSheetItemView

@property (nonatomic, assign) bool collapsed;

@property (nonatomic, copy) void (^didBeginEditingComment)(void);

@property (nonatomic, readonly) NSString *caption;

- (instancetype)initWithActionTitle:(NSString *)actionTitle action:(void (^)(void))action sendAction:(void (^)(NSString *caption))sendAction;

- (void)setSelectedCount:(NSInteger)count;

- (void)dismissCommentView;

@end
