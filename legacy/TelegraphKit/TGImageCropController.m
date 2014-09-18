#import "TGImageCropController.h"

#import "TGHacks.h"

#import "TGImageUtils.h"

#import "TGRemoteImageView.h"

#import "TGFont.h"

#import "TGModernButton.h"

@interface TGCropScrollView : UIScrollView

@property (nonatomic) UIEdgeInsets extendedInsets;

@end

@implementation TGCropScrollView

@synthesize extendedInsets = _extendedInsets;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (result != nil)
        return result;
    
    //CGRect frame = self.frame;
    //if (CGRectContainsPoint(CGRectMake(-_extendedInsets.left, -_extendedInsets.top, frame.size.width + _extendedInsets.left + _extendedInsets.right, frame.size.height + _extendedInsets.top + _extendedInsets.bottom), point))
        return self;
    
    return nil;
}

@end

#pragma mark -

@interface TGImageCropController () <TGViewControllerNavigationBarAppearance, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) TGModernButton *cancelButton;
@property (nonatomic, strong) TGModernButton *doneButton;

@property (nonatomic, strong) UIImageView *fieldSquareView;
@property (nonatomic, strong) UIView *leftShadeView;
@property (nonatomic, strong) UIView *rightShadeView;
@property (nonatomic, strong) UIView *topShadeView;
@property (nonatomic, strong) UIView *bottomShadeView;

@property (nonatomic, strong) TGCropScrollView *scrollView;
@property (nonatomic, strong) TGRemoteImageView *imageView;

@property (nonatomic) CGSize imageSize;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, strong) UIImage *fullImage;

@end

@implementation TGImageCropController

- (id)initWithAsset:(ALAsset *)asset
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self commonInit];
        
        if ([ALAssetRepresentation instancesRespondToSelector:@selector(dimensions)])
        {
            _imageSize = asset.defaultRepresentation.dimensions;
        }
        else
        {
            CGImageRef fullImage = asset.defaultRepresentation.fullScreenImage;
            if (fullImage != NULL)
                _imageSize = CGSizeMake(CGImageGetWidth(fullImage), CGImageGetHeight(fullImage));
        }
        
        _thumbnailImage = [[UIImage alloc] initWithCGImage:asset.aspectRatioThumbnail];
        _imageUrl = [[NSString alloc] initWithFormat:@"asset-original:%@", [asset.defaultRepresentation.url absoluteString]];
    }
    return self;
}

- (id)initWithImageInfo:(TGImageInfo *)imageInfo thumbnail:(UIImage *)thumbnail
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self commonInit];
        
        CGSize size = CGSizeZero;
        _imageUrl = [imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&size pickLargest:true];
        _imageSize = size;
        _thumbnailImage = thumbnail;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        [self commonInit];
        
        CGSize size = image.size;
        _imageSize = size;
        _fullImage = image;
    }
    return self;
}

- (void)commonInit
{
    self.wantsFullScreenLayout = true;
    self.automaticallyManageScrollViewInsets = false;
    self.autoManageStatusBarBackground = false;
    
    _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
}

- (void)dealloc
{
    [_actionHandle reset];
    
    [self doUnloadView];
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    return true;
}

- (bool)statusBarShouldBeHidden
{
    return false;
}

- (void)loadView
{
    [super loadView];
    
    self.view.clipsToBounds = true;
    self.view.backgroundColor = [UIColor blackColor];
    
    _imageView = [[TGRemoteImageView alloc] init];
    _imageView.cache = _customCache;
    _imageView.fadeTransition = true;
    
    _scrollView = [[TGCropScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = false;
    _scrollView.showsVerticalScrollIndicator = false;
    _scrollView.clipsToBounds = false;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [_scrollView addSubview:_imageView];
    [self.view addSubview:_scrollView];
    
    UIImage *rawFieldImage = [UIImage imageNamed:@"ModernPhotoCropField.png"];
    _fieldSquareView = [[UIImageView alloc] initWithImage:rawFieldImage];
    [self.view addSubview:_fieldSquareView];
    
    _leftShadeView = [[UIView alloc] init];
    _leftShadeView.userInteractionEnabled = false;
    _rightShadeView = [[UIView alloc] init];
    _rightShadeView.userInteractionEnabled = false;
    _topShadeView = [[UIView alloc] init];
    _topShadeView.userInteractionEnabled = false;
    _bottomShadeView = [[UIView alloc] init];
    _bottomShadeView.userInteractionEnabled = false;
    
    [self.view addSubview:_leftShadeView];
    [self.view addSubview:_rightShadeView];
    [self.view addSubview:_topShadeView];
    [self.view addSubview:_bottomShadeView];
    
    _leftShadeView.backgroundColor = UIColorRGBA(0x000000, 0.33f);
    _rightShadeView.backgroundColor = _leftShadeView.backgroundColor;
    _topShadeView.backgroundColor = _leftShadeView.backgroundColor;
    _bottomShadeView.backgroundColor = _leftShadeView.backgroundColor;
    
    _panelView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 50)];
    _panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_panelView];
    
    _cancelButton = [[TGModernButton alloc] init];
    _cancelButton.exclusiveTouch = true;
    [_cancelButton setTitle:self.navigationController.viewControllers.count == 1 ? TGLocalized(@"Common.Cancel") : TGLocalized(@"Common.Back") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor]];
    _cancelButton.titleLabel.font = TGSystemFontOfSize(18);
    [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    _cancelButton.frame = CGRectMake(0.0f, 0.0f, _cancelButton.frame.size.width + 24, 50);
    [_panelView addSubview:_cancelButton];
    
    _doneButton = [[TGModernButton alloc] init];
    _doneButton.exclusiveTouch = true;
    _doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_doneButton setTitle:TGLocalized(@"MediaPicker.Choose") forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor]];
    _doneButton.titleLabel.font = TGSystemFontOfSize(18);
    [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(_panelView.frame.size.width - _doneButton.frame.size.width - 24, 0.0f, _doneButton.frame.size.width + 24, 50);
    [_panelView addSubview:_doneButton];
    
    _doneButton.enabled = _fullImage != nil;
    
    ASHandle *actionHandle = _actionHandle;
    
    [_imageView setProgressHandler:^(__unused TGRemoteImageView *imageView, float progress)
    {
        if (progress == 1.0f)
        {
            [actionHandle requestAction:@"imageLoaded" options:nil];
        }
    }];
    
    if (_fullImage != nil)
        [_imageView loadImage:_fullImage];
    else
        [_imageView loadImage:_imageUrl filter:nil placeholder:_thumbnailImage];
    
    [self updateField];
    
    _imageView.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
    [self adjustScrollView];
    
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
    
    CGSize contentSize = _scrollView.contentSize;
    CGSize viewSize = _scrollView.frame.size;
    _scrollView.contentOffset = CGPointMake(MAX(0, floorf((contentSize.width - viewSize.width) / 2)), MAX(0, floorf((contentSize.height - viewSize.height) / 2)));
}

