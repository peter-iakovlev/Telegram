#import "TGModernView.h"

@protocol TGMessageImageViewDelegate;

@class TGPresentation;

@interface TGDocumentMessageIconView : UIView <TGModernView>

@property (nonatomic, weak) id<TGMessageImageViewDelegate> delegate;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) TGPresentation *presentation;

@property (nonatomic) CGFloat diameter;
@property (nonatomic) bool incoming;
@property (nonatomic) int overlayType;
@property (nonatomic) CGFloat progress;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(CGFloat)progress animated:(bool)animated;

@end
