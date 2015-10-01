#import "TGInterfaceController.h"

@interface TGProfilePhotoControllerContext : NSObject <TGInterfaceContext>

@property (nonatomic, readonly) NSString *imageUrl;

- (instancetype)initWithImageUrl:(NSString *)imageUrl;

@end

@interface TGProfilePhotoController : TGInterfaceController

@property (nonatomic, weak) IBOutlet WKInterfaceGroup *imageGroup;
@property (nonatomic, weak) IBOutlet WKInterfaceImage *activityIndicator;

@end
