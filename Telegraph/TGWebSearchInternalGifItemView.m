#import "TGWebSearchInternalGifItemView.h"

#import "TGStringUtils.h"

#import "TGImagePickerCellCheckButton.h"

#import "TGImageView.h"

#import "TGWebSearchInternalGifItem.h"

#import "TGImageInfo.h"

@interface TGWebSearchInternalGifItemView ()
{
    TGImagePickerCellCheckButton *_checkButton;
}

@property (nonatomic, copy) bool (^isEditing)();
@property (nonatomic, copy) void (^toggleEditing)();
@property (nonatomic, copy) void (^itemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGWebSearchListItem>);

@end

@implementation TGWebSearchInternalGifItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _checkButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 33.0f)];
        [_checkButton setChecked:false animated:false];
        [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkButton];
    }
    return self;
}

- (void)setItem:(TGWebSearchInternalGifItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    self.isEditing = item.isEditing;
    self.toggleEditing = item.toggleEditing;
    self.itemSelected = item.itemSelected;
    self.isItemSelected = item.isItemSelected;
    self.isItemHidden = item.isItemHidden;
    
    [self updateItemHiddenAnimated:false];
    if (_isItemSelected)
        [_checkButton setChecked:_isItemSelected(item) animated:false];
    
    CGSize dimensions = CGSizeZero;
    NSString *legacyThumbnailCacheUri = [item.webSearchResult.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
    dimensions.width *= 10.0f;
    dimensions.height *= 10.0f;
    
    NSString *filePreviewUri = nil;
    
    if ((item.webSearchResult.documentId != 0) && legacyThumbnailCacheUri.length != 0)
    {
        NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
        if (item.webSearchResult.documentId != 0)
            [previewUri appendFormat:@"id=%" PRId64 "", item.webSearchResult.documentId];
        
        [previewUri appendFormat:@"&file-name=%@", [item.webSearchResult.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        CGSize thumbnailSize = CGSizeMake(90.0f, 90.0f);
        CGSize renderSize = CGSizeZero;
        if (dimensions.width < dimensions.height)
        {
            renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
            renderSize.width = thumbnailSize.width;
        }
        else
        {
            renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
            renderSize.height = thumbnailSize.height;
        }
        
        [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
        
        if (legacyThumbnailCacheUri != nil)
            [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", legacyThumbnailCacheUri];
        
        filePreviewUri = previewUri;
    }
    
    [self setImageUri:filePreviewUri synchronously:synchronously];
    
    if (self.window != nil && _isEditing && _isEditing())
        [self startShakeAnimation:false];
    else
        [self stopShakeAnimation:false];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (void)checkButtonPressed
{
    if (_isItemSelected && _itemSelected)
    {
        _itemSelected((id<TGWebSearchListItem>)self.item);
        [_checkButton setChecked:_isItemSelected((id<TGWebSearchListItem>)self.item) animated:true];
    }
}

- (void)updateItemHiddenAnimated:(bool)animated
{
    if (_isItemHidden)
    {
        bool hidden = _isItemHidden((id<TGWebSearchListItem>)self.item);
        if (hidden != self.imageView.hidden)
        {
            self.imageView.hidden = hidden;
            
            if (animated)
            {
                if (!hidden)
                    _checkButton.alpha = 0.0f;
                [UIView animateWithDuration:0.2 animations:^
                 {
                     if (!hidden)
                         _checkButton.alpha = 1.0f;
                 }];
            }
            else
            {
                self.imageView.hidden = hidden;
                _checkButton.alpha = hidden ? 0.0f : 1.0f;
            }
        }
    }
}

- (void)updateItemSelected
{
    if (_isItemSelected)
    {
        bool checked = _isItemSelected((id<TGWebSearchListItem>)self.item);
        if (checked != _checkButton.checked)
            [_checkButton setChecked:_isItemSelected((id<TGWebSearchListItem>)self.item) animated:false];
    }
}

- (void)updateIsEditing
{
    if (self.window != nil && _isEditing && _isEditing())
        [self startShakeAnimation:true];
    else
        [self stopShakeAnimation:true];
}

#define Y_OFFSET 0.5f
#define X_OFFSET 0.5f
#define ANGLE_OFFSET ((CGFloat)M_PI_4*0.07f)

-(void)startShakeAnimation:(bool)animated
{
    if ([self.layer animationForKey:@"shake_translation_x"] != nil)
        return;
    
    CFTimeInterval offset=(double)arc4random()/(double)RAND_MAX;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, -ANGLE_OFFSET*0.5f);
    transform = CGAffineTransformTranslate(transform, -X_OFFSET*0.5f, -Y_OFFSET*0.5f);
    transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
    
    if (animated)
    {
        [UIView animateWithDuration:0.15 animations:^
         {
             self.imageView.transform = transform;
             _checkButton.alpha = 0.0f;
         }];
    }
    else
    {
        self.imageView.transform = transform;
        _checkButton.alpha = 0.0f;
    }
    
    CABasicAnimation *tAnim=[CABasicAnimation animationWithKeyPath:@"position.x"];
    tAnim.repeatCount=HUGE_VALF;
    tAnim.byValue=[NSNumber numberWithFloat:X_OFFSET];
    tAnim.duration=0.07f;
    tAnim.autoreverses=YES;
    tAnim.timeOffset=offset;
    [self.imageView.layer addAnimation:tAnim forKey:@"shake_translation_x"];
    
    CABasicAnimation *tyAnim=[CABasicAnimation animationWithKeyPath:@"position.y"];
    tyAnim.repeatCount=HUGE_VALF;
    tyAnim.byValue=[NSNumber numberWithFloat:Y_OFFSET];
    tyAnim.duration=0.07f;
    tyAnim.autoreverses=YES;
    tyAnim.timeOffset=offset;
    [self.imageView.layer addAnimation:tyAnim forKey:@"shake_translation_y"];
    
    CABasicAnimation *rAnim=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rAnim.repeatCount=HUGE_VALF;
    rAnim.byValue=[NSNumber numberWithFloat:(float)ANGLE_OFFSET];
    rAnim.duration=0.11f;
    rAnim.autoreverses=YES;
    rAnim.timeOffset=offset;
    rAnim.speed = 1.0f + arc4random_uniform(200) / 1000.0f;
    [self.imageView.layer addAnimation:rAnim forKey:@"shake_rotation"];
}

-(void)stopShakeAnimation:(bool)animated
{
    [self.imageView.layer removeAnimationForKey:@"shake_translation_x"];
    [self.imageView.layer removeAnimationForKey:@"shake_translation_y"];
    [self.imageView.layer removeAnimationForKey:@"shake_rotation"];
    
    if (animated)
    {
        [UIView animateWithDuration:0.15 animations:^
         {
             self.imageView.transform = CGAffineTransformIdentity;
             _checkButton.alpha = 1.0f;
         }];
    }
    else
    {
        self.imageView.transform = CGAffineTransformIdentity;
        _checkButton.alpha = 1.0f;
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window != nil && _isEditing && _isEditing())
        [self startShakeAnimation:false];
    else
        [self stopShakeAnimation:false];
}

@end
