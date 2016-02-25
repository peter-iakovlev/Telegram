#import "TGDocumentMessageIconModel.h"

#import "TGDocumentMessageIconView.h"

@implementation TGDocumentMessageIconModel

- (Class)viewClass
{
    return [TGDocumentMessageIconView class];
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _diameter = 44.0f;
    }
    return self;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGDocumentMessageIconViewModel/%d", (int)_diameter];
    
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    ((TGDocumentMessageIconView *)self.boundView).viewStateIdentifier = self.viewStateIdentifier;
    
    TGDocumentMessageIconView *view = (TGDocumentMessageIconView *)[self boundView];
    view.fileName = _fileName;
    
    [view setDiameter:_diameter];
    [view setIncoming:_incoming];
    [view setProgress:_progress animated:false];
    [view setOverlayType:_overlayType animated:false];
}

- (void)setProgress:(float)progress animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON)
    {
        _progress = progress;
        
        [((TGDocumentMessageIconView *)self.boundView) setProgress:_progress animated:animated];
    }
}

- (void)setOverlayType:(int)overlayType
{
    [self setOverlayType:overlayType animated:false];
}

- (void)setOverlayType:(int)overlayType animated:(bool)animated
{
    if (_overlayType != overlayType)
    {
        _overlayType = overlayType;
        
        [((TGDocumentMessageIconView *)self.boundView) setOverlayType:_overlayType animated:animated];
    }
}

@end
