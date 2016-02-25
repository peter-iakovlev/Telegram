#import "TGCollectionItem.h"

@interface TGVersionCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *version;

- (instancetype)initWithVersion:(NSString *)version;

@end
