#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGSharedMediaSectionHeaderView : UIView

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) TGPresentation *presentation;

- (void)setDateString:(NSString *)dateString summaryString:(NSString *)summaryString;

@end
