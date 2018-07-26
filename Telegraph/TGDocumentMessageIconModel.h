#import "TGModernViewModel.h"

@class TGPresentation;

@interface TGDocumentMessageIconModel : TGModernViewModel

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) TGPresentation *presentation;

@property (nonatomic) CGFloat diameter;
@property (nonatomic) bool incoming;
@property (nonatomic) int overlayType;
@property (nonatomic) float progress;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(float)progress animated:(bool)animated;

@end
