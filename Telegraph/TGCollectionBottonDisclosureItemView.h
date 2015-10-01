#import "TGCollectionItemView.h"

@class TGModernTextViewModel;

@interface TGCollectionBottonDisclosureItemView : TGCollectionItemView

- (void)setTitle:(NSString *)title textModel:(TGModernTextViewModel *)textModel expanded:(bool)expanded followAnchor:(void (^)(NSString *))followAnchor;
- (void)setExpanded:(bool)expanded;

+ (CGSize)title:(NSString *)title sizeForWidth:(CGFloat)width;

+ (NSString *)stringForText:(NSString *)text outAttributes:(__autoreleasing NSArray **)outAttributes outTextCheckingResults:(__autoreleasing NSArray **)outTextCheckingResults;

@end
