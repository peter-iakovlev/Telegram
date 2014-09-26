/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCommentCollectionItem.h"

#import "TGCommentCollectionItemView.h"

#import "TGFont.h"

@interface TGCommentCollectionItem ()
{
    NSString *_text;
}

@end

@implementation TGCommentCollectionItem

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.highlightable = false;
        self.selectable = false;
        
        _text = text;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGCommentCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(14);
    });
    
    CGSize textSize = [_text sizeWithFont:font constrainedToSize:CGSizeMake(containerSize.width - 30.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = ceilf(textSize.width);
    textSize.height = ceilf(textSize.height);
    
    if (_skipLastLineInSizeComputation)
    {
        CGFloat lineHeight = [@" " sizeWithFont:font].height;
        textSize.height = MAX(lineHeight, textSize.height - lineHeight);
    }
    
    return CGSizeMake(containerSize.width, textSize.height + 7.0f + 7.0f);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [((TGCommentCollectionItemView *)view) setText:_text];
}

@end
