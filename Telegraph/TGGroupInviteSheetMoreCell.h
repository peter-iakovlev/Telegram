#import <UIKit/UIKit.h>

@class TGPresentation;

@interface TGGroupInviteSheetMoreCell : UICollectionViewCell

@property (nonatomic, strong) TGPresentation *presentation;
- (void)setCount:(NSUInteger)count;

@end
