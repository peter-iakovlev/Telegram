#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"

#import "TGFont.h"

@interface TGGenericPeerMediaGalleryDefaultHeaderView ()
{
    UILabel *_titleLabel;
    void (^_positionAndCountBlock)(id<TGModernGalleryItem>, NSUInteger *, NSUInteger *);
}

@end

@implementation TGGenericPeerMediaGalleryDefaultHeaderView

- (instancetype)initWithPositionAndCountBlock:(void (^)(id<TGModernGalleryItem>, NSUInteger *, NSUInteger *))positioAndCountBlock
{
    self = [super init];
    if (self != nil)
    {
        _positionAndCountBlock = positioAndCountBlock;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = TGMediumSystemFontOfSize(17);
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (CGRect)titleFrameForSize:(CGSize)size
{
    [_titleLabel sizeToFit];
    return CGRectMake(CGFloor((size.width - _titleLabel.frame.size.width) / 2.0f), CGFloor((44.0f - _titleLabel.frame.size.height) / 2.0f), _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _titleLabel.frame = [self titleFrameForSize:frame.size];
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    if (_positionAndCountBlock)
    {
        NSUInteger position = 0;
        NSUInteger count = 0;
        _positionAndCountBlock(item, &position, &count);
        
        _titleLabel.text = [[NSString alloc] initWithFormat:@"%d %@ %d", (int)position + 1, TGLocalized(@"Common.of"), (int)count];
        _titleLabel.frame = [self titleFrameForSize:self.frame.size];
    }
}

@end
