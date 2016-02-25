#import <UIKit/UIKit.h>

#import "TGBotContextResult.h"

@interface TGGenericContextResultCellContent : UIView

@property (nonatomic, strong, readonly) TGBotContextResult *result;

@end

@interface TGGenericContextResultCell : UITableViewCell

@property (nonatomic, copy) void (^preview)(NSString *url, bool embed, CGSize embedSize);

- (void)setResult:(TGBotContextResult *)result;

- (TGGenericContextResultCellContent *)_takeContent;
- (void)_putContent:(TGGenericContextResultCellContent *)content;
- (bool)hasContent;

@end
