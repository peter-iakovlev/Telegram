#import "TGShareSheetTitleItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGShareSheetTitleItemView () {
    UILabel *_titleLabel;
}

@end

@implementation TGShareSheetTitleItemView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self != nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = nil;
        _titleLabel.opaque = false;
        _titleLabel.textColor = UIColorRGB(0x7c7c7c);
        _titleLabel.font = TGSystemFontOfSize(13.0f);
        _titleLabel.text = title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (CGFloat)preferredHeightForMaximumHeight:(CGFloat)__unused maximumHeight {
    return 40.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.frame = self.bounds;
}

@end
