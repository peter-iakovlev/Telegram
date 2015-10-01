#import "TGModernViewModel.h"

@interface TGDocumentMessageIconModel : TGModernViewModel

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic) bool incoming;
@property (nonatomic) int overlayType;
@property (nonatomic) float progress;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(float)progress animated:(bool)animated;

@end
