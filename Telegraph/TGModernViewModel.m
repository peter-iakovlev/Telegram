#import "TGModernViewModel.h"

#import "TGModernView.h"

@interface TGModernViewModelId : NSObject <NSCopying>

@end

@implementation TGModernViewModelId

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return self;
}

@end

@interface TGModernViewModel ()
{
    UIView<TGModernView> *_view;
    
    NSString *_viewIdentifier;
    NSMutableArray *_submodels;
}

@end

@implementation TGModernViewModel

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _alpha = 1.0f;
        _modelId = [[TGModernViewModelId alloc] init];
    }
    return self;
}

- (bool)hasNoView
{
    return _modelFlags.hasNoView;
}

- (void)setHasNoView:(bool)hasNoView
{
    _modelFlags.hasNoView = hasNoView;
}

- (bool)skipDrawInContext
{
    return _modelFlags.skipDrawInContext;
}

- (void)setSkipDrawInContext:(bool)skipDrawInContext
{
    _modelFlags.skipDrawInContext = skipDrawInContext;
}

- (bool)disableSubmodelAutomaticBinding
{
    return _modelFlags.disableSubmodelAutomaticBinding;
}

- (void)setDisableSubmodelAutomaticBinding:(bool)disableSubmodelAutomaticBinding
{
    _modelFlags.disableSubmodelAutomaticBinding = disableSubmodelAutomaticBinding;
}

- (bool)viewUserInteractionDisabled
{
    return _modelFlags.viewUserInteractionDisabled;
}

- (void)setViewUserInteractionDisabled:(bool)viewUserInteractionDisabled
{
    if (_modelFlags.viewUserInteractionDisabled != viewUserInteractionDisabled)
    {
        _modelFlags.viewUserInteractionDisabled = viewUserInteractionDisabled;
        _view.userInteractionEnabled = !viewUserInteractionDisabled;
    }
}

- (Class)viewClass
{
    return nil;
}

- (UIView<TGModernView> *)_dequeueView:(TGModernViewStorage *)viewStorage
{
    if (_viewIdentifier == nil)
        _viewIdentifier = NSStringFromClass([self viewClass]);
    
    UIView<TGModernView> *view = [viewStorage dequeueViewWithIdentifier:_viewIdentifier viewStateIdentifier:_viewStateIdentifier];
    if (view == nil)
    {
        view = [[[self viewClass] alloc] init];
        [view setViewIdentifier:_viewIdentifier];
    }
    
    return view;
}

