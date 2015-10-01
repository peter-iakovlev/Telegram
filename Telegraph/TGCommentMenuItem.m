#import "TGCommentMenuItem.h"

#import "TGCommentMenuItemView.h"

@interface TGCommentMenuItem ()

@property (nonatomic) CGFloat cachedHeight;
@property (nonatomic) UIInterfaceOrientation cachedHeightWidth;

@end

@implementation TGCommentMenuItem

- (id)initWithComment:(NSString *)comment
{
    self = [super initWithType:TGCommentMenuItemType];
    if (self != nil)
    {
        _comment = comment;
    }
    return self;
}

- (void)setComment:(NSString *)comment
{
    _comment = comment;
    
    _cachedHeight = 0.0f;
    _cachedHeightWidth = 0.0f;
}

- (CGFloat)heightForWidth:(float)width
{
    if (ABS(width - _cachedHeightWidth) < FLT_EPSILON)
        return _cachedHeight;
    
    _cachedHeight = [_comment sizeWithFont:[TGCommentMenuItemView defaultFont] constrainedToSize:CGSizeMake(width - 12 * 2, 1000) lineBreakMode:NSLineBreakByWordWrapping].height + 7 * 2;
    _cachedHeightWidth = width;
    
    return _cachedHeight;
}

@end
