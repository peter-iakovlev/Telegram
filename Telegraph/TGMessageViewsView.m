#import "TGMessageViewsView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGPresentation.h"

@interface TGMessageViewsView () {
    TGMessageViewsViewType _type;
    
    UIImageView *_iconView;
    UILabel *_label;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGMessageViewsView

- (void)willBecomeRecycled {
}

+ (UIImage *)iconImageForType:(TGMessageViewsViewType)type presentation:(TGPresentation *)presentation {
    switch (type) {
        case TGMessageViewsViewTypeIncoming:
        {
            return presentation.images.chatIncomingMessageViewsIcon;
        }
        case TGMessageViewsViewTypeOutgoing:
        {
            return presentation.images.chatOutgoingMessageViewsIcon;
        }
        case TGMessageViewsViewTypeMedia:
        {
            return presentation.images.chatMediaMessageViewsIcon;
        }
    }
}

+ (UIColor *)textColorForType:(TGMessageViewsViewType)type presentation:(TGPresentation *)presentation {
    switch (type) {
        case TGMessageViewsViewTypeIncoming:
            return presentation.pallete.chatIncomingDateColor;
        case TGMessageViewsViewTypeOutgoing:
            return presentation.pallete.chatOutgoingDateColor;
        case TGMessageViewsViewTypeMedia:
            return [UIColor whiteColor];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
        
        _label = [[UILabel alloc] init];
        _label.font = TGItalicSystemFontOfSize(11.0f);
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    _iconView.image = [TGMessageViewsView iconImageForType:_type presentation:presentation];
    _label.textColor = [TGMessageViewsView textColorForType:_type presentation:presentation];
}

- (void)setType:(TGMessageViewsViewType)type {
    _type = type;
    if (self.presentation != nil)
    {
        _iconView.image = [TGMessageViewsView iconImageForType:type presentation:self.presentation];
        [_iconView sizeToFit];
        _label.textColor = [TGMessageViewsView textColorForType:type presentation:self.presentation];
    }
}

+ (NSString *)stringForCount:(int32_t)count {
    if (count < 1000) {
        return [[NSString alloc] initWithFormat:@"%d", (int)count];
    } else if (count < 1000 * 1000) {
        return [[NSString alloc] initWithFormat:@"%.1fk", (float)count / 1000.0f];
    } else {
        return [[NSString alloc] initWithFormat:@"%.1fm", (float)count / (1000.0f * 1000.0f)];
    }
}

- (void)setCount:(int32_t)count {
    _count = count;
    
    _label.text = [TGMessageViewsView stringForCount:MAX(1, count)];
    [_label sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize labelSize = _label.bounds.size;
    _label.frame = CGRectMake(self.bounds.size.width - labelSize.width, 0.0f, labelSize.width, labelSize.height);
    _iconView.frame = CGRectOffset(_iconView.bounds, _label.frame.origin.x - _iconView.bounds.size.width - 3.0f, 2.0f);
}

+ (void)drawInContext:(CGContextRef)context frame:(CGRect)frame type:(TGMessageViewsViewType)type count:(int32_t)count presentation:(TGPresentation *)presentation {
    UIImage *image = [self iconImageForType:type presentation:presentation];
    UIFont *font = TGItalicSystemFontOfSize(11.0f);
    
    NSString *text = [self stringForCount:MAX(1, count)];
    CGSize labelSize = [text sizeWithFont:font];
    labelSize.width = CGCeil(labelSize.width);
    labelSize.height = CGCeil(labelSize.height);
    
    CGContextSetFillColorWithColor(context, [self textColorForType:type presentation:presentation].CGColor);
    
    [text drawInRect:CGRectMake(CGRectGetMaxX(frame) - labelSize.width + 1.0f - TGRetinaPixel, frame.origin.y, labelSize.width, labelSize.height) withFont:font];
    [image drawInRect:CGRectMake(CGRectGetMaxX(frame) - labelSize.width - image.size.width - 3.0f + 1.0f - TGRetinaPixel, frame.origin.y + 2.0f, image.size.width, image.size.height)];
}

@end
