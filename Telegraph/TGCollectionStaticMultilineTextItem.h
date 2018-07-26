#import "TGCollectionItem.h"

@interface TGCollectionStaticMultilineTextItem : TGCollectionItem

@property (nonatomic, strong) NSString *text;

@property (nonatomic, copy) void (^followLink)(NSString *);
@property (nonatomic, copy) void (^holdLink)(NSString *);

@end
