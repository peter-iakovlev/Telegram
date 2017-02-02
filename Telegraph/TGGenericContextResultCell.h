#import <UIKit/UIKit.h>

#import "TGBotContextResult.h"

@interface TGGenericContextResultCellContent : UIView

@property (nonatomic, strong, readonly) TGBotContextResult *result;

@end

@interface TGGenericContextResultCell : UITableViewCell

@property (nonatomic, copy) void (^preview)(TGBotContextResult *result);

@property (nonatomic, strong) TGBotContextResult *result;

- (TGGenericContextResultCellContent *)_takeContent;
- (void)_putContent:(TGGenericContextResultCellContent *)content;
- (bool)hasContent;

@end
