#import "TGCollectionItemView.h"

@interface TGWatchReplyCollectionItemView : TGCollectionItemView

@property (nonatomic, copy) void (^valueChanged)(NSString *);
@property (nonatomic, copy) void (^inputReturned)(void);

- (void)setValue:(NSString *)value;
- (void)setPlaceholder:(NSString *)placeholder;

- (void)becomeFirstResponder;
- (void)resignFirstResponder;

@end
