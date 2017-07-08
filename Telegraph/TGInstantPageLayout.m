#import "TGInstantPageLayout.h"

#import "TGFont.h"
#import <CoreText/CoreText.h>

#import "TGImageUtils.h"
#import "TGDateUtils.h"

#import "TGInstantPageImageView.h"
#import "TGInstantPageEmbedView.h"
#import "TGInstantPageSlideshowView.h"
#import "TGInstantPageFooterButtonView.h"
#import "TGInstantPageChannelView.h"
#import "TGInstantPageAudioView.h"

#import "TGEmbedPIPController.h"

#import "TGImageMediaAttachment.h"
#import "TGVideoMediaAttachment.h"
#import "TGDocumentMediaAttachment.h"

static const NSString *TGLineSpacingFactorAttribute = @"TGLineSpacingFactorAttribute";
static const NSString *TGUrlAttribute = @"TGUrlAttribute";
static const int32_t TGDistanceThresholdGroupEmbed = 1;
static const int32_t TGDistanceThresholdGroupMedia = 2;

static NSString *richPlainText(TGRichText *text) {
    if ([text isKindOfClass:[TGRichTextPlain class]]) {
        return ((TGRichTextPlain *)text).text;
    } else if ([text isKindOfClass:[TGRichTextBold class]]) {
        return richPlainText(((TGRichTextBold *)text).text);
    } else if ([text isKindOfClass:[TGRichTextItalic class]]) {
        return richPlainText(((TGRichTextItalic *)text).text);
    } else if ([text isKindOfClass:[TGRichTextUnderline class]]) {
        return richPlainText(((TGRichTextUnderline *)text).text);
    } else if ([text isKindOfClass:[TGRichTextStrikethrough class]]) {
        return richPlainText(((TGRichTextStrikethrough *)text).text);
    } else if ([text isKindOfClass:[TGRichTextFixed class]]) {
        return richPlainText(((TGRichTextFixed *)text).text);
    } else if ([text isKindOfClass:[TGRichTextUrl class]]) {
        return richPlainText(((TGRichTextUrl *)text).text);
    } else if ([text isKindOfClass:[TGRichTextEmail class]]) {
        return richPlainText(((TGRichTextEmail *)text).text);
    } else if ([text isKindOfClass:[TGRichTextCollection class]]) {
        NSMutableString *string = [[NSMutableString alloc] init];
        for (TGRichText *subtext in ((TGRichTextCollection *)text).texts) {
            NSString *substring = richPlainText(subtext);
            if (substring.length != 0) {
                [string appendString:substring];
            }
        }
        return string;
    } else {
        return @"";
    }
}

static CGFloat spacingBetweenBlocks(TGInstantPageBlock *upper, TGInstantPageBlock *lower) {
    if ([lower isKindOfClass:[TGInstantPageBlockCover class]] || ([lower isKindOfClass:[TGInstantPageBlockChannel class]] && upper == nil)) {
        return 0.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockChannel class]] && [upper isKindOfClass:[TGInstantPageBlockCover class]]) {
        TGInstantPageBlockCover *coverBlock = (TGInstantPageBlockCover *)upper;
        NSString *caption;
        if ([coverBlock.block isKindOfClass:[TGInstantPageBlockPhoto class]])
            caption = richPlainText(((TGInstantPageBlockPhoto *)coverBlock.block).caption);
        else if ([coverBlock.block isKindOfClass:[TGInstantPageBlockVideo class]])
            caption = richPlainText(((TGInstantPageBlockVideo *)coverBlock.block).caption);
        else if ([coverBlock.block isKindOfClass:[TGInstantPageBlockSlideshow class]])
            caption = richPlainText(((TGInstantPageBlockSlideshow *)coverBlock.block).caption);
        
        return caption.length > 0 ? -40.0f : 0.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockDivider class]] || [upper isKindOfClass:[TGInstantPageBlockDivider class]]) {
        return 25.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockBlockQuote class]] || [upper isKindOfClass:[TGInstantPageBlockBlockQuote class]] || [lower isKindOfClass:[TGInstantPageBlockPullQuote class]] || [upper isKindOfClass:[TGInstantPageBlockPullQuote class]]) {
        return 27.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockTitle class]]) {
        return 20.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockSubtitle class]] && [upper isKindOfClass:[TGInstantPageBlockTitle class]]) {
        return 18.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockAuthorAndDate class]]) {
        if ([upper isKindOfClass:[TGInstantPageBlockTitle class]] || [upper isKindOfClass:[TGInstantPageBlockSubtitle class]]) {
            return 18.0f;
        } else {
            return 20.0f;
        }
    } else if ([lower isKindOfClass:[TGInstantPageBlockParagraph class]]) {
        if ([upper isKindOfClass:[TGInstantPageBlockTitle class]] || [upper isKindOfClass:[TGInstantPageBlockAuthorAndDate class]]) {
            return 34.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockHeader class]] || [upper isKindOfClass:[TGInstantPageBlockSubheader class]]) {
            return 25.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockParagraph class]]) {
            return 25.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockList class]]) {
            return 31.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockPreFormatted class]]) {
            return 19.0f;
        } else {
            return 20.0f;
        }
    } else if ([lower isKindOfClass:[TGInstantPageBlockList class]]) {
        if ([upper isKindOfClass:[TGInstantPageBlockTitle class]] || [upper isKindOfClass:[TGInstantPageBlockAuthorAndDate class]]) {
            return 34.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockHeader class]] || [upper isKindOfClass:[TGInstantPageBlockSubheader class]]) {
            return 31.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockParagraph class]] || [upper isKindOfClass:[TGInstantPageBlockList class]]) {
            return 31.0f;
        } else if ([upper isKindOfClass:[TGInstantPageBlockPreFormatted class]]) {
            return 19.0f;
        } else {
            return 20.0f;
        }
    } else if ([lower isKindOfClass:[TGInstantPageBlockPreFormatted class]]) {
        if ([upper isKindOfClass:[TGInstantPageBlockParagraph class]]) {
            return 19.0f;
        } else {
            return 20.0f;
        }
    } else if ([lower isKindOfClass:[TGInstantPageBlockHeader class]]) {
        return 32.0f;
    } else if ([lower isKindOfClass:[TGInstantPageBlockSubheader class]]) {
        return 32.0f;
    } else if (lower == nil) {
        if ([upper isKindOfClass:[TGInstantPageBlockFooter class]]) {
            return 24.0f;
        } else {
            return 24.0f;
        }
    }
    return 20.0f;
}

@interface TGInstantPageStyleFontSizeItem : NSObject

@property (nonatomic, readonly) CGFloat size;

@end

@implementation TGInstantPageStyleFontSizeItem

- (instancetype)initWithSize:(CGFloat)size {
    self = [super init];
    if (self != nil) {
        _size = size;
    }
    return self;
}

@end

@interface TGInstantPageStyleLineSpacingFactorItem : NSObject

@property (nonatomic, readonly) CGFloat factor;

@end

@implementation TGInstantPageStyleLineSpacingFactorItem

- (instancetype)initWithFactor:(CGFloat)factor {
    self = [super init];
    if (self != nil) {
        _factor = factor;
    }
    return self;
}

@end

@interface TGInstantPageStyleFontSerifItem : NSObject

@property (nonatomic, readonly) bool serif;

@end

@implementation TGInstantPageStyleFontSerifItem

- (instancetype)initWithSerif:(bool)serif {
    self = [super init];
    if (self != nil) {
        _serif = serif;
    }
    return self;
}

@end

@interface TGInstantPageStyleFontFixedItem : NSObject

@property (nonatomic, readonly) bool fixed;

@end

@implementation TGInstantPageStyleFontFixedItem

- (instancetype)initWithFixed:(bool)fixed {
    self = [super init];
    if (self != nil) {
        _fixed = fixed;
    }
    return self;
}

@end

@interface TGInstantPageStyleBoldItem : NSObject

@end

@implementation TGInstantPageStyleBoldItem

@end

@interface TGInstantPageStyleItalicItem : NSObject

@end

@implementation TGInstantPageStyleItalicItem

@end

@interface TGInstantPageStyleUnderlineItem : NSObject

@end

@implementation TGInstantPageStyleUnderlineItem

@end

@interface TGInstantPageStyleStrikethroughItem : NSObject

@end

@implementation TGInstantPageStyleStrikethroughItem

@end

@interface TGInstantPageStyleTextColorItem : NSObject

@property (nonatomic, strong, readonly) UIColor *color;

@end

@implementation TGInstantPageStyleTextColorItem

- (instancetype)initWithColor:(UIColor *)color {
    self = [super init];
    if (self != nil) {
        _color = color;
    }
    return self;
}

@end

@interface TGInstantPageStyleStack : NSObject {
    NSMutableArray *_items;
}

@end

@implementation TGInstantPageStyleStack

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)pushItem:(id)item {
    [_items addObject:item];
}

- (void)popItem {
    [_items removeLastObject];
}

