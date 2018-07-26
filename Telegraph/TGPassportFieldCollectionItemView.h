#import "TGCollectionItemView.h"

@interface TGPassportFieldCollectionItemView : TGCollectionItemView

- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;
- (void)setErrors:(NSArray *)errors;
- (void)setIsChecked:(bool)isChecked;
- (void)setIsRequired:(bool)isRequired;
- (void)setCalculatedSize:(CGSize)calculatedSize;

@end
