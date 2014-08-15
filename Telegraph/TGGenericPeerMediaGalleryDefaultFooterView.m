#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import "TGGenericPeerGalleryItem.h"

#import "TGFont.h"

#import "TGUser.h"
#import "TGDateUtils.h"

@interface TGGenericPeerMediaGalleryDefaultFooterView ()
{
    UILabel *_nameLabel;
    UILabel *_dateLabel;
}

@end

@implementation TGGenericPeerMediaGalleryDefaultFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = TGBoldSystemFontOfSize(15.0f);
        [self addSubview:_nameLabel];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = TGSystemFontOfSize(14.0f);
        [self addSubview:_dateLabel];
    }
    return self;
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
    {
        id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
        _nameLabel.text = [[concreteItem author] displayName];
        _dateLabel.text = [TGDateUtils stringForApproximateDate:(int)[concreteItem date]];
        
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat spacing = 1.0f;
    
    CGSize nameSize = [_nameLabel.text sizeWithFont:_nameLabel.font];
    nameSize.width = MIN(self.frame.size.width - 10.0f, nameSize.width);
    CGSize dateSize = [_dateLabel.text sizeWithFont:_dateLabel.font];
    dateSize.width = MIN(self.frame.size.width - 10.0f, dateSize.width);
    
    _nameLabel.frame = (CGRect){{CGFloor((self.frame.size.width - nameSize.width) / 2.0f), CGFloor((self.frame.size.height - nameSize.height - dateSize.height - spacing) / 2.0f)}, nameSize};
    _dateLabel.frame = (CGRect){{CGFloor((self.frame.size.width - dateSize.width) / 2.0f), CGRectGetMaxY(_nameLabel.frame) + spacing}, dateSize};
}

@end