- (NSDictionary *)textAttributes {
    NSNumber *fontSize = nil;
    NSNumber *serif = nil;
    NSNumber *fixed = nil;
    NSNumber *bold = nil;
    NSNumber *italic = nil;
    NSNumber *strikethrough = nil;
    NSNumber *underline = nil;
    UIColor *color = nil;
    NSNumber *lineSpacingFactor = nil;
    for (id item in _items.reverseObjectEnumerator) {
        if (fontSize == nil && [item isKindOfClass:[TGInstantPageStyleFontSizeItem class]]) {
            fontSize = @(((TGInstantPageStyleFontSizeItem *)item).size);
        } else if (serif == nil && [item isKindOfClass:[TGInstantPageStyleFontSerifItem class]]) {
            serif = @(((TGInstantPageStyleFontSerifItem *)item).serif);
        } else if (bold == nil && [item isKindOfClass:[TGInstantPageStyleBoldItem class]]) {
            bold = @(true);
        } else if (italic == nil && [item isKindOfClass:[TGInstantPageStyleItalicItem class]]) {
            italic = @(true);
        } else if (strikethrough == nil && [item isKindOfClass:[TGInstantPageStyleStrikethroughItem class]]) {
            strikethrough = @(true);
        } else if (underline == nil && [item isKindOfClass:[TGInstantPageStyleUnderlineItem class]]) {
            underline = @(true);
        } else if (color == nil && [item isKindOfClass:[TGInstantPageStyleTextColorItem class]]) {
            color = ((TGInstantPageStyleTextColorItem *)item).color;
        } else if (lineSpacingFactor == nil && [item isKindOfClass:[TGInstantPageStyleLineSpacingFactorItem class]]) {
            lineSpacingFactor = @(((TGInstantPageStyleLineSpacingFactorItem *)item).factor);
        } else if (fixed == nil && [item isKindOfClass:[TGInstantPageStyleFontFixedItem class]]) {
            fixed = @(((TGInstantPageStyleFontFixedItem *)item).fixed);
        }
    }
    
    if (iosMajorVersion() <= 6) {
        fixed = nil;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    CGFloat parsedFontSize = fontSize == nil ? 16.0f : [fontSize floatValue];
    if (bold && italic) {
        if ([serif boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Georgia-BoldItalic" size:parsedFontSize];
        } else if ([fixed boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Menlo-BoldItalic" size:parsedFontSize];
        } else {
            attributes[NSFontAttributeName] = TGBoldSystemFontOfSize(parsedFontSize);
        }
    } else if (bold) {
        if ([serif boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Georgia-Bold" size:parsedFontSize];
        } else if ([fixed boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Menlo-Bold" size:parsedFontSize];
        } else {
            attributes[NSFontAttributeName] = TGBoldSystemFontOfSize(parsedFontSize);
        }
    } else if (italic) {
        if ([serif boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Georgia-Italic" size:parsedFontSize];
        } else if ([fixed boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Menlo-Italic" size:parsedFontSize];
        } else {
            attributes[NSFontAttributeName] = TGItalicSystemFontOfSize(parsedFontSize);
        }
    } else {
        if ([serif boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Georgia" size:parsedFontSize];
        } else if ([fixed boolValue]) {
            attributes[NSFontAttributeName] = [UIFont fontWithName:@"Menlo" size:parsedFontSize];
        } else {
            attributes[NSFontAttributeName] = TGSystemFontOfSize(parsedFontSize);
        }
    }
    
    if ([strikethrough boolValue]) {
        attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle | NSUnderlinePatternSolid);
    }
    
    if ([underline boolValue]) {
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    
    if (color != nil) {
        attributes[NSForegroundColorAttributeName] = color;
    } else {
        attributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    }
    
    if (lineSpacingFactor != nil) {
        attributes[TGLineSpacingFactorAttribute] = lineSpacingFactor;
    }
    
    return attributes;
}

@end

@interface TGInstantPageTextUrlItem : NSObject

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, strong, readonly) id item;

@end

@implementation TGInstantPageTextUrlItem

- (instancetype)initWithFrame:(CGRect)frame item:(id)item {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _item = item;
    }
    return self;
}

@end

@interface TGInstantPageTextStrikethroughItem : NSObject

@property (nonatomic, readonly) CGRect frame;

@end

@implementation TGInstantPageTextStrikethroughItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self != nil) {
        _frame = frame;
    }
    return self;
}

@end

@interface TGInstantPageTextLine : NSObject {
    @public
    CTLineRef _line;
}

@property (nonatomic) CGRect frame;
@property (nonatomic, strong, readonly) NSArray<TGInstantPageTextUrlItem *> *urlItems;
@property (nonatomic, strong, readonly) NSArray<TGInstantPageTextStrikethroughItem *> *strikethroughItems;

@end

@implementation TGInstantPageTextLine

- (instancetype)initWithLine:(CTLineRef)line frame:(CGRect)frame urlItems:(NSArray<TGInstantPageTextUrlItem *> *)urlItems strikethroughItems:(NSArray<TGInstantPageTextStrikethroughItem *> *)strikethroughItems {
    self = [super init];
    if (self != nil) {
        _line = CFRetain(line);
        _frame = frame;
        _urlItems = urlItems;
        _strikethroughItems = strikethroughItems;
    }
    return self;
}

- (void)dealloc {
    if (_line != NULL) {
        CFRelease(_line);
    }
}

@end

@interface TGInstantPageAnchorItem : NSObject <TGInstantPageLayoutItem> {
    NSString *_anchor;
}

@property (nonatomic) CGRect frame;

@end

@implementation TGInstantPageAnchorItem

- (instancetype)initWithFrame:(CGRect)frame anchor:(NSString *)anchor {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _anchor = anchor;
    }
    return self;
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

- (bool)matchesAnchor:(NSString *)anchor {
    return [_anchor isEqualToString:anchor];
}

@end

@interface TGInstantPageMediaItem : NSObject <TGInstantPageLayoutItem> {
    TGInstantPageMedia *_media;
    TGInstantPageMediaArguments *_arguments;
}

@property (nonatomic) CGRect frame;

@end

@implementation TGInstantPageMediaItem

- (instancetype)initWithFrame:(CGRect)frame media:(TGInstantPageMedia *)media arguments:(TGInstantPageMediaArguments *)arguments {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _media = media;
        _arguments = arguments;
    }
    return self;
}

- (UIView<TGInstantPageDisplayView> *)view {
    return [[TGInstantPageImageView alloc] initWithFrame:_frame media:_media arguments:_arguments];
}

- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view {
    if ([view isKindOfClass:[TGInstantPageImageView class]]) {
        return [((TGInstantPageImageView *)view).media isEqual:_media];
    } else {
        return false;
    }
}

- (int32_t)distanceThresholdGroup {
    return TGDistanceThresholdGroupMedia;
}

- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *,NSNumber *> *)groupCount {
    if ([groupCount[@(TGDistanceThresholdGroupMedia)] intValue] <= 3) {
        return CGFLOAT_MAX;
    } else {
        return 120.0f;
    }
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    if (_media.index == -1) {
        return nil;
    } else {
        return @[_media];
    }
}

@end

@interface TGInstantPageEmbedItem : NSObject <TGInstantPageLayoutItem> {
    NSString *_url;
    NSString *_html;
    TGImageMediaAttachment *_posterMedia;
    TGPIPSourceLocation *_location;
    bool _enableScrolling;
}

@property (nonatomic) CGRect frame;

@end

@implementation TGInstantPageEmbedItem

- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url html:(NSString *)html posterMedia:(TGImageMediaAttachment *)posterMedia location:(TGPIPSourceLocation *)location enableScrolling:(bool)enableScrolling {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _url = url;
        _html = html;
        _posterMedia = posterMedia;
        _location = location;
        _enableScrolling = enableScrolling;
    }
    return self;
}

- (UIView<TGInstantPageDisplayView> *)view {
    return [[TGInstantPageEmbedView alloc] initWithFrame:_frame url:_url html:_html posterMedia:_posterMedia location:_location enableScrolling:_enableScrolling];
}

- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view {
    if ([view isKindOfClass:[TGInstantPageEmbedView class]]) {
        return TGStringCompare(_html, ((TGInstantPageEmbedView *)view).html) || TGStringCompare(_url, ((TGInstantPageEmbedView *)view).url);
    } else {
        return false;
    }
}

- (bool)matchesEmbedIndex:(int32_t)embedIndex {
    return _location.localId == embedIndex;
}

- (int32_t)distanceThresholdGroup {
    return TGDistanceThresholdGroupEmbed;
}

- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *,NSNumber *> *)groupCount {
    if ([groupCount[@(TGDistanceThresholdGroupEmbed)] intValue] <= 4) {
        return CGFLOAT_MAX;
    } else {
        return 1000.0f;
    }
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

@end

@interface TGInstantPageSlideshowItem : NSObject <TGInstantPageLayoutItem> {
    NSArray<TGInstantPageMedia *> *_medias;
}

@property (nonatomic) CGRect frame;

@end

@implementation TGInstantPageSlideshowItem

- (instancetype)initWithFrame:(CGRect)frame medias:(NSArray<TGInstantPageMedia *> *)medias {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _medias = medias;
    }
    return self;
}

- (UIView<TGInstantPageDisplayView> *)view {
    return [[TGInstantPageSlideshowView alloc] initWithFrame:_frame medias:_medias];
}

- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view {
    if ([view isKindOfClass:[TGInstantPageSlideshowView class]]) {
        return [((TGInstantPageSlideshowView *)view).medias isEqualToArray:_medias];
    } else {
        return false;
    }
}

- (int32_t)distanceThresholdGroup {
    return TGDistanceThresholdGroupEmbed;
}

- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *,NSNumber *> *)groupCount {
    if ([groupCount[@(TGDistanceThresholdGroupEmbed)] intValue] <= 4) {
        return CGFLOAT_MAX;
    } else {
        return 1000.0f;
    }
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return _medias;
}

@end

@interface TGInstantPageAudioItem : NSObject <TGInstantPageLayoutItem> {
    TGDocumentMediaAttachment *_document;
}

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) TGInstantPagePresentation *presentation;

@end

@implementation TGInstantPageAudioItem

- (instancetype)initWithFrame:(CGRect)frame document:(TGDocumentMediaAttachment *)document presentation:(TGInstantPagePresentation *)presentation {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _document = document;
        _presentation = presentation;
    }
    return self;
}

- (UIView<TGInstantPageDisplayView> *)view {
    return [[TGInstantPageAudioView alloc] initWithFrame:_frame document:_document presentation:_presentation];
}

- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view {
    if ([view isKindOfClass:[TGInstantPageAudioView class]]) {
        return ((TGInstantPageAudioView *)view).document.documentId == _document.documentId;
    } else {
        return false;
    }
}

- (int32_t)distanceThresholdGroup {
    return TGDistanceThresholdGroupMedia;
}

- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *,NSNumber *> *)groupCount {
    if ([groupCount[@(TGDistanceThresholdGroupMedia)] intValue] <= 3) {
        return CGFLOAT_MAX;
    } else {
        return 120.0f;
    }
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

- (NSArray<TGDocumentMediaAttachment *> *)audios {
    if (_document != nil) {
        return @[_document];
    } else {
        return nil;
    }
}

@end

@interface TGInstantPageTextItem : NSObject <TGInstantPageLayoutItem> {
    @public NSArray<TGInstantPageTextLine *> *_lines;
    bool _hasLinks;
    NSString *_text;
    NSMutableSet *_rtlStrings;
}

@property (nonatomic) CGRect frame;
@property (nonatomic) NSTextAlignment alignment;
@property (nonatomic, readonly) bool containsRTL;

@end

@implementation TGInstantPageTextItem

- (instancetype)initWithFrame:(CGRect)frame lines:(NSArray<TGInstantPageTextLine *> *)lines text:(NSString *)text {
    self = [super init];
    if (self != nil) {
        _alignment = NSTextAlignmentNatural;
        _frame = frame;
        _lines = lines;
        _text = text;
        
        NSMutableSet *rtlStrings = [[NSMutableSet alloc] init];
        
        NSInteger index = -1;
        for (TGInstantPageTextLine *line in lines) {
            index++;
            
            if (line.urlItems != nil) {
                _hasLinks = true;
            }
            CFArrayRef glyphRuns = CTLineGetGlyphRuns(line->_line);
            CFIndex count = CFArrayGetCount(glyphRuns);
            if (count != 0) {
                for (CFIndex i = 0; i < count; i++){
                    if (CTRunGetStatus((CTRunRef)CFArrayGetValueAtIndex(glyphRuns, i)) & kCTRunStatusRightToLeft) {
                        [rtlStrings addObject:@(index)];
                        _containsRTL = true;
                        break;
                    }
                }
            }
        }
        
        if (rtlStrings.count != 0) {
            _rtlStrings = rtlStrings;
        }
    }
    return self;
}

- (void)drawInTile {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0f, -1.0f));
    CGContextTranslateCTM(context, _frame.origin.x, _frame.origin.y);
    
    CGRect clipRect = CGContextGetClipBoundingBox(context);
    
    CGFloat upperOriginBound = clipRect.origin.y - 10.0f;
    CGFloat lowerOriginBound = clipRect.origin.y + clipRect.size.height + 10.0f;
    CGFloat boundsWidth = _frame.size.width;
    
    NSInteger index = -1;
    for (TGInstantPageTextLine *line in _lines) {
        index++;
        
        CGRect lineFrame = line.frame;
        if (lineFrame.origin.y + lineFrame.size.height < upperOriginBound || lineFrame.origin.y > lowerOriginBound) {
            continue;
        }
        
        CGPoint lineOrigin = lineFrame.origin;
        if (_alignment == NSTextAlignmentCenter) {
            lineOrigin.x = CGFloor((boundsWidth - lineFrame.size.width) / 2.0f);
        } else if (_alignment == NSTextAlignmentRight) {
            lineOrigin.x = boundsWidth - lineFrame.size.width;
        } else if (_alignment == NSTextAlignmentNatural && [_rtlStrings containsObject:@(index)]) {
            lineOrigin.x = boundsWidth - lineFrame.size.width;
        }
        
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y + lineFrame.size.height);
        CTLineDraw(line->_line, context);
        
        if (line.strikethroughItems != nil) {
            for (TGInstantPageTextStrikethroughItem *item in line.strikethroughItems) {
                CGContextFillRect(context, CGRectMake(item.frame.origin.x, item.frame.origin.y + CGFloor((lineFrame.size.height) / 2.0f + 1.0f), item.frame.size.width, 1.0f));
            }
        }
    }
    
    CGContextRestoreGState(context);
}

- (bool)hasLinks {
    return _hasLinks;
}

- (bool)hasText {
    return true;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

static TGInstantPageLinkSelectionView *linkSelectionViewFromFrames(NSArray<NSValue *> *frames, CGPoint origin, id urlItem) {
    CGRect frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    bool first = true;
    for (NSValue *rectValue in frames) {
        CGRect rect = CGRectIntegral([rectValue CGRectValue]);
        rect.size.height += 2.0f;
        
        if (first) {
            first = false;
            frame = rect;
        } else {
            frame = CGRectUnion(rect, frame);
        }
    }
    NSMutableArray *adjustedFrames = [[NSMutableArray alloc] init];
    for (NSValue *rectValue in frames) {
        CGRect rect = CGRectIntegral([rectValue CGRectValue]);
        rect.origin.x -= frame.origin.x;
        rect.origin.y -= frame.origin.y;
        rect.size.height += 2.0f;
        [adjustedFrames addObject:[NSValue valueWithCGRect:rect]];
    }
    return [[TGInstantPageLinkSelectionView alloc] initWithFrame:CGRectOffset(frame, origin.x, origin.y) rects:adjustedFrames urlItem:urlItem];
}

static TGInstantPageTextSelectionView *textSelectionViewFromFrames(NSArray<NSValue *> *frames, CGPoint origin, NSString *text) {
    CGRect frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    bool first = true;
    for (NSValue *rectValue in frames) {
        CGRect rect = [rectValue CGRectValue];
        rect.size.height += 2.0f;
        
        if (first) {
            first = false;
            frame = CGRectOffset(rect, 0.0f, -2.0f);
        } else {
            frame = CGRectUnion(rect, frame);
        }
    }
    NSMutableArray *adjustedFrames = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < frames.count; i++) {
        CGRect rect = [frames[i] CGRectValue];
        
        rect.origin.x -= frame.origin.x;
        rect.origin.y -= frame.origin.y;
        
        CGRect previousRect = i > 0 ? [frames[i - 1] CGRectValue] : CGRectNull;
        CGRect nextRect = i < frames.count - 1 ? [frames[i + 1] CGRectValue] : CGRectNull;
        CGFloat offset = 0.0f;
        
        if (!CGRectIsNull(previousRect)) {
            previousRect.origin.x -= frame.origin.x;
            previousRect.origin.y -= frame.origin.y;
            
            offset = ((rect.origin.y - CGRectGetMaxY(previousRect) - 8.0f) / 2.0f) + 1.0f;
            rect.origin.y -= offset;
        }
        if (!CGRectIsNull(nextRect)) {
            nextRect.origin.x -= frame.origin.x;
            nextRect.origin.y -= frame.origin.y;
            
            rect.size.width = frame.size.width;
            rect.size.height += (nextRect.origin.y - CGRectGetMaxY(rect) - 8.0f) / 2.0f + 1.0f;
        } else {
            rect.size.height += 2.0f;
        }
        rect.size.height += offset;
        
        [adjustedFrames addObject:[NSValue valueWithCGRect:rect]];
        
    }

    return [[TGInstantPageTextSelectionView alloc] initWithFrame:CGRectOffset(frame, origin.x, origin.y) rects:adjustedFrames text:text];
}

- (TGInstantPageTextSelectionView *)textSelectionView {
    NSMutableArray<NSValue *> *currentTextFrames = [[NSMutableArray alloc] init];
    
    NSInteger index = -1;
    for (TGInstantPageTextLine *line in _lines) {
        index++;
        
        CGPoint lineOrigin = line.frame.origin;
        if (_alignment == NSTextAlignmentCenter) {
            lineOrigin.x = CGFloor((self.frame.size.width - line.frame.size.width) / 2.0f);
        } else if (_alignment == NSTextAlignmentRight) {
            lineOrigin.x = self.frame.size.width - line.frame.size.width;
        } else if (_alignment == NSTextAlignmentNatural && _containsRTL && [_rtlStrings containsObject:@(index)]) {
            lineOrigin.x = self.frame.size.width - line.frame.size.width;
        }

        [currentTextFrames addObject:[NSValue valueWithCGRect:CGRectOffset(line.frame, lineOrigin.x, 0.0)]];
    }
        
    return textSelectionViewFromFrames(currentTextFrames, self.frame.origin, _text);
}

- (NSArray<TGInstantPageLinkSelectionView *> *)linkSelectionViews {
    if (_hasLinks) {
        NSMutableArray<TGInstantPageLinkSelectionView *> *views = [[NSMutableArray alloc] init];
        NSMutableArray<NSValue *> *currentLinkFrames = [[NSMutableArray alloc] init];
        id currentUrlItem = nil;
        NSInteger index = -1;
        for (TGInstantPageTextLine *line in _lines) {
            index++;
            
            if (line.urlItems != nil) {
                for (TGInstantPageTextUrlItem *urlItem in line.urlItems) {
                    if (currentUrlItem == urlItem.item) {
                    } else {
                        if (currentLinkFrames.count != 0) {
                            [views addObject:linkSelectionViewFromFrames(currentLinkFrames, self.frame.origin, currentUrlItem)];
                        }
                        [currentLinkFrames removeAllObjects];
                        currentUrlItem = urlItem.item;
                    }
                    CGPoint lineOrigin = line.frame.origin;
                    if (_alignment == NSTextAlignmentCenter) {
                        lineOrigin.x = CGFloor((self.frame.size.width - line.frame.size.width) / 2.0f);
                    } else if (_alignment == NSTextAlignmentRight) {
                        lineOrigin.x = self.frame.size.width - line.frame.size.width;
                    } else if (_alignment == NSTextAlignmentNatural && _containsRTL && [_rtlStrings containsObject:@(index)]) {
                        lineOrigin.x = self.frame.size.width - line.frame.size.width;
                    }
                    [currentLinkFrames addObject:[NSValue valueWithCGRect:CGRectOffset(urlItem.frame, lineOrigin.x, 0.0)]];
                }
            } else if (currentUrlItem != nil) {
                if (currentLinkFrames.count != 0) {
                    [views addObject:linkSelectionViewFromFrames(currentLinkFrames, self.frame.origin, currentUrlItem)];
                }
                [currentLinkFrames removeAllObjects];
                currentUrlItem = nil;
            }
        }
        if (currentLinkFrames.count != 0 && currentUrlItem != nil) {
            [views addObject:linkSelectionViewFromFrames(currentLinkFrames, self.frame.origin, currentUrlItem)];
        }
        return views;
    }
    return nil;
}

@end

typedef enum {
    TGInstantPageShapeRect,
    TGInstantPageShapeEllipse,
    TGInstantPageShapeRoundLine
} TGInstantPageShape;

@interface TGInstantPageShapeItem : NSObject <TGInstantPageLayoutItem>

@property (nonatomic) CGRect frame;
@property (nonatomic) CGRect shapeFrame;
@property (nonatomic, readonly) TGInstantPageShape shape;
@property (nonatomic, strong, readonly) UIColor *color;

@end

@implementation TGInstantPageShapeItem

- (instancetype)initWithFrame:(CGRect)frame shapeFrame:(CGRect)shapeFrame shape:(TGInstantPageShape)shape color:(UIColor *)color {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _shapeFrame = shapeFrame;
        _shape = shape;
        _color = color;
    }
    return self;
}

