#import <UIKit/UIKit.h>

@class GDURLMetadata;

@interface TGGoogleDriveItemCell : UITableViewCell

- (void)configureWithMetadata:(GDURLMetadata *)metadata;

@end

extern NSString *const TGGoogleDriveItemCellKind;
