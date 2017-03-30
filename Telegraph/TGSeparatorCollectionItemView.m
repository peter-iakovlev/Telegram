#import "TGSeparatorCollectionItemView.h"

#import "TGImageUtils.h"

@interface TGSeparatorCollectionItemView () {
    UIView *_separatorView;
}

@end

@implementation TGSeparatorCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.contentView addSubview:_separatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _separatorView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, TGScreenPixel);
}

@end
