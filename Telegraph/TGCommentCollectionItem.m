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
    NSAttributedString *_attributedText;
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
        
        _attributedText = [self attributedStringFromText:text allowFormatting:false];
    }
    return self;
}

- (instancetype)initWithFormattedText:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.highlightable = false;
        self.selectable = false;
        
        _attributedText = [self attributedStringFromText:text allowFormatting:true];
    }
    return self;
}

- (NSAttributedString *)attributedStringFromText:(NSString *)text allowFormatting:(bool)allowFormatting
{
    NSMutableArray *boldRanges = [[NSMutableArray alloc] init];
    
    NSMutableString *cleanText = [[NSMutableString alloc] initWithString:text];
    if (allowFormatting)
    {
        while (true)
        {
            NSRange startRange = [cleanText rangeOfString:@"**"];
            if (startRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:startRange];
            
            NSRange endRange = [cleanText rangeOfString:@"**"];
            if (endRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:endRange];
            
            [boldRanges addObject:[NSValue valueWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)]];
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cleanText attributes:@
    {
    }];
    
    [attributedString addAttributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: TGSystemFontOfSize(14.0f)} range:NSMakeRange(0, attributedString.length)];

    NSDictionary *boldAttributes = @{NSFontAttributeName: TGBoldSystemFontOfSize(14.0f)};
    for (NSValue *nRange in boldRanges)
    {
        [attributedString addAttributes:boldAttributes range:[nRange rangeValue]];
    }

    return attributedString;
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
    
    CGSize textSize = [_attributedText boundingRectWithSize:CGSizeMake(containerSize.width - 30.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    
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
    
    [((TGCommentCollectionItemView *)view) setAttributedText:_attributedText];
}

@end
