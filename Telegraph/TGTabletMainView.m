#import "TGTabletMainView.h"

#import "TGImageUtils.h"

@interface TGTabletMainView ()
{
    UIView *_stripeView;
    UIView *_masterViewContainer;
    UIView *_detailViewContainer;
    
    UIView *_fakeNavigationBarView;
    UIView *_fakeNavigationBarSeparatorView;
    
    UIImageView *_blankLogoView;
}

@end

@implementation TGTabletMainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.clipsToBounds = true;
        
        CGRect detailViewContainerFrame = [self rectForDetailViewForFrame:frame];
        
        _fakeNavigationBarView = [[UIView alloc] initWithFrame:CGRectMake(detailViewContainerFrame.origin.x, 0.0f, detailViewContainerFrame.size.width, 64.0f)];
        _fakeNavigationBarView.backgroundColor = UIColorRGBA(0xf7f7f7, 1.0f);
        [self addSubview:_fakeNavigationBarView];
        
        CGFloat separatorHeight = TGScreenPixel;
        _fakeNavigationBarSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(detailViewContainerFrame.origin.x, 64.0f - separatorHeight, detailViewContainerFrame.size.width, separatorHeight)];
        _fakeNavigationBarSeparatorView.backgroundColor = UIColorRGB(0xb2b2b2);
        [self addSubview:_fakeNavigationBarSeparatorView];
        
        _blankLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DetailLogoBlank.png"]];
        _blankLogoView.frame = CGRectMake(CGFloor(CGRectGetMidX(detailViewContainerFrame) - _blankLogoView.frame.size.width / 2.0f), CGFloor(CGRectGetMidY(detailViewContainerFrame) - _blankLogoView.frame.size.height / 2.0f) + 9.0f, _blankLogoView.frame.size.width, _blankLogoView.frame.size.height);
        [self addSubview:_blankLogoView];
        
        _detailViewContainer = [[UIView alloc] initWithFrame:detailViewContainerFrame];
        _detailViewContainer.clipsToBounds = true;
        [self addSubview:_detailViewContainer];
        
        CGRect masterViewContainerFrame = [self rectForMasterViewForFrame:frame];
        _masterViewContainer = [[UIView alloc] initWithFrame:masterViewContainerFrame];
        _masterViewContainer.clipsToBounds = true;
        [self addSubview:_masterViewContainer];
        
        _stripeView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(masterViewContainerFrame), 0.0f, TGScreenPixel, masterViewContainerFrame.size.height)];
        _stripeView.backgroundColor = UIColorRGB(0xb2b2b2);
        [self addSubview:_stripeView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self layoutForFrame:frame];
}

- (void)layoutForFrame:(CGRect)frame {
    CGRect masterViewContainerFrame = [self rectForMasterViewForFrame:frame];
    _masterViewContainer.frame = masterViewContainerFrame;
    
    _stripeView.frame = CGRectMake(CGRectGetMaxX(masterViewContainerFrame), 0.0f, TGScreenPixel, masterViewContainerFrame.size.height);
    
    masterViewContainerFrame.origin = CGPointZero;
    _masterView.frame = masterViewContainerFrame;
    
    CGRect detailViewContainerFrame = [self rectForDetailViewForFrame:frame];
    
    _fakeNavigationBarView.frame = CGRectMake(detailViewContainerFrame.origin.x, 0.0f, detailViewContainerFrame.size.width, 64.0f);
    
    _blankLogoView.frame = CGRectMake(CGFloor(CGRectGetMidX(detailViewContainerFrame) - _blankLogoView.frame.size.width / 2.0f), CGFloor(CGRectGetMidY(detailViewContainerFrame) - _blankLogoView.frame.size.height / 2.0f) + 9.0f, _blankLogoView.frame.size.width, _blankLogoView.frame.size.height);
    
    CGFloat separatorHeight = [[UIScreen mainScreen] scale] > 1.0f + FLT_EPSILON ? 0.5f : 1.0f;
    _fakeNavigationBarSeparatorView.frame = CGRectMake(detailViewContainerFrame.origin.x, 64.0f - separatorHeight, detailViewContainerFrame.size.width, separatorHeight);
    
    _detailViewContainer.frame = detailViewContainerFrame;
    
    detailViewContainerFrame.origin = CGPointZero;
    _detailView.frame = detailViewContainerFrame;
}

- (void)setFullScreenDetail:(bool)fullScreenDetail {
    if (fullScreenDetail != _fullScreenDetail) {
        _fullScreenDetail = fullScreenDetail;
        
        if (fullScreenDetail) {
            [_fakeNavigationBarView removeFromSuperview];
            [_fakeNavigationBarSeparatorView removeFromSuperview];
            [_blankLogoView removeFromSuperview];
            [_masterViewContainer removeFromSuperview];
            [_stripeView removeFromSuperview];
        } else {
            [self insertSubview:_fakeNavigationBarView atIndex:0];
            [self insertSubview:_fakeNavigationBarSeparatorView atIndex:1];
            [self insertSubview:_blankLogoView atIndex:2];
            [self insertSubview:_masterViewContainer aboveSubview:_detailViewContainer];
            [self addSubview:_stripeView];
        }
        
        [self layoutForFrame:self.frame];
    }
}

- (CGRect)rectForMasterViewForFrame:(CGRect)frame
{
    return CGRectMake(0.0f, 0.0f, frame.size.width >= (1024.0f - FLT_EPSILON) ? 389.0f : 320.0f, frame.size.height);
}

- (CGRect)rectForDetailViewForFrame:(CGRect)frame
{
    if (_fullScreenDetail) {
        return CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    } else {
        CGRect dialogListViewFrame = [self rectForMasterViewForFrame:frame];
        return CGRectMake(dialogListViewFrame.size.width, 0.0f, MAX(0.0f, frame.size.width - dialogListViewFrame.size.width + 1.0f), frame.size.height);
    }
}

- (void)setMasterView:(UIView *)masterView
{
    [_masterView removeFromSuperview];
    
    _masterView = masterView;
    CGRect masterViewContainerFrame = [self rectForMasterViewForFrame:self.frame];
    masterViewContainerFrame.origin = CGPointZero;
    _masterView.frame = masterViewContainerFrame;
    [_masterViewContainer addSubview:_masterView];
}

- (void)setDetailView:(UIView *)detailView
{
    if (detailView == _detailView) {
        CGRect detailViewContainerFrame = [self rectForDetailViewForFrame:self.frame];
        detailViewContainerFrame.origin = CGPointZero;
        _detailView.frame = detailViewContainerFrame;
        [_detailViewContainer addSubview:_detailView];
    } else {
        [_detailView removeFromSuperview];
        
        _detailView = detailView;
        CGRect detailViewContainerFrame = [self rectForDetailViewForFrame:self.frame];
        detailViewContainerFrame.origin = CGPointZero;
        _detailView.frame = detailViewContainerFrame;
        [_detailViewContainer addSubview:_detailView];
    }
}

@end
