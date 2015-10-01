/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import <CoreText/CoreText.h>

#ifdef __cplusplus
#include <vector>
#endif

#ifdef __cplusplus

typedef struct
{
    CGFloat offset;
    CGFloat horizontalOffset;
    uint8_t alignment;
    CGFloat lineWidth;
} TGLinePosition;

class TGLinkData
{
public:
    NSRange range;
    NSString *url;
    
    CGRect topRegion;
    CGRect middleRegion;
    CGRect bottomRegion;
    
public:
    TGLinkData(NSRange range_, NSString *url_)
    {
        range = range_;
        url = url_;
        
        topRegion = CGRectZero;
        middleRegion = CGRectZero;
        bottomRegion = CGRectZero;
    }
    
    TGLinkData(const TGLinkData &other)
    {
        range = other.range;
        url = other.url;
        
        topRegion = other.topRegion;
        middleRegion = other.middleRegion;
        bottomRegion = other.bottomRegion;
    }
    
    TGLinkData & operator= (const TGLinkData &other)
    {
        if (this != &other)
        {
            range = other.range;
            url = other.url;
            
            topRegion = other.topRegion;
            middleRegion = other.middleRegion;
            bottomRegion = other.bottomRegion;
        }
        
        return *this;
    }
    
    ~TGLinkData()
    {
        url = nil;
    }
};

#endif

typedef enum {
    TGReusableLabelLayoutMultiline = 1,
    TGReusableLabelLayoutHighlightLinks = 2,
    TGReusableLabelLayoutDateSpacing = 4,
    TGReusableLabelLayoutExtendedDateSpacing = 8,
    TGReusableLabelTruncateInTheMiddle = 16,
    TGReusableLabelLayoutHighlightCommands = 32,
    TGReusableLabelViewCountSpacing = 64
} TGReusableLabelLayout;

@interface TGReusableLabelLayoutData : NSObject

@property (nonatomic) CGSize size;

- (NSString *)linkAtPoint:(CGPoint)point topRegion:(CGRect *)topRegion middleRegion:(CGRect *)middleRegion bottomRegion:(CGRect *)bottomRegion;
- (void)enumerateSearchRegionsForString:(NSString *)string withBlock:(void (^)(CGRect))block;

#ifdef __cplusplus
- (std::vector<TGLinkData> *)links;
- (std::vector<TGLinePosition> *)lineOrigins;
#endif

@end

@interface TGReusableLabel : UIView

@property (nonatomic, strong) NSString *reuseIdentifier;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, strong) UIColor *highlightedShadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) bool highlighted;
@property (nonatomic) int numberOfLines;
@property (nonatomic) UITextAlignment textAlignment;

@property (nonatomic) bool richText;

@property (nonatomic, retain) TGReusableLabelLayoutData *precalculatedLayout;

+ (void)preloadData;
+ (TGReusableLabelLayoutData *)calculateLayout:(NSString *)text additionalAttributes:(NSArray *)additionalAttributes textCheckingResults:(NSArray *)textCheckingResults font:(CTFontRef)font textColor:(UIColor *)textColor frame:(CGRect)frame orMaxWidth:(float)maxWidth flags:(int)flags textAlignment:(UITextAlignment)textAlignment outIsRTL:(bool *)outIsRTL;
+ (TGReusableLabelLayoutData *)calculateLayout:(NSString *)text additionalAttributes:(NSArray *)additionalAttributes textCheckingResults:(NSArray *)textCheckingResults font:(CTFontRef)font textColor:(UIColor *)textColor frame:(CGRect)frame orMaxWidth:(float)maxWidth flags:(int)flags textAlignment:(UITextAlignment)textAlignment outIsRTL:(bool *)outIsRTL additionalTrailingWidth:(CGFloat)additionalTrailingWidth maxNumberOfLines:(NSUInteger)maxNumberOfLines numberOfLinesToInset:(NSUInteger)numberOfLinesToInset linesInset:(CGFloat)linesInset containsEmptyNewline:(bool *)containsEmptyNewline additionalLineSpacing:(CGFloat)additionalLineSpacing;

+ (void)drawTextInRect:(CGRect)rect text:(NSString *)text richText:(bool)richText font:(UIFont *)font highlighted:(bool)highlighted textColor:(UIColor *)textColor highlightedColor:(UIColor *)highlightedColor shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset numberOfLines:(int)numberOfLines;
+ (void)drawRichTextInRect:(CGRect)rect precalculatedLayout:(TGReusableLabelLayoutData *)precalculatedLayout linesRange:(NSRange)linesRange shadowColor:(UIColor *)shadowColor shadowOffset:(CGSize)shadowOffset;

@end