- (void)drawInTile {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [_color CGColor]);
    switch (_shape) {
        case TGInstantPageShapeRect:
            CGContextFillRect(context, CGRectOffset(_shapeFrame, _frame.origin.x, _frame.origin.y));
            break;
        case TGInstantPageShapeEllipse:
            CGContextFillEllipseInRect(context, CGRectOffset(_shapeFrame, _frame.origin.x, _frame.origin.y));
            break;
        case TGInstantPageShapeRoundLine: {
            if (_frame.size.width < _frame.size.height) {
                CGFloat radius = _frame.size.width / 2.0f;
                CGRect shapeFrame = CGRectOffset(_shapeFrame, _frame.origin.x, _frame.origin.y);
                shapeFrame.origin.y += radius;
                shapeFrame.size.height -= radius + radius;
                CGContextFillRect(context, shapeFrame);
                CGContextFillEllipseInRect(context, CGRectMake(shapeFrame.origin.x, shapeFrame.origin.y - radius, radius + radius, radius + radius));
                CGContextFillEllipseInRect(context, CGRectMake(shapeFrame.origin.x, shapeFrame.origin.y + shapeFrame.size.height - radius, radius + radius, radius + radius));
            } else {
                CGRect shapeFrame = CGRectOffset(_shapeFrame, _frame.origin.x, _frame.origin.y);
                CGContextFillRect(context, shapeFrame);
            }
            break;
        }
    }
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

@end

@interface TGInstantPageFooterButtonItem : NSObject <TGInstantPageLayoutItem> {
}

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) TGInstantPagePresentation *presentation;

@end

@implementation TGInstantPageFooterButtonItem

- (instancetype)initWithFrame:(CGRect)frame presentation:(TGInstantPagePresentation *)presentation {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _presentation = presentation;
    }
    return self;
}

- (UIView<TGInstantPageDisplayView> *)view {
    return [[TGInstantPageFooterButtonView alloc] initWithFrame:_frame presentation:_presentation];
}

- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view {
    if ([view isKindOfClass:[TGInstantPageFooterButtonView class]]) {
        return true;
    } else {
        return false;
    }
}

- (int32_t)distanceThresholdGroup {
    return 1000;
}

- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *,NSNumber *> *)__unused groupCount {
    return 1000.0f;
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

@end

@interface TGInstantPageChannelItem : NSObject <TGInstantPageLayoutItem> {
}

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) TGConversation *channel;
@property (nonatomic, readonly) bool overlay;
@property (nonatomic, strong) TGInstantPagePresentation *presentation;

@end

@implementation TGInstantPageChannelItem

- (instancetype)initWithFrame:(CGRect)frame channel:(TGConversation *)channel overlay:(bool)overlay presentation:(TGInstantPagePresentation *)presentation {
    self = [super init];
    if (self != nil) {
        _frame = frame;
        _channel = channel;
        _overlay = overlay;
        _presentation = presentation;
    }
    return self;
}

- (UIView<TGInstantPageDisplayView> *)view {
    return [[TGInstantPageChannelView alloc] initWithFrame:_frame channel:_channel overlay:_overlay presentation:_presentation];
}

- (bool)matchesView:(UIView<TGInstantPageDisplayView> *)view {
    if ([view isKindOfClass:[TGInstantPageChannelView class]]) {
        return true;
    } else {
        return false;
    }
}

- (int32_t)distanceThresholdGroup {
    return 1000;
}

- (CGFloat)distanceThresholdWithGroupCount:(NSDictionary<NSNumber *,NSNumber *> *)__unused groupCount {
    return 1000.0f;
}

- (bool)hasLinks {
    return false;
}

- (NSArray<TGInstantPageMedia *> *)medias {
    return nil;
}

@end


@implementation TGInstantPageLayout

- (instancetype)initWithOrigin:(CGPoint)origin contentSize:(CGSize)contentSize items:(NSArray<id<TGInstantPageLayoutItem> > *)items {
    self = [super init];
    if (self != nil) {
        _origin = origin;
        _contentSize = contentSize;
        _items = items;
    }
    return self;
}

- (NSArray *)flattenedItemsWithOrigin:(CGPoint)origin {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (id<TGInstantPageLayoutItem> item in _items) {
        item.frame = CGRectOffset(item.frame, origin.x, origin.y);
        [items addObject:item];
    }
    return items;
}

+ (NSAttributedString *)attributedStringForRichText:(TGRichText *)text styleStack:(TGInstantPageStyleStack *)styleStack {
    if ([text isKindOfClass:[TGRichTextPlain class]]) {
        return [[NSAttributedString alloc] initWithString:((TGRichTextPlain *)text).text == nil ? @"" : ((TGRichTextPlain *)text).text attributes:[styleStack textAttributes]];
    } else if ([text isKindOfClass:[TGRichTextBold class]]) {
        [styleStack pushItem:[[TGInstantPageStyleBoldItem alloc] init]];
        NSAttributedString *result = [self attributedStringForRichText:((TGRichTextBold *)text).text styleStack:styleStack];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextItalic class]]) {
        [styleStack pushItem:[[TGInstantPageStyleItalicItem alloc] init]];
        NSAttributedString *result = [self attributedStringForRichText:((TGRichTextItalic *)text).text styleStack:styleStack];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextUnderline class]]) {
        [styleStack pushItem:[[TGInstantPageStyleUnderlineItem alloc] init]];
        NSAttributedString *result = [self attributedStringForRichText:((TGRichTextUnderline *)text).text styleStack:styleStack];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextStrikethrough class]]) {
        [styleStack pushItem:[[TGInstantPageStyleStrikethroughItem alloc] init]];
        NSAttributedString *result = [self attributedStringForRichText:((TGRichTextStrikethrough *)text).text styleStack:styleStack];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextFixed class]]) {
        [styleStack pushItem:[[TGInstantPageStyleFontFixedItem alloc] initWithFixed:true]];
        NSAttributedString *result = [self attributedStringForRichText:((TGRichTextFixed *)text).text styleStack:styleStack];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextUrl class]]) {
        [styleStack pushItem:[[TGInstantPageStyleUnderlineItem alloc] init]];
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringForRichText:((TGRichTextUrl *)text).text styleStack:styleStack]];
        [result addAttribute:(NSString *)TGUrlAttribute value:text range:NSMakeRange(0, result.length)];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextEmail class]]) {
        [styleStack pushItem:[[TGInstantPageStyleUnderlineItem alloc] init]];
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringForRichText:((TGRichTextEmail *)text).text styleStack:styleStack]];
        [result addAttribute:(NSString *)TGUrlAttribute value:text range:NSMakeRange(0, result.length)];
        [styleStack popItem];
        return result;
    } else if ([text isKindOfClass:[TGRichTextCollection class]]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
        for (TGRichText *subtext in ((TGRichTextCollection *)text).texts) {
            NSAttributedString *substring = [self attributedStringForRichText:subtext styleStack:styleStack];
            if (substring != nil) {
                [string appendAttributedString:substring];
            }
        }
        return string;
    } else {
        return nil;
    }
}

