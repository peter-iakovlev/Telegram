#import "TGMessageViewsView.h"

#import "TGFont.h"
#import "TGImageUtils.h"

@interface TGMessageViewsView () {
    UIImageView *_iconView;
    UILabel *_label;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGMessageViewsView

- (void)willBecomeRecycled {
}

+ (UIImage *)iconImageForType:(TGMessageViewsViewType)type {
    switch (type) {
        case TGMessageViewsViewTypeIncoming:
        {
            static UIImage *image = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                image = [UIImage imageNamed:@"MessageInlineViewCountIconIncoming.png"];
            });
            return image;
        }
        case TGMessageViewsViewTypeOutgoing:
        {
            static UIImage *image = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                image = [UIImage imageNamed:@"MessageInlineViewCountIconOutgoing.png"];
            });
            return image;
        }
        case TGMessageViewsViewTypeMedia:
        {
            static UIImage *image = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                image = [UIImage imageNamed:@"MessageInlineViewCountIconMedia.png"];
            });
            return image;
        }
    }
}

+ (UIColor *)textColorForType:(TGMessageViewsViewType)type {
    switch (type) {
        case TGMessageViewsViewTypeIncoming:
            return UIColorRGBA(0x525252, 0.6f);
        case TGMessageViewsViewTypeOutgoing:
            return UIColorRGBA(0x008c09, 0.8f);
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

- (void)setType:(TGMessageViewsViewType)type {
    _iconView.image = [TGMessageViewsView iconImageForType:type];
    [_iconView sizeToFit];
    _label.textColor = [TGMessageViewsView textColorForType:type];
}

+ (NSString *)stringForCount:(int32_t)count {
    if (count < 1000) {
        return [[NSString alloc] initWithFormat:@"%d", (int)count];
    } else if (count < 1000 * 1000) {
        return [[NSString alloc] initWithFormat:@"%dk", (int)count / 1000];
    } else {
        return [[NSString alloc] initWithFormat:@"%dm", (int)count / (1000 * 1000)];
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

+ (void)drawInContext:(CGContextRef)context frame:(CGRect)frame type:(TGMessageViewsViewType)type count:(int32_t)count {
    UIImage *image = [self iconImageForType:type];
    UIFont *font = TGItalicSystemFontOfSize(11.0f);
    
    NSString *text = [self stringForCount:MAX(1, count)];
    CGSize labelSize = [text sizeWithFont:font];
    labelSize.width = CGCeil(labelSize.width);
    labelSize.height = CGCeil(labelSize.height);
    
    CGContextSetFillColorWithColor(context, [self textColorForType:type].CGColor);
    
    [text drawInRect:CGRectMake(CGRectGetMaxX(frame) - labelSize.width + 1.0f - TGRetinaPixel, frame.origin.y, labelSize.width, labelSize.height) withFont:font];
    [image drawInRect:CGRectMake(CGRectGetMaxX(frame) - labelSize.width - image.size.width - 3.0f + 1.0f - TGRetinaPixel, frame.origin.y + 2.0f, image.size.width, image.size.height)];
}

@end
