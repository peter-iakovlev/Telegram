#import "TGModernMapController.h"

typedef enum {
    TGModernMapControllerModePreview = 0,
    TGModernMapControllerModeSelection = 1
} TGModernMapControllerMode;

@interface TGModernMapController ()
{
    TGModernMapControllerMode _mode;
    
    CLLocationCoordinate2D _previewCoordinate;
}

@end

@implementation TGModernMapController

- (instancetype)initInPreviewMode:(CLLocationCoordinate2D)previewCoordinate
{
    self = [super init];
    if (self)
    {
        [self _commonInit];
        
        _previewCoordinate = previewCoordinate;
    }
    return self;
}

- (instancetype)initInSelectionMode
{
    self = [super init];
    if (self)
    {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    self.automaticallyManageScrollViewInsets = false;
}

- (void)loadView
{
    [super loadView];
}

@end