+ (TGInstantPageTextItem *)layoutTextItemWithString:(NSAttributedString *)string boundingWidth:(CGFloat)boundingWidth {
    if (string.length == 0) {
        return [[TGInstantPageTextItem alloc] initWithFrame:CGRectZero lines:@[] text:nil];
    }
    NSMutableArray<TGInstantPageTextLine *> *lines = [[NSMutableArray alloc] init];
    UIFont *font = [string attribute:NSFontAttributeName atIndex:0 longestEffectiveRange:nil inRange:NSMakeRange(0, string.length)];
    if (font == nil) {
        return [[TGInstantPageTextItem alloc] initWithFrame:CGRectZero lines:@[] text:nil];
    }
    CGFloat lineSpacingFactor = 1.12f;
    NSNumber *lineSpacingFactorAttribute = [string attribute:(NSString *)TGLineSpacingFactorAttribute atIndex:0 longestEffectiveRange:nil inRange:NSMakeRange(0, string.length)];
    if (lineSpacingFactorAttribute != nil) {
        lineSpacingFactor = [lineSpacingFactorAttribute floatValue];
    }
    
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    if (typesetter != nil) {
        NSAssert(font != nil, @"font != nil");
        CGFloat fontAscent = font.ascender;
        CGFloat fontDescent = font.descender;
        
        CGFloat fontLineHeight = CGFloor(fontAscent + fontDescent);
        
        CGFloat fontLineSpacing = CGFloor(fontLineHeight * lineSpacingFactor);
        
        CFIndex lastIndex = 0;
        CGPoint currentLineOrigin = CGPointMake(0.0f, 0.0f);
        
        while (true) {
            CGFloat currentMaxWidth = boundingWidth - currentLineOrigin.x;
            CGFloat currentLineInset = 0.0f;
            
            CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(typesetter, lastIndex, currentMaxWidth);
            
            if (lineCharacterCount > 0) {
                CTLineRef line = CTTypesetterCreateLineWithOffset(typesetter, CFRangeMake(lastIndex, lineCharacterCount), 100.0);
                
                if (line != NULL) {
                    __unused CGFloat trailingWhitespace = (CGFloat)CTLineGetTrailingWhitespaceWidth(line);
                    CGFloat lineWidth = (CGFloat)CTLineGetTypographicBounds(line, NULL, NULL, NULL) + currentLineInset;
                    
                    __block NSMutableArray<TGInstantPageTextUrlItem *> *urlItems = nil;
                    [string enumerateAttribute:(NSString *)TGUrlAttribute inRange:NSMakeRange(lastIndex, lineCharacterCount) options:0 usingBlock:^(id item, NSRange range, __unused BOOL *stop) {
                        if (item != nil) {
                            if (urlItems == nil) {
                                urlItems = [[NSMutableArray alloc] init];
                            }
                            CGFloat lowerX = CGFloor(CTLineGetOffsetForStringIndex(line, range.location, NULL));
                            CGFloat upperX = CGCeil(CTLineGetOffsetForStringIndex(line, range.location + range.length, NULL));
                            [urlItems addObject:[[TGInstantPageTextUrlItem alloc] initWithFrame:CGRectMake(currentLineOrigin.x + lowerX, currentLineOrigin.y, upperX - lowerX, fontLineHeight) item:item]];
                        }
                    }];
                    
                    __block NSMutableArray<TGInstantPageTextStrikethroughItem *> *strikethroughItems = nil;
                    [string enumerateAttribute:NSStrikethroughStyleAttributeName inRange:NSMakeRange(lastIndex, lineCharacterCount) options:0 usingBlock:^(id item, NSRange range, __unused BOOL *stop) {
                        if (item != nil) {
                            if (strikethroughItems == nil) {
                                strikethroughItems = [[NSMutableArray alloc] init];
                            }
                            CGFloat lowerX = CGFloor(CTLineGetOffsetForStringIndex(line, range.location, NULL));
                            CGFloat upperX = CGCeil(CTLineGetOffsetForStringIndex(line, range.location + range.length, NULL));
                            [strikethroughItems addObject:[[TGInstantPageTextStrikethroughItem alloc] initWithFrame:CGRectMake(currentLineOrigin.x + lowerX, currentLineOrigin.y, upperX - lowerX, fontLineHeight)]];
                        }
                    }];
                    
                    TGInstantPageTextLine *textLine = [[TGInstantPageTextLine alloc] initWithLine:line frame:CGRectMake(currentLineOrigin.x, currentLineOrigin.y, lineWidth, fontLineHeight) urlItems:urlItems strikethroughItems:strikethroughItems];
                    CFRelease(line);
                    [lines addObject:textLine];
                    
                    bool rightAligned = false;
                    
                    CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
                    if (CFArrayGetCount(glyphRuns) != 0) {
                        if (CTRunGetStatus((CTRunRef)CFArrayGetValueAtIndex(glyphRuns, 0)) & kCTRunStatusRightToLeft)
                            rightAligned = true;
                    }
                    
                    //hadRTL |= rightAligned;
                    
                    currentLineOrigin.x = 0.0f;
                    currentLineOrigin.y += fontLineHeight + fontLineSpacing;
                    
                    lastIndex += lineCharacterCount;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        
        CFRelease(typesetter);
    }
    
    CGFloat height = 0.0f;
    if (lines.count != 0) {
        height = CGRectGetMaxY(lines.lastObject.frame);
    }
    
    return [[TGInstantPageTextItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundingWidth, height) lines:lines text:string.string];
}

+ (TGInstantPageLayout *)layoutBlock:(TGInstantPageBlock *)block boundingWidth:(CGFloat)boundingWidth horizontalInset:(CGFloat)horizontalInset isCover:(bool)isCover previousItems:(NSArray *)previousItems fillToWidthAndHeight:(bool)fillToWidthAndHeight images:(NSDictionary<NSNumber *, TGImageMediaAttachment *> *)images videos:(NSDictionary<NSNumber *, TGVideoMediaAttachment *> *)videos documents:(NSDictionary<NSNumber *, TGDocumentMediaAttachment *> *)documents webPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId mediaIndexCounter:(NSInteger *)mediaIndexCounter embedIndexCounter:(NSInteger *)embedIndexCounter overlay:(bool)overlay presentation:(TGInstantPagePresentation *)presentation {
    CGFloat multiplier = presentation.fontSizeMultiplier;
    
    if ([block isKindOfClass:[TGInstantPageBlockCover class]]) {
        return [self layoutBlock:((TGInstantPageBlockCover *)block).block boundingWidth:boundingWidth horizontalInset:horizontalInset isCover:true previousItems:previousItems fillToWidthAndHeight:fillToWidthAndHeight images:images videos:videos documents:documents webPage:webPage peerId:peerId messageId:messageId mediaIndexCounter:mediaIndexCounter embedIndexCounter:embedIndexCounter overlay:overlay presentation:presentation];
    } else if ([block isKindOfClass:[TGInstantPageBlockTitle class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(28.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        [styleStack pushItem:[[TGInstantPageStyleLineSpacingFactorItem alloc] initWithFactor:0.685f]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.titleColor]];
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockTitle *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockSubtitle class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.titleColor]];
        if (presentation.fontSerif)
            [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockSubtitle *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockAuthorAndDate class]]) {
        TGInstantPageBlockAuthorAndDate *authorAndDateBlock = (TGInstantPageBlockAuthorAndDate *)block;
        
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
        if (presentation.fontSerif)
            [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        
        TGRichText *text = nil;
        NSString *dateStringPlain = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:authorAndDateBlock.date] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
        TGRichText *dateText = [[TGRichTextPlain alloc] initWithText:dateStringPlain];
        if (richPlainText(authorAndDateBlock.author).length > 0) {
            if (authorAndDateBlock.date != 0) {
                NSString *formatString = TGLocalized(@"InstantPage.AuthorAndDateTitle");
                NSRange authorRange = [formatString rangeOfString:@"%1$@"];
                NSRange dateRange = [formatString rangeOfString:@"%2$@"];
                if (authorRange.location < dateRange.location) {
                    NSString *byPart = [formatString substringToIndex:authorRange.location];
                    NSString *middlePart = [formatString substringWithRange:NSMakeRange(authorRange.location + authorRange.length, dateRange.location - authorRange.location - authorRange.length)];
                    NSString *endPart = [formatString substringFromIndex:dateRange.location + dateRange.length];
                    
                    TGRichText *byText = [[TGRichTextPlain alloc] initWithText:byPart];
                    TGRichText *middleText = [[TGRichTextPlain alloc] initWithText:middlePart];
                    TGRichText *endText = [[TGRichTextPlain alloc] initWithText:endPart];
                    
                    text = [[TGRichTextCollection alloc] initWithTexts:@[byText, authorAndDateBlock.author, middleText, dateText, endText]];
                } else {
                    NSString *beforePart = [formatString substringToIndex:dateRange.location];
                    NSString *middlePart = [formatString substringWithRange:NSMakeRange(dateRange.location + dateRange.length, authorRange.location - dateRange.location - dateRange.length)];
                    NSString *endPart = [formatString substringFromIndex:authorRange.location + authorRange.length];
                    
                    TGRichText *beforeText = [[TGRichTextPlain alloc] initWithText:beforePart];
                    TGRichText *middleText = [[TGRichTextPlain alloc] initWithText:middlePart];
                    TGRichText *endText = [[TGRichTextPlain alloc] initWithText:endPart];
                    
                    text = [[TGRichTextCollection alloc] initWithTexts:@[beforeText, dateText, middleText, authorAndDateBlock.author, endText]];
                }
            } else {
                text = authorAndDateBlock.author;
            }
        } else {
            if (authorAndDateBlock.date != 0) {
                text = dateText;
            }
        }
        
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        
        if ([previousItems.lastObject isKindOfClass:[TGInstantPageTextItem class]]) {
            if (((TGInstantPageTextItem *)previousItems.lastObject).containsRTL) {
                item.alignment = NSTextAlignmentRight;
            }
        }
        
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockHeader class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(24.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        [styleStack pushItem:[[TGInstantPageStyleLineSpacingFactorItem alloc] initWithFactor:0.685f]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockHeader *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockSubheader class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(19.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        [styleStack pushItem:[[TGInstantPageStyleLineSpacingFactorItem alloc] initWithFactor:0.685f]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockSubheader *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockParagraph class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
        if (presentation.fontSerif)
            [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockParagraph *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockPreFormatted class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(16.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleFontFixedItem alloc] initWithFixed:true]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
        
        CGFloat backgroundInset = 14.0f;
        
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockPreFormatted *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset - backgroundInset - backgroundInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, backgroundInset);
        
        TGInstantPageShapeItem *backgroundItem = [[TGInstantPageShapeItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundingWidth, item.frame.size.height + backgroundInset + backgroundInset) shapeFrame:CGRectMake(0.0f, 0.0f, boundingWidth, item.frame.size.height + backgroundInset + backgroundInset) shape:TGInstantPageShapeRect color:presentation.panelColor];
        
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:backgroundItem.frame.size items:@[backgroundItem, item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockFooter class]]) {
        TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
        [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
        [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
        if (presentation.fontSerif)
            [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
        TGInstantPageTextItem *item = [self layoutTextItemWithString:[self attributedStringForRichText:((TGInstantPageBlockFooter *)block).text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
        item.frame = CGRectOffset(item.frame, horizontalInset, 0.0f);
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:item.frame.size items:@[item]];

    } else if ([block isKindOfClass:[TGInstantPageBlockDivider class]]) {
        CGFloat lineWidth = CGFloor(boundingWidth / 2.0f);
        TGInstantPageShapeItem *shapeItem = [[TGInstantPageShapeItem alloc] initWithFrame:CGRectMake(CGFloor((boundingWidth - lineWidth) / 2.0f), 0.0f, lineWidth, 1.0f) shapeFrame:CGRectMake(0.0f, 0.0f, lineWidth, 1.0f) shape:TGInstantPageShapeRect color:[presentation.subtextColor colorWithAlphaComponent:0.4f]];
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:shapeItem.frame.size items:@[shapeItem]];
    } else if ([block isKindOfClass:[TGInstantPageBlockList class]]) {
        TGInstantPageBlockList *listBlock = (TGInstantPageBlockList *)block;
        CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
        CGFloat maxIndexWidth = 0.0f;
        NSMutableArray<id<TGInstantPageLayoutItem>> *listItems = [[NSMutableArray alloc] init];
        NSMutableArray<id<TGInstantPageLayoutItem>> *indexItems = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < listBlock.items.count; i++) {
            if (listBlock.ordered) {
                TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
                [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
                [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
                if (presentation.fontSerif)
                    [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
                
                TGInstantPageTextItem *textItem = [self layoutTextItemWithString:[self attributedStringForRichText:[[TGRichTextPlain alloc] initWithText:[NSString stringWithFormat:@"%d.", (int)i + 1]] styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
                maxIndexWidth = MAX(textItem->_lines.firstObject.frame.size.width, maxIndexWidth);
                [indexItems addObject:textItem];
            } else {
                TGInstantPageShapeItem *shapeItem = [[TGInstantPageShapeItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 6.0f, 12.0f) shapeFrame:CGRectMake(0.0f, 3.0f, 6.0f, 6.0f) shape:TGInstantPageShapeEllipse color:presentation.textColor];
                [indexItems addObject:shapeItem];
            }
        }
        NSInteger index = -1;
        CGFloat indexSpacing = listBlock.ordered ? 7.0f : 20.0f;
        for (TGRichText *text in listBlock.items) {
            index++;
            if (index != 0) {
                contentSize.height += 20.0f;
            }
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
            if (presentation.fontSerif)
                [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            
            TGInstantPageTextItem *textItem = [self layoutTextItemWithString:[self attributedStringForRichText:text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset - indexSpacing - maxIndexWidth];
            textItem.frame = CGRectOffset(textItem.frame, horizontalInset + indexSpacing + maxIndexWidth, contentSize.height);
            
            contentSize.height += textItem.frame.size.height;
            id<TGInstantPageLayoutItem> indexItem = indexItems[index];
            indexItem.frame = CGRectOffset(indexItem.frame, horizontalInset, textItem.frame.origin.y);
            [listItems addObject:indexItem];
            [listItems addObject:textItem];
        }
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:listItems];
    } else if ([block isKindOfClass:[TGInstantPageBlockBlockQuote class]]) {
        TGInstantPageBlockBlockQuote *quoteBlock = (TGInstantPageBlockBlockQuote *)block;
        CGFloat lineInset = 20.0f;
        CGFloat verticalInset = 4.0f;
        CGSize contentSize = CGSizeMake(boundingWidth, verticalInset);
        
        NSMutableArray<id<TGInstantPageLayoutItem>> *items = [[NSMutableArray alloc] init];
        
        {
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            [styleStack pushItem:[[TGInstantPageStyleItalicItem alloc] init]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
            
            TGInstantPageTextItem *textItem = [self layoutTextItemWithString:[self attributedStringForRichText:quoteBlock.text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset - lineInset];
            textItem.frame = CGRectOffset(textItem.frame, horizontalInset + lineInset, contentSize.height);
            
            contentSize.height += textItem.frame.size.height;
            [items addObject:textItem];
        }
        if (quoteBlock.caption != nil) {
            contentSize.height += 14.0f;
            {
                TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
                [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
                [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
                if (presentation.fontSerif)
                    [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
                
                TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:quoteBlock.caption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset - lineInset];
                captionItem.frame = CGRectOffset(captionItem.frame, horizontalInset + lineInset, contentSize.height);
                
                contentSize.height += captionItem.frame.size.height;
                [items addObject:captionItem];
            }
        }
        contentSize.height += verticalInset;
        [items addObject:[[TGInstantPageShapeItem alloc] initWithFrame:CGRectMake(horizontalInset, 0.0f, 3.0f, contentSize.height) shapeFrame:CGRectMake(0.0f, 0.0f, 3.0f, contentSize.height) shape:TGInstantPageShapeRoundLine color:presentation.textColor]];
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
    } else if ([block isKindOfClass:[TGInstantPageBlockPullQuote class]]) {
        TGInstantPageBlockPullQuote *quoteBlock = (TGInstantPageBlockPullQuote *)block;
        CGFloat verticalInset = 4.0f;
        CGSize contentSize = CGSizeMake(boundingWidth, verticalInset);
        
        NSMutableArray<id<TGInstantPageLayoutItem>> *items = [[NSMutableArray alloc] init];
        
        {
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            [styleStack pushItem:[[TGInstantPageStyleItalicItem alloc] init]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
            
            TGInstantPageTextItem *textItem = [self layoutTextItemWithString:[self attributedStringForRichText:quoteBlock.text styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
            textItem.frame = CGRectOffset(textItem.frame, CGFloor((boundingWidth - textItem.frame.size.width) / 2.0), contentSize.height);
            textItem.alignment = NSTextAlignmentCenter;
            
            contentSize.height += textItem.frame.size.height;
            [items addObject:textItem];
        }
        contentSize.height += 14.0f;
        {
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
            if (presentation.fontSerif)
                [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            
            TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:quoteBlock.caption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
            captionItem.frame = CGRectOffset(captionItem.frame, CGFloor((boundingWidth - captionItem.frame.size.width) / 2.0), contentSize.height);
            captionItem.alignment = NSTextAlignmentCenter;
            
            contentSize.height += captionItem.frame.size.height;
            [items addObject:captionItem];
        }
        contentSize.height += verticalInset;
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
    } else if ([block isKindOfClass:[TGInstantPageBlockPhoto class]]) {
        TGInstantPageBlockPhoto *photoBlock = (TGInstantPageBlockPhoto *)block;
        TGImageMediaAttachment *imageMedia = images[@(photoBlock.photoId)];
        if (imageMedia != nil) {
            CGSize imageSize = CGSizeZero;
            if ([imageMedia.imageInfo imageUrlForLargestSize:&imageSize] != nil) {
                CGSize filledSize = TGFitSize(imageSize, CGSizeMake(boundingWidth, 1200.0));
                if (fillToWidthAndHeight) {
                    filledSize = CGSizeMake(boundingWidth, boundingWidth);
                } else if (isCover) {
                    filledSize = TGScaleToFill(imageSize, CGSizeMake(boundingWidth, 1.0f));
                    if (filledSize.height > FLT_EPSILON) {
                        filledSize = TGCropSize(filledSize, CGSizeMake(boundingWidth, CGFloor(boundingWidth * 3.0f / 5.0f)));
                    }
                }
                
                NSMutableArray *items = [[NSMutableArray alloc] init];
                
                NSInteger mediaIndex = *mediaIndexCounter;
                (*mediaIndexCounter)++;
                
                CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
                TGImageMediaAttachment *mediaWithCaption = [imageMedia copy];
                mediaWithCaption.caption = richPlainText(photoBlock.caption);
                TGInstantPageMediaItem *mediaItem = [[TGInstantPageMediaItem alloc] initWithFrame:CGRectMake(CGFloor((boundingWidth - filledSize.width) / 2.0f), 0.0f, filledSize.width, filledSize.height) media:[[TGInstantPageMedia alloc] initWithIndex:mediaIndex media:mediaWithCaption] arguments:[[TGInstantPageImageMediaArguments alloc] initWithInteractive:true roundCorners:false fit:false]];
                [items addObject:mediaItem];
                contentSize.height += filledSize.height;
                
                if (photoBlock.caption != nil) {
                    contentSize.height += 10.0f;
                    TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
                    [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
                    [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
                    if (presentation.fontSerif)
                        [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
                    
                    TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:photoBlock.caption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
                    if (filledSize.width >= boundingWidth - FLT_EPSILON) {
                        captionItem.alignment = NSTextAlignmentCenter;
                        captionItem.frame = CGRectOffset(captionItem.frame, horizontalInset, contentSize.height);
                    } else {
                        captionItem.alignment = NSTextAlignmentCenter;
                        captionItem.frame = CGRectOffset(captionItem.frame, CGFloor((boundingWidth - captionItem.frame.size.width) / 2.0), contentSize.height);
                    }
                    contentSize.height += captionItem.frame.size.height;
                    [items addObject:captionItem];
                }
                
                return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
            }
        }
    } else if ([block isKindOfClass:[TGInstantPageBlockVideo class]]) {
        TGInstantPageBlockVideo *videoBlock = (TGInstantPageBlockVideo *)block;
        TGVideoMediaAttachment *videoMedia = videos[@(videoBlock.videoId)];
        if (videoMedia != nil) {
            CGSize imageSize = [videoMedia dimensions];
            if (imageSize.width > FLT_EPSILON && imageSize.height > FLT_EPSILON) {
                CGSize filledSize = TGFitSize(imageSize, CGSizeMake(boundingWidth, 1200.0));
                if (fillToWidthAndHeight) {
                    filledSize = CGSizeMake(boundingWidth, boundingWidth);
                } else if (isCover) {
                    filledSize = TGScaleToFill(imageSize, CGSizeMake(boundingWidth, 1.0f));
                    if (filledSize.height > FLT_EPSILON) {
                        filledSize = TGCropSize(filledSize, CGSizeMake(boundingWidth, CGFloor(boundingWidth * 3.0f / 5.0f)));
                    }
                }
                
                NSMutableArray *items = [[NSMutableArray alloc] init];
                
                NSInteger mediaIndex = *mediaIndexCounter;
                (*mediaIndexCounter)++;
                
                CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
                TGVideoMediaAttachment *videoWithCaption = [videoMedia copy];
                videoWithCaption.caption = richPlainText(videoBlock.caption);
                videoWithCaption.loopVideo = videoBlock.loop;
                TGInstantPageMediaItem *mediaItem = [[TGInstantPageMediaItem alloc] initWithFrame:CGRectMake(CGFloor((boundingWidth - filledSize.width) / 2.0f), 0.0f, filledSize.width, filledSize.height) media:[[TGInstantPageMedia alloc] initWithIndex:mediaIndex media:videoWithCaption] arguments:[[TGInstantPageVideoMediaArguments alloc] initWithInteractive:true autoplay:videoBlock.autoplay || videoBlock.loop]];
                [items addObject:mediaItem];
                contentSize.height += filledSize.height;
                
                if (videoBlock.caption != nil) {
                    contentSize.height += 10.0f;
                    TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
                    [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
                    [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
                    if (presentation.fontSerif)
                        [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
                    
                    TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:videoBlock.caption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
                    if (filledSize.width >= boundingWidth - FLT_EPSILON) {
                        captionItem.alignment = NSTextAlignmentCenter;
                        captionItem.frame = CGRectOffset(captionItem.frame, horizontalInset, contentSize.height);
                    } else {
                        captionItem.alignment = NSTextAlignmentCenter;
                        captionItem.frame = CGRectOffset(captionItem.frame, CGFloor((boundingWidth - captionItem.frame.size.width) / 2.0), contentSize.height);
                    }
                    contentSize.height += captionItem.frame.size.height;
                    [items addObject:captionItem];
                }
                
                return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
            }
        }
    } else if ([block isKindOfClass:[TGInstantPageBlockEmbed class]]) {
        TGInstantPageBlockEmbed *embedBlock = (TGInstantPageBlockEmbed *)block;
        TGImageMediaAttachment *posterMedia = images[@(embedBlock.posterPhotoId)];
        CGSize size = CGSizeZero;
        CGFloat embedBoundingWidth = boundingWidth - horizontalInset - horizontalInset;
        if (embedBlock.fillWidth) {
            embedBoundingWidth = boundingWidth;
        }
        CGSize screenSize = TGScreenSize();
        if (embedBoundingWidth > screenSize.width)
            embedBoundingWidth = screenSize.width;
        if (embedBlock.size.width < FLT_EPSILON) {
            size = CGSizeMake(embedBoundingWidth, embedBlock.size.height);
        } else {
            size = TGFitSize(embedBlock.size, CGSizeMake(embedBoundingWidth, embedBoundingWidth));
        }
        
        NSInteger embedIndex = *embedIndexCounter;
        (*embedIndexCounter)++;
        
        TGPIPSourceLocation *location = [[TGPIPSourceLocation alloc] initWithEmbed:true peerId:peerId messageId:messageId localId:(int32_t)embedIndex webPage:webPage];
        TGInstantPageEmbedItem *item = [[TGInstantPageEmbedItem alloc] initWithFrame:CGRectMake(CGFloor((boundingWidth - size.width) / 2.0f), 0.0f, size.width, size.height) url:embedBlock.url html:embedBlock.html posterMedia:posterMedia location:location enableScrolling:embedBlock.enableScrolling];
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:CGSizeMake(boundingWidth, item.frame.size.height) items:@[item]];
    } else if ([block isKindOfClass:[TGInstantPageBlockSlideshow class]]) {
        TGInstantPageBlockSlideshow *slideshowBlock = (TGInstantPageBlockSlideshow *)block;
        NSMutableArray<TGInstantPageMedia *> *medias = [[NSMutableArray alloc] init];
        CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        for (TGInstantPageBlock *subBlock in slideshowBlock.items) {
            if ([subBlock isKindOfClass:[TGInstantPageBlockPhoto class]]) {
                TGInstantPageBlockPhoto *photoBlock = (TGInstantPageBlockPhoto *)subBlock;
                TGImageMediaAttachment *imageMedia = images[@(photoBlock.photoId)];
                if (imageMedia != nil) {
                    CGSize imageSize = CGSizeZero;
                    if ([imageMedia.imageInfo imageUrlForLargestSize:&imageSize] != nil) {
                        TGImageMediaAttachment *mediaWithCaption = [imageMedia copy];
                        mediaWithCaption.caption = richPlainText(photoBlock.caption);
                        NSInteger mediaIndex = *mediaIndexCounter;
                        (*mediaIndexCounter)++;
                        
                        CGSize filledSize = TGFitSize(imageSize, CGSizeMake(boundingWidth, 1200.0f));
                        contentSize.height = MIN(MAX(contentSize.height, filledSize.height), boundingWidth);
                        [medias addObject:[[TGInstantPageMedia alloc] initWithIndex:mediaIndex media:mediaWithCaption]];
                    }
                }
            }
        }
        
        [items addObject:[[TGInstantPageSlideshowItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundingWidth, contentSize.height) medias:medias]];
        
        if (slideshowBlock.caption != nil) {
            contentSize.height += 10.0f;
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
            if (presentation.fontSerif)
                [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            
            TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:slideshowBlock.caption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
            captionItem.alignment = NSTextAlignmentCenter;
            captionItem.frame = CGRectOffset(captionItem.frame, CGFloor((boundingWidth - captionItem.frame.size.width) / 2.0), contentSize.height);
            contentSize.height += captionItem.frame.size.height;
            [items addObject:captionItem];
        }

        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
    } else if ([block isKindOfClass:[TGInstantPageBlockCollage class]]) {
        TGInstantPageBlockCollage *collageBlock = (TGInstantPageBlockCollage *)block;
        CGFloat spacing = 2.0f;
        int itemsPerRow = 3;
        CGFloat itemSize = (boundingWidth - spacing * MAX(0, itemsPerRow - 1)) / itemsPerRow;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        CGPoint nextItemOrigin = CGPointMake(0.0f, 0.0f);
        for (TGInstantPageBlock *subBlock in collageBlock.items) {
            if (nextItemOrigin.x + itemSize > boundingWidth) {
                nextItemOrigin.x = 0.0f;
                nextItemOrigin.y += itemSize + spacing;
            }
            TGInstantPageLayout *subLayout = [self layoutBlock:subBlock boundingWidth:itemSize horizontalInset:0.0f isCover:false previousItems:items fillToWidthAndHeight:true images:images videos:videos documents:documents webPage:webPage peerId:peerId messageId:messageId mediaIndexCounter:mediaIndexCounter embedIndexCounter:embedIndexCounter overlay:overlay presentation:presentation];
            [items addObjectsFromArray:[subLayout flattenedItemsWithOrigin:nextItemOrigin]];
            nextItemOrigin.x += itemSize + spacing;
        }
        
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:CGSizeMake(boundingWidth, nextItemOrigin.y + itemSize) items:items];
    } else if ([block isKindOfClass:[TGInstantPageBlockEmbedPost class]]) {
        TGInstantPageBlockEmbedPost *postBlock = (TGInstantPageBlockEmbedPost *)block;
        
        CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
        CGFloat lineInset = 20.0f;
        CGFloat verticalInset = 4.0f;
        CGFloat itemSpacing = 10.0f;
        CGFloat avatarInset = 0.0f;
        CGFloat avatarVerticalInset = 0.0f;
        
        contentSize.height += verticalInset;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        if (postBlock.author.length != 0) {
            TGImageMediaAttachment *avatar = postBlock.authorPhotoId == 0 ? nil : images[@(postBlock.authorPhotoId)];
            if (avatar != nil) {
                TGInstantPageMediaItem *avatarItem = [[TGInstantPageMediaItem alloc] initWithFrame:CGRectMake(horizontalInset + lineInset + 1.0f, contentSize.height - 2.0f, 50.0f, 50.0f) media:[[TGInstantPageMedia alloc] initWithIndex:-1 media:avatar] arguments:[[TGInstantPageImageMediaArguments alloc] initWithInteractive:false roundCorners:true fit:false]];
                [items addObject:avatarItem];
                avatarInset += 62.0f;
                avatarVerticalInset += 6.0f;
                if (postBlock.date == 0) {
                    avatarVerticalInset += 11.0f;
                }
            }
            
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(17.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleBoldItem alloc] init]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.textColor]];
            if (presentation.fontSerif)
                [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            
            TGInstantPageTextItem *textItem = [self layoutTextItemWithString:[self attributedStringForRichText:[[TGRichTextPlain alloc] initWithText:postBlock.author] styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset - lineInset - avatarInset];
            textItem.frame = CGRectOffset(textItem.frame, horizontalInset + lineInset + avatarInset, contentSize.height + avatarVerticalInset);
            
            contentSize.height += textItem.frame.size.height + avatarVerticalInset;
            [items addObject:textItem];
        }
        if (postBlock.date != 0) {
            if (items.count != 0) {
                contentSize.height += itemSpacing;
            }
            NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:postBlock.date] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
            
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
            if (presentation.fontSerif)
                [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            
            TGInstantPageTextItem *textItem = [self layoutTextItemWithString:[self attributedStringForRichText:[[TGRichTextPlain alloc] initWithText:dateString] styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset - lineInset - avatarInset];
            textItem.frame = CGRectOffset(textItem.frame, horizontalInset + lineInset + avatarInset, contentSize.height);
            contentSize.height += textItem.frame.size.height;
            if (textItem != nil) {
                [items addObject:textItem];
            }
        }
        
        if (true) {
            if (items.count != 0) {
                contentSize.height += itemSpacing;
            }
            
            TGInstantPageBlock *previousBlock = nil;
            for (TGInstantPageBlock *subBlock in postBlock.blocks) {
                TGInstantPageLayout *subLayout = [self layoutBlock:subBlock boundingWidth:boundingWidth - horizontalInset - horizontalInset - lineInset horizontalInset:0.0f isCover:false previousItems:items fillToWidthAndHeight:false images:images videos:videos documents:documents webPage:webPage peerId:peerId messageId:messageId mediaIndexCounter:mediaIndexCounter embedIndexCounter:embedIndexCounter overlay:overlay presentation:presentation];
                CGFloat spacing = spacingBetweenBlocks(previousBlock, subBlock) * presentation.fontSizeMultiplier;
                NSArray *blockItems = [subLayout flattenedItemsWithOrigin:CGPointMake(horizontalInset + lineInset, contentSize.height + spacing)];
                [items addObjectsFromArray:blockItems];
                contentSize.height += subLayout.contentSize.height + spacing;
                previousBlock = subBlock;
            }
        }
        
        contentSize.height += verticalInset;
        
        [items addObject:[[TGInstantPageShapeItem alloc] initWithFrame:CGRectMake(horizontalInset, 0.0f, 3.0f, contentSize.height) shapeFrame:CGRectMake(0.0f, 0.0f, 3.0f, contentSize.height) shape:TGInstantPageShapeRoundLine color:presentation.textColor]];
        
        TGRichText *postCaption = postBlock.caption;
        
        if (postCaption != nil) {
            contentSize.height += 14.0f;
            TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
            [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
            [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
            if (presentation.fontSerif)
                [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
            
            TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:postCaption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
            captionItem.frame = CGRectOffset(captionItem.frame, horizontalInset, contentSize.height);
            contentSize.height += captionItem.frame.size.height;
            [items addObject:captionItem];
        }
        
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
    } else if ([block isKindOfClass:[TGInstantPageBlockAnchor class]]) {
        TGInstantPageBlockAnchor *anchorBlock = (TGInstantPageBlockAnchor *)block;
        return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:CGSizeMake(0.0f, 0.0f) items:@[[[TGInstantPageAnchorItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) anchor:anchorBlock.name]]];
    } else if ([block isKindOfClass:[TGInstantPageBlockChannel class]]) {
        TGInstantPageBlockChannel *channelBlock = (TGInstantPageBlockChannel *)block;
    
        if (channelBlock.channel != nil)
        {
            TGInstantPageChannelItem *item = [[TGInstantPageChannelItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundingWidth, [TGInstantPageChannelView height]) channel:channelBlock.channel overlay:overlay presentation:presentation];
            return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:CGSizeMake(boundingWidth, item.frame.size.height) items:@[item]];
        }
    } else if ([block isKindOfClass:[TGInstantPageBlockAudio class]]) {
        TGInstantPageBlockAudio *audioBlock = (TGInstantPageBlockAudio *)block;
        
        TGDocumentMediaAttachment *document = documents[@(audioBlock.audioId)];
        if (document != nil) {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
            
            TGInstantPageAudioItem *item = [[TGInstantPageAudioItem alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundingWidth, [TGInstantPageAudioView height]) document:document presentation:presentation];
            contentSize.height += item.frame.size.height;
            [items addObject:item];
            
            TGRichText *postCaption = audioBlock.caption;
            
            if (postCaption != nil) {
                contentSize.height += 10.0f;
                TGInstantPageStyleStack *styleStack = [[TGInstantPageStyleStack alloc] init];
                [styleStack pushItem:[[TGInstantPageStyleFontSizeItem alloc] initWithSize:round(15.0f * multiplier)]];
                [styleStack pushItem:[[TGInstantPageStyleTextColorItem alloc] initWithColor:presentation.subtextColor]];
                if (presentation.fontSerif)
                    [styleStack pushItem:[[TGInstantPageStyleFontSerifItem alloc] initWithSerif:true]];
                
                TGInstantPageTextItem *captionItem = [self layoutTextItemWithString:[self attributedStringForRichText:postCaption styleStack:styleStack] boundingWidth:boundingWidth - horizontalInset - horizontalInset];
                captionItem.frame = CGRectOffset(captionItem.frame, 0.0f, contentSize.height);
                captionItem.frame = CGRectOffset(captionItem.frame, CGFloor((boundingWidth - captionItem.frame.size.width) / 2.0), 0.0f);
                captionItem.alignment = NSTextAlignmentCenter;
                contentSize.height += captionItem.frame.size.height;
                [items addObject:captionItem];
            }
            
            return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:contentSize items:items];
        }
    }
    
    return [[TGInstantPageLayout alloc] initWithOrigin:CGPointMake(0.0f, 0.0f) contentSize:CGSizeMake(0.0f, 0.0f) items:@[]];
}

+ (TGInstantPageLayout *)makeLayoutForWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId boundingWidth:(CGFloat)boundingWidth presentation:(TGInstantPagePresentation *)presentation {
    NSArray<TGInstantPageBlock *> *pageBlocks = webPage.instantPage.blocks;
    
    CGSize contentSize = CGSizeMake(boundingWidth, 0.0f);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSDictionary *images = webPage.instantPage.images;
    NSDictionary *videos = webPage.instantPage.videos;
    NSDictionary *documents = webPage.instantPage.documents;
    if (webPage.photo != nil) {
        NSMutableDictionary *updatedImages = [[NSMutableDictionary alloc] initWithDictionary:images];
        updatedImages[@(webPage.photo.imageId)] = webPage.photo;
        images = updatedImages;
    }
    if (webPage.document != nil) {
        TGVideoMediaAttachment *videoMedia = nil;
        for (id attribute in webPage.document.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                TGDocumentAttributeVideo *video = attribute;
                
                videoMedia = [[TGVideoMediaAttachment alloc] init];
                videoMedia.videoId = webPage.document.documentId;
                videoMedia.accessHash = webPage.document.accessHash;
                videoMedia.duration = video.duration;
                videoMedia.dimensions = video.size;
                videoMedia.thumbnailInfo = webPage.document.thumbnailInfo;
                videoMedia.caption = webPage.document.caption;
                
                TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
                [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"video:%lld:%lld:%d:%d", videoMedia.videoId, videoMedia.accessHash, webPage.document.datacenterId, webPage.document.size] size:webPage.document.size];
                videoMedia.videoInfo = videoInfo;
            }
        }
        if (videoMedia != nil) {
            NSMutableDictionary *updatedVideos = [[NSMutableDictionary alloc] initWithDictionary:videos];
            updatedVideos[@(videoMedia.videoId)] = videoMedia;
            videos = updatedVideos;
        }
    }
    
    NSInteger mediaIndexCounter = 0;
    NSInteger embedIndexCounter = 0;
    
    TGInstantPageBlock *previousBlock = nil;
    TGInstantPageLayout *previousLayout = nil;
    for (TGInstantPageBlock *block in pageBlocks) {
        CGFloat spacingBetween = spacingBetweenBlocks(previousBlock, block);
        if (spacingBetween > FLT_EPSILON)
            spacingBetween *= presentation.fontSizeMultiplier;
        
        if (spacingBetween < -FLT_EPSILON) {
            spacingBetween -= previousLayout.contentSize.height - previousLayout.items.firstObject.frame.size.height;
        }
        
        TGInstantPageLayout *blockLayout = [self layoutBlock:block boundingWidth:boundingWidth horizontalInset:17.0f isCover:false previousItems:items fillToWidthAndHeight:false images:images videos:videos documents:documents webPage:webPage peerId:peerId messageId:messageId mediaIndexCounter:&mediaIndexCounter embedIndexCounter:&embedIndexCounter overlay:(spacingBetween < -FLT_EPSILON) presentation:presentation];
        
        CGFloat spacing = blockLayout.contentSize.height > FLT_EPSILON ? spacingBetween : 0.0f;
        NSArray *blockItems = [blockLayout flattenedItemsWithOrigin:CGPointMake(0.0f, contentSize.height + spacing)];
        [items addObjectsFromArray:blockItems];
        contentSize.height += (spacing > -FLT_EPSILON ? blockLayout.contentSize.height + spacing : 0.0f);
        previousBlock = block;
        previousLayout = blockLayout;
    }
    CGFloat closingSpacing = spacingBetweenBlocks(previousBlock, nil) * presentation.fontSizeMultiplier;
    contentSize.height += closingSpacing;
    
    {
        CGFloat height = CGCeil([TGInstantPageFooterButtonView heightForWidth:boundingWidth]);
        
        TGInstantPageFooterButtonItem *item = [[TGInstantPageFooterButtonItem alloc] initWithFrame:CGRectMake(0.0f, contentSize.height, boundingWidth, height) presentation:presentation];
        [items addObject:item];
        contentSize.height += item.frame.size.height;
    }
    
    return [[TGInstantPageLayout alloc] initWithOrigin:CGPointZero contentSize:contentSize items:items];
}

@end


@implementation TGInstantPagePresentation

+ (instancetype)presentationWithFontSizeMultiplier:(CGFloat)fontSizeMultiplier fontSerif:(bool)fontSerif theme:(TGInstantPagePresentationTheme)theme forceAutoNight:(bool)forceAutoNight {
    TGInstantPagePresentation *presentation = [[TGInstantPagePresentation alloc] init];
    presentation->_fontSizeMultiplier = fontSizeMultiplier;
    presentation->_fontSerif = fontSerif;
    presentation->_initialTheme = theme;
    presentation->_theme = forceAutoNight ? TGInstantPagePresentationThemeBlack : theme;
    presentation->_forceAutoNight = forceAutoNight;
    
    switch (presentation->_theme) {
        case TGInstantPagePresentationThemeBrown:
            presentation->_backgroundColor = UIColorRGB(0xf8f1e2);
            presentation->_textColor = UIColorRGB(0x4f321d);
            presentation->_titleColor = presentation->_textColor;
            presentation->_subtextColor = UIColorRGB(0x927e6b);
            presentation->_linkColor = presentation->_textColor;
            presentation->_actionColor = UIColorRGB(0xd19601);
            presentation->_panelColor = UIColorRGB(0xefe7d6);
            presentation->_panelHighlightColor = UIColorRGB(0xe3dccb);
            presentation->_panelTextColor = [UIColor blackColor];
            presentation->_panelSubtextColor = presentation->_subtextColor;
            
            presentation->_textSelectionColor = UIColorRGBA(0x000000, 0.1f);
            break;
            
        case TGInstantPagePresentationThemeGray:
            presentation->_backgroundColor = UIColorRGB(0x5a5a5c);
            presentation->_textColor = UIColorRGB(0xcecece);
            presentation->_titleColor = presentation->_textColor;
            presentation->_subtextColor = UIColorRGB(0xa0a0a0);
            presentation->_linkColor = presentation->_textColor;
            presentation->_actionColor = UIColorRGB(0x54b9f8);
            presentation->_panelColor = UIColorRGB(0x555556);
            presentation->_panelHighlightColor = UIColorRGB(0x505051);
            presentation->_panelTextColor = UIColorRGB(0xcecece);
            presentation->_panelSubtextColor = presentation->_subtextColor;
            
            presentation->_textSelectionColor = UIColorRGBA(0x000000, 0.16f);
            break;
            
        case TGInstantPagePresentationThemeBlack:
            presentation->_backgroundColor = UIColorRGB(0x000000);
            presentation->_textColor = UIColorRGB(0xb0b0b0);
            presentation->_titleColor = presentation->_textColor;
            presentation->_subtextColor = UIColorRGB(0x6a6a6a);
            presentation->_linkColor = presentation->_textColor;
            presentation->_actionColor = UIColorRGB(0x50b6f3);
            presentation->_panelColor = UIColorRGB(0x131313);
            presentation->_panelHighlightColor = UIColorRGB(0x1f1f1f);
            presentation->_panelTextColor = UIColorRGB(0xb0b0b0);
            presentation->_panelSubtextColor = presentation->_subtextColor;
            
            presentation->_textSelectionColor = UIColorRGBA(0xffffff, 0.10f);
            break;
            
        default:
            presentation->_backgroundColor = [UIColor whiteColor];
            presentation->_textColor = [UIColor blackColor];
            presentation->_titleColor = presentation->_textColor;
            presentation->_subtextColor = UIColorRGB(0x79828b);
            presentation->_linkColor = presentation->_textColor;
            presentation->_actionColor = TGAccentColor();
            presentation->_panelColor = UIColorRGB(0xf3f4f5);
            presentation->_panelHighlightColor = UIColorRGB(0xe7e7e7);
            presentation->_panelTextColor = [UIColor blackColor];
            presentation->_panelSubtextColor = presentation->_subtextColor;
            
            presentation->_textSelectionColor = UIColorRGBA(0x000000, 0.12f);
            break;
    }
    
    return presentation;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return true;
    }
    
    if (!object || ![object isKindOfClass:[self class]]) {
        return false;
    }
    
    TGInstantPagePresentation *value = (TGInstantPagePresentation *)object;
    return fabs(value.fontSizeMultiplier - self.fontSizeMultiplier) < FLT_EPSILON && value.fontSerif == self.fontSerif && value.initialTheme == self.initialTheme && value.forceAutoNight == self.forceAutoNight;
}

@end
