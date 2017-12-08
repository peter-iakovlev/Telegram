#import <LegacyComponents/TGMenuSheetItemView.h>

@interface TGShareSendButtonItemView : TGMenuSheetItemView

@property (nonatomic, assign) bool collapsed;

@property (nonatomic, copy) void (^didBeginEditingComment)(void);

@property (nonatomic, readonly) NSString *caption;

- (instancetype)initWithTopActionTitle:(NSString *)topActionTitle topAction:(void (^)(void))topAction bottomActionTitle:(NSString *)bottomActionTitle bottomAction:(void (^)(void))bottomAction sendAction:(void (^)(NSString *caption))sendAction;

- (void)setSelectedCount:(NSInteger)count;

- (void)dismissCommentView;

@end
