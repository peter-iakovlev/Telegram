#import "TGCommentCollectionItem.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGCommentCollectionItemView.h"

#import "TGPresentation.h"

@interface TGCommentCollectionItem ()
{
    NSAttributedString *_attributedText;
    CGFloat _lastContainerWidth;
    CGSize _calculatedSize;
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
        _alpha = 1.0f;
        
        _attributedText = [TGCommentCollectionItem attributedStringFromText:text allowFormatting:false paragraphSpacing:0.0f];
    }
    return self;
}

- (instancetype)initWithFormattedText:(NSString *)text {
    return [self initWithFormattedText:text paragraphSpacing:0.0f clearFormatting:false];
}

- (instancetype)initWithFormattedText:(NSString *)text paragraphSpacing:(CGFloat)paragraphSpacing clearFormatting:(bool)clearFormatting
{
    return [self initWithFormattedText:text paragraphSpacing:paragraphSpacing clearFormatting:clearFormatting alignment:NSTextAlignmentNatural];
}

- (instancetype)initWithFormattedText:(NSString *)text paragraphSpacing:(CGFloat)paragraphSpacing clearFormatting:(bool)clearFormatting alignment:(NSTextAlignment)alignment
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.highlightable = false;
        self.selectable = false;
        _alpha = 1.0f;
        
        _attributedText = [TGCommentCollectionItem attributedStringFromText:text allowFormatting:true paragraphSpacing:paragraphSpacing alignment:alignment fontSize:14.0f clearFormatting:clearFormatting];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.highlightable = false;
        self.selectable = false;
        _alpha = 1.0f;
    }
    return self;
}

+ (NSAttributedString *)attributedStringFromText:(NSString *)text allowFormatting:(bool)allowFormatting paragraphSpacing:(CGFloat)paragraphSpacing {
    return [self attributedStringFromText:text allowFormatting:allowFormatting paragraphSpacing:paragraphSpacing alignment:NSTextAlignmentNatural fontSize:14.0f clearFormatting:false];
}

+ (NSAttributedString *)attributedStringFromText:(NSString *)text allowFormatting:(bool)allowFormatting paragraphSpacing:(CGFloat)paragraphSpacing alignment:(NSTextAlignment)alignment fontSize:(CGFloat)fontSize clearFormatting:(bool)clearFormatting
{
    if (text.length == 0)
        return [[NSAttributedString alloc] initWithString:@"" attributes:nil];
    
    NSMutableArray *boldRanges = [[NSMutableArray alloc] init];
    NSMutableArray *linkRanges = [[NSMutableArray alloc] init];
    
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
        
        while (true)
        {
            NSRange startRange = [cleanText rangeOfString:@"["];
            if (startRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:startRange];
            
            NSRange endRange = [cleanText rangeOfString:@"]"];
            if (endRange.location == NSNotFound)
                break;
            
            [cleanText deleteCharactersInRange:endRange];
            
            [linkRanges addObject:[NSValue valueWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)]];
        }
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2;
    style.paragraphSpacing = paragraphSpacing;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = alignment;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:cleanText attributes:@{}];
    
    [attributedString addAttributes:@{NSParagraphStyleAttributeName: style, NSFontAttributeName: TGSystemFontOfSize(fontSize)} range:NSMakeRange(0, attributedString.length)];

    NSDictionary *boldAttributes = @{NSFontAttributeName: TGBoldSystemFontOfSize(fontSize)};
    for (NSValue *nRange in boldRanges)
    {
        [attributedString addAttributes:boldAttributes range:[nRange rangeValue]];
    }
    
    if (!clearFormatting) {
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: TGAccentColor()};
        for (NSValue *nRange in linkRanges)
        {
            [attributedString addAttributes:linkAttributes range:[nRange rangeValue]];
        }
    }

    return attributedString;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    _attributedText = [TGCommentCollectionItem attributedStringFromText:text allowFormatting:false paragraphSpacing:0.0f];
    
    if (_lastContainerWidth > FLT_EPSILON)
    {
        [self itemSizeForContainerSize:CGSizeMake(_lastContainerWidth, FLT_MAX)];
        [((TGCommentCollectionItemView *)self.boundView) setCalculatedSize:_calculatedSize];
    }
    
    [((TGCommentCollectionItemView *)self.boundView) setAttributedText:_attributedText];
}

- (void)setFormattedText:(NSString *)formattedText
{
    _text = nil;
    
    _attributedText = [TGCommentCollectionItem attributedStringFromText:formattedText allowFormatting:true paragraphSpacing:0.0f];
    
    if (_lastContainerWidth > FLT_EPSILON)
    {
        [self itemSizeForContainerSize:CGSizeMake(_lastContainerWidth, FLT_MAX)];
        [((TGCommentCollectionItemView *)self.boundView) setCalculatedSize:_calculatedSize];
    }
    
    [((TGCommentCollectionItemView *)self.boundView) setAttributedText:_attributedText];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    [((TGCommentCollectionItemView *)self.boundView) setTextColor:_textColor];
}

- (Class)itemViewClass
{
    return [TGCommentCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGSystemFontOfSize(14);
    });
    
    CGSize textSize = [_attributedText boundingRectWithSize:CGSizeMake(containerSize.width - 30.0f - safeAreaInset.left - safeAreaInset.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    
    if (_skipLastLineInSizeComputation)
    {
        CGFloat lineHeight = [@" " sizeWithFont:font].height;
        textSize.height = MAX(lineHeight, textSize.height - lineHeight);
    }
    
    _calculatedSize = CGSizeMake(containerSize.width, textSize.height + 7.0f + 7.0f + MAX(0.0f, _topInset) + _bottomInset);
    [((TGCommentCollectionItemView *)self.boundView) setCalculatedSize:_calculatedSize];
    
    _lastContainerWidth = containerSize.width;
    
    if (_hidden)
        return CGSizeMake(containerSize.width, 1.0f);
    
    return _calculatedSize;
}

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    
    [((TGCommentCollectionItemView *)self.boundView) setLabelAlpha:_alpha];
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];

    [((TGCommentCollectionItemView *)self.boundView) setLabelAlpha:_alpha];
    [((TGCommentCollectionItemView *)view) setCalculatedSize:_calculatedSize];
    [((TGCommentCollectionItemView *)view) setTopInset:_topInset];
    [((TGCommentCollectionItemView *)view) setTextColor:_textColor];
    [((TGCommentCollectionItemView *)view) setShowProgress:_showProgress];
    [((TGCommentCollectionItemView *)view) setAttributedText:_attributedText];
    [((TGCommentCollectionItemView *)view) setAction:_action];
}

- (void)unbindView
{
    [((TGCommentCollectionItemView *)self.boundView) setAction:_action];
    
    [super unbindView];
}

- (void)setShowProgress:(bool)showProgress
{
    _showProgress = showProgress;
    
    [((TGCommentCollectionItemView *)self.boundView) setShowProgress:_showProgress];
}

@end
