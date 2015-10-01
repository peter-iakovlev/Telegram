#import "TGMessageViewsViewModel.h"

#import "TGMessageViewsView.h"

@interface TGMessageViewsViewModel () {
}

@end

@implementation TGMessageViewsViewModel

- (Class)viewClass {
    return [TGMessageViewsView class];
}

- (instancetype)init{
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage {
    [super bindViewToContainer:container viewStorage:viewStorage];

    [(TGMessageViewsView *)[self boundView] setType:_type];
    [(TGMessageViewsView *)[self boundView] setCount:_count];
}

- (void)setCount:(int32_t)count {
    _count = count;
    
    [(TGMessageViewsView *)[self boundView] setCount:_count];    
}

- (void)drawInContext:(CGContextRef)context {
    if (!self.hidden) {
        [TGMessageViewsView drawInContext:context frame:self.bounds type:_type count:_count];
    }
}

@end
