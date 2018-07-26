#import <UIKit/UIKit.h>

@class TGGroupInfoUserCollectionItem;
@class TGPresentation;

@interface TGGroupInfoUserCell : UITableViewCell

@property (nonatomic, strong) TGPresentation *presentation;
- (void)setItem:(TGGroupInfoUserCollectionItem *)item;

@end