- (UIView<TGModernView> *)boundView
{
    return _view;
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    if (!_modelFlags.hasNoView)
        _view = [self _dequeueView:viewStorage];
    
    if (_view != nil || _modelFlags.hasNoView)
    {
        if (!_modelFlags.hasNoView)
        {
            [container addSubview:_view];
        
            [_view setFrame:CGRectOffset(_frame, _parentOffset.x, _parentOffset.y)];
            [_view setAlpha:_alpha];
            [_view setHidden:_hidden];
            
            _view.userInteractionEnabled = !_modelFlags.viewUserInteractionDisabled;
        }

        bool disableSubmodelAutomaticBinding = _modelFlags.disableSubmodelAutomaticBinding;
        
        for (TGModernViewModel *submodel in self.submodels)
        {
            if (!disableSubmodelAutomaticBinding || submodel.skipDrawInContext)
                [submodel bindViewToContainer:_modelFlags.hasNoView ? container : _view viewStorage:viewStorage];
        }
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    if (_unbindAction)
        _unbindAction();
    
    for (TGModernViewModel *submodel in self.submodels)
    {
        [submodel unbindView:viewStorage];
    }
    
    if (_view != nil)
    {
        [_view removeFromSuperview];
        [viewStorage enqueueView:_view];
        _view = nil;
    }
}

- (void)moveViewToContainer:(UIView *)container
{
    if (!_modelFlags.hasNoView)
    {
        if (_view != nil)
            [container addSubview:_view];
    }
    else
    {
        bool disableSubmodelAutomaticBinding = _modelFlags.disableSubmodelAutomaticBinding;
        
        for (TGModernViewModel *submodel in self.submodels)
        {
            if (!disableSubmodelAutomaticBinding || submodel.skipDrawInContext)
                [submodel moveViewToContainer:container];
        }
    }
}

- (void)_offsetBoundViews:(CGSize)offset
{
    if (!_modelFlags.hasNoView)
    {
        if (_view != nil)
            _view.frame = CGRectOffset(_view.frame, offset.width, offset.height);
    }
    else
    {
        bool disableSubmodelAutomaticBinding = _modelFlags.disableSubmodelAutomaticBinding;
        
        for (TGModernViewModel *submodel in self.submodels)
        {
            if (!disableSubmodelAutomaticBinding || submodel.skipDrawInContext)
                [submodel _offsetBoundViews:offset];
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    _frame = frame;
    
    if (_view != nil)
        [_view setFrame:CGRectOffset(_frame, _parentOffset.x, _parentOffset.y)];
}

- (void)setParentOffset:(CGPoint)parentOffset
{
    _parentOffset = parentOffset;
}

- (void)setAlpha:(float)alpha
{
    _alpha = alpha;
    
    if (_view != nil)
        [_view setAlpha:alpha];
}

- (void)setHidden:(bool)hidden
{
    _hidden = hidden;
    
    if (_view != nil)
        [_view setHidden:hidden];
}

- (void)drawInContext:(CGContextRef)context
{
    if (_modelFlags.skipDrawInContext || _hidden || _alpha < FLT_EPSILON)
        return;
    
    [self drawSubmodelsInContext:context];
}

- (void)drawSubmodelsInContext:(CGContextRef)context
{
    for (TGModernViewModel *submodel in self.submodels)
    {
        CGRect frame = submodel.frame;
        CGContextTranslateCTM(context, frame.origin.x, frame.origin.y);
        [submodel drawInContext:context];
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    }
}

- (void)sizeToFit
{
}

- (CGRect)bounds
{
    return CGRectMake(0, 0, _frame.size.width, _frame.size.height);
}

- (NSArray *)submodels
{
    return _submodels;
}

- (bool)containsSubmodel:(TGModernViewModel *)model
{
    return _submodels != nil && [_submodels containsObject:model];
}

- (void)addSubmodel:(TGModernViewModel *)model
{
    if (model == nil)
        return;
    
    if (_submodels == nil)
        _submodels = [[NSMutableArray alloc] init];
    
    [_submodels addObject:model];
}

- (void)insertSubmodel:(TGModernViewModel *)model aboveSubmodel:(TGModernViewModel *)aboveSubmodel
{
    if (model == nil)
        return;
    
    if (_submodels == nil)
        _submodels = [[NSMutableArray alloc] init];
    
    NSUInteger index = [_submodels indexOfObject:aboveSubmodel];
    if (index != NSNotFound)
        [_submodels insertObject:model atIndex:index + 1];
    else
        [_submodels addObject:model];
}

- (void)removeSubmodel:(TGModernViewModel *)model viewStorage:(TGModernViewStorage *)viewStorage
{
    if (model == nil)
        return;
    
    if ([_submodels containsObject:model])
    {
        [model unbindView:viewStorage];
        [_submodels removeObject:model];
    }
}

- (void)layoutForContainerSize:(CGSize)__unused containerSize
{
}

- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict
{
    if (_modelId != nil && _view != nil)
        dict[_modelId] = [NSValue valueWithCGRect:_view.frame];
    
    for (TGModernViewModel *submodel in _submodels)
    {
        [submodel collectBoundModelViewFramesRecursively:dict];
    }
}

- (void)collectBoundModelViewFramesRecursively:(NSMutableDictionary *)dict ifPresentInDict:(NSMutableDictionary *)anotherDict
{
    if (_modelId != nil && _view != nil && anotherDict[_modelId] != nil)
        dict[_modelId] = [NSValue valueWithCGRect:_view.frame];
    
    for (TGModernViewModel *submodel in _submodels)
    {
        [submodel collectBoundModelViewFramesRecursively:dict];
    }
}

- (void)restoreBoundModelViewFramesRecursively:(NSMutableDictionary *)dict
{
    if (_modelId != nil && _view != nil)
    {
        NSValue *value = dict[_modelId];
        if (value != nil)
            _view.frame = [value CGRectValue];
    }
    
    for (TGModernViewModel *submodel in _submodels)
    {
        [submodel restoreBoundModelViewFramesRecursively:dict];
    }
}

@end
