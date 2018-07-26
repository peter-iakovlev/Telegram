#import <UIKit/UIKit.h>

@interface TGShareContactFieldCell : UITableViewCell

@property (nonatomic, assign) bool checked;
@property (nonatomic, assign) int64_t uniqueId;
@property (nonatomic, strong) NSSet *uniqueIds;

- (void)setLabel:(NSString *)label value:(NSString *)value;
- (void)setChecked:(bool)checked animated:(bool)animated;

@end
