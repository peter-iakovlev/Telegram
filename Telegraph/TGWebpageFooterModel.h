#import "TGModernViewModel.h"

@interface TGWebpageFooterModel : TGModernViewModel

- (instancetype)initWithWithIncoming:(bool)incoming;

- (void)layoutForContainerSize:(CGSize)containerSize contentSize:(CGSize)contentSize needsContentUpdate:(bool *)needsContentUpdate;

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)contentSize needsContentsUpdate:(bool *)needsContentsUpdate;
- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)bottomInset;

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition;
- (void)updateSpecialViewsPositions:(CGPoint)itemPosition;
- (bool)preferWebpageSize;

+ (UIColor *)colorForAccentText:(bool)incoming;

- (bool)hasWebpageActionAtPoint:(CGPoint)point;
- (bool)activateWebpageContents;
- (bool)webpageContentsActivated;
- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData;

- (UIView *)referenceViewForImageTransition;
- (void)setMediaVisible:(bool)mediaVisible;

@end
