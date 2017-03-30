#import "TGCollectionMenuController.h"

@class TGShippingOption;

@interface TGShippingMethodController : TGCollectionMenuController

@property (nonatomic, copy) void (^completed)(TGShippingOption *);

- (instancetype)initWithOptions:(NSArray<TGShippingOption *> *)options currentOption:(TGShippingOption *)currentOption;

@end
