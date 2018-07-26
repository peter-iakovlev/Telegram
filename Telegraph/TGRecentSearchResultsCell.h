#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGRecentSearchResultsCell : UITableViewCell

@property (nonatomic, strong) TGPresentation *presentation;

- (void)setTitle:(NSString *)title;

@end
