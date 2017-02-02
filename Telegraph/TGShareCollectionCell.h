#import <UIKit/UIKit.h>

@interface TGShareCollectionCell : UICollectionViewCell

@property (nonatomic, readonly) int64_t peerId;

- (void)setShowOnlyFirstName:(bool)showOnlyFirstName;
- (void)setPeer:(id)peer;
- (void)setChecked:(bool)checked;
- (void)setChecked:(bool)checked animated:(bool)animated;

- (void)performTransitionInWithDelay:(NSTimeInterval)delay;

@end

extern NSString *const TGShareCollectionCellIdentifier;
