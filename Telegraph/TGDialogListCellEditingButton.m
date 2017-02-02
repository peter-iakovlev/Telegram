#import "TGDialogListCellEditingButton.h"
#import "TGFont.h"

@interface TGDialogListCellEditingButton () {
    UILabel *_labelView;
    UIImageView *_iconView;
}

@end

@implementation TGDialogListCellEditingButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = nil;
        _labelView.opaque = false;
        _labelView.textColor = [UIColor whiteColor];
        
        static UIFont *font;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            font = TGSystemFontOfSize(13.0f);
        });
        
        _labelView.font = font;
        [self addSubview:_labelView];
        
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
    }
    return self;
}

- (void)setTitle:(NSString *)title image:(UIImage *)image {
    _labelView.text = title;
    [_labelView sizeToFit];
    
    _iconView.image = image;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize labelSize = _labelView.bounds.size;
    CGSize iconSize = _iconView.image.size;
    
    _labelView.frame = CGRectMake(CGFloor((bounds.size.width - labelSize.width) / 2.0f), 48.0f, labelSize.width, labelSize.height);
    _iconView.frame = CGRectMake(CGFloor((bounds.size.width - iconSize.width) / 2.0f), 14.0f, iconSize.width, iconSize.height);
}

- (void)panGesture:(UIPanGestureRecognizer *)__unused recognizer {
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor force:false];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor force:(bool)force {
    if (force) {
        [super setBackgroundColor:backgroundColor];
    }
}

@end
