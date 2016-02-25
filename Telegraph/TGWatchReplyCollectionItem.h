#import "TGCollectionItem.h"

@interface TGWatchReplyCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, copy) void (^valueChanged)(NSString *);
@property (nonatomic, copy) void (^inputReturned)(void);

- (instancetype)initWithIdentifier:(NSString *)identifier value:(NSString *)value placeholder:(NSString *)placeholder;

- (void)becomeFirstResponder;
- (void)resignFirstResponder;

@end