- (void)doUnloadView
{
    _scrollView.delegate = nil;
}

- (void)updateField
{
    CGSize screenSize = [self referenceViewSizeForOrientation:self.interfaceOrientation];
    
    _fieldSquareView.frame = CGRectMake(CGFloor((screenSize.width - 290.0f) / 2.0f), CGFloor((screenSize.height - _panelView.frame.size.height - 290) / 2), 290, 290);
    
    _leftShadeView.frame = CGRectMake(0, 0, _fieldSquareView.frame.origin.x, screenSize.height);
    _rightShadeView.frame = CGRectMake(_fieldSquareView.frame.origin.x + _fieldSquareView.frame.size.width, 0, screenSize.width - (_fieldSquareView.frame.origin.x + _fieldSquareView.frame.size.width), screenSize.height);
    _topShadeView.frame = CGRectMake(_leftShadeView.frame.size.width, 0, _rightShadeView.frame.origin.x - _leftShadeView.frame.size.width, _fieldSquareView.frame.origin.y);
    _bottomShadeView.frame = CGRectMake(_leftShadeView.frame.size.width, _fieldSquareView.frame.origin.y + _fieldSquareView.frame.size.height, _rightShadeView.frame.origin.x - _leftShadeView.frame.size.width, screenSize.height - (_fieldSquareView.frame.origin.y + _fieldSquareView.frame.size.height));
    
    _scrollView.frame = _fieldSquareView.frame;
    _scrollView.extendedInsets = UIEdgeInsetsMake(_topShadeView.frame.size.height, _leftShadeView.frame.size.width, _bottomShadeView.frame.size.height, _rightShadeView.frame.size.width);
}

- (void)viewWillAppear:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha:0.0f];
        }];
    }
    else
    {
        [TGHacks setApplicationStatusBarAlpha:0.0f];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
        }];
    }
    else
    {
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }
    
    [super viewWillAppear:animated];
}

#pragma mark -

- (void)cancelButtonPressed
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)doneButtonPressed
{
    UIImage *image = [_imageView currentImage];
    if (image == nil)
        return;
    
    CGSize imageSize = image.size;
    
    float scale = 1.0f / _scrollView.zoomScale / (_imageSize.width / imageSize.width);
    
    CGPoint contentOffset = _scrollView.contentOffset;
    
    CGRect visibleRect;
    visibleRect.origin.x = contentOffset.x * scale;
    visibleRect.origin.y = contentOffset.y * scale;
    visibleRect.size.width = _scrollView.frame.size.width * scale;
    visibleRect.size.height = _scrollView.frame.size.height * scale;
    
    UIImage *croppedImage = TGFixOrientationAndCrop(image, visibleRect, CGSizeMake(600, 600));
    [_watcherHandle requestAction:@"imageCropResult" options:croppedImage];
}

#pragma mark -

- (void)scrollViewDidZoom:(UIScrollView *)__unused scrollView
{
    [self adjustScrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)__unused scrollView withView:(UIView *)__unused view atScale:(float)__unused scale
{
    [self adjustScrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)__unused scrollView
{
    return _imageView;
}

- (void)adjustScrollView
{
    CGSize imageSize = _imageSize;
    float imageScale = 1.0f;
    imageSize.width /= imageScale;
    imageSize.height /= imageScale;
    
    CGSize boundsSize = _scrollView.bounds.size;
    
    CGFloat scaleWidth = boundsSize.width / imageSize.width;
    CGFloat scaleHeight = boundsSize.height / imageSize.height;
    CGFloat minScale = MAX(scaleWidth, scaleHeight);
    
    if (_scrollView.minimumZoomScale != minScale)
        _scrollView.minimumZoomScale = minScale;
    if (_scrollView.maximumZoomScale != minScale * 3.0f)
        _scrollView.maximumZoomScale = minScale * 3.0f;
    
    CGRect contentsFrame = _imageView.frame;
    
    if (boundsSize.width > contentsFrame.size.width)
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    else
        contentsFrame.origin.x = 0;
    
    if (boundsSize.height > contentsFrame.size.height)
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    else
        contentsFrame.origin.y = 0;
    
    _imageView.frame = contentsFrame;
}

#pragma mark -

- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"imageLoaded"])
    {
        _doneButton.enabled = true;
    }
}

@end
