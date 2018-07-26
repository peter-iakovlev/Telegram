#import "TGCollectionItem.h"

@interface TGUpdateAppInfoItem : TGCollectionItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *entities;

@property (nonatomic, copy) void (^followLink)(NSString *);

- (CGFloat)maximumWidth;

@end
