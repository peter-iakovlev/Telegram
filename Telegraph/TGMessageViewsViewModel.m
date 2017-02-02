#import "TGMessageViewsViewModel.h"

#import "TGMessageViewsView.h"

#import "TGFont.h"

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

- (void)sizeToFit {
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        font = TGItalicSystemFontOfSize(11.0f);
    });
    CGSize size = [[TGMessageViewsView stringForCount:_count] sizeWithFont:font];
    size.width = CGCeil(size.width);
    size.width += ((int)size.width) % 3;
    size.height = CGCeil(size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width + 19.0f, size.height);
}

@end
