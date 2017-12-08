#import <UIKit/UIKit.h>

@interface TGStickerCollectionHeader : UICollectionReusableView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, copy) void (^accessoryPressed)(void);

@end
