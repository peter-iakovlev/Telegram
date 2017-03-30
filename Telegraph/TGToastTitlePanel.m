#import "TGToastTitlePanel.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGModernButton.h"

@interface TGToastTitlePanel () {
    UILabel *_label;
    TGModernButton *_closeButton;
    UIView *_separatorView;
}

@end

@implementation TGToastTitlePanel

- (instancetype)initWithText:(NSString *)text {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 37.0f)];
    if (self != nil) {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor blackColor];
        _label.font = TGSystemFontOfSize(14.0f);
        _label.text = text;
        _label.numberOfLines = 1;
        [self addSubview:_label];
        
        _closeButton = [[TGModernButton alloc] init];
        _closeButton.adjustsImageWhenHighlighted = false;
        [_closeButton setImage:[UIImage imageNamed:@"MusicPlayerMinimizedClose.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        _closeButton.hidden = true;
        
        _closeButton.extendedEdgeInsets = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_separatorView];
    }
    return self;
}

- (void)setDismiss:(void (^)())dismiss {
    _dismiss = [dismiss copy];
    _closeButton.hidden = _dismiss == nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat maxWidth = self.frame.size.width - 60.0f;
    CGSize labelSize = [_label.text sizeWithFont:_label.font constrainedToSize:CGSizeMake(maxWidth, self.frame.size.height)];
    labelSize.width = MIN(maxWidth, CGCeil(labelSize.width));
    labelSize.height = CGCeil(labelSize.height);
    
    _label.frame = CGRectMake(CGFloor((self.frame.size.width - labelSize.width) / 2.0f), CGFloor((self.frame.size.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
    
    _closeButton.frame = CGRectMake(self.frame.size.width - 44.0f, TGRetinaPixel, 44.0f, 36.0f);
    
    CGFloat separatorHeight = TGScreenPixel;
    _separatorView.frame = CGRectMake(0.0f, self.frame.size.height - separatorHeight, self.frame.size.width, separatorHeight);
}

- (void)closeButtonPressed {
    if (_dismiss) {
        _dismiss();
    }
}

@end
