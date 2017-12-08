#import "TGChannelMembersControllerEmptyView.h"

#import <LegacyComponents/LegacyComponents.h>

@interface TGChannelMembersControllerEmptyView () {
    UILabel *_label;
}

@end

@implementation TGChannelMembersControllerEmptyView

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self != nil) {
        _label = [[UILabel alloc] init];
        _label.text = text;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = UIColorRGB(0x6d6d72);
        _label.font = TGSystemFontOfSize(15.0f);
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    CGSize labelSize = [_label.text sizeWithFont:_label.font constrainedToSize:CGSizeMake(size.width - 40.0f, CGFLOAT_MAX) lineBreakMode:_label.lineBreakMode];
    _label.frame = CGRectMake(CGFloor((size.width - labelSize.width) / 2.0f), CGFloor((size.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
}

@end
