#import "TGWebSearchInternalImageItemView.h"

#import "TGStringUtils.h"

#import "TGImagePickerCellCheckButton.h"

#import "TGImageView.h"

#import "TGWebSearchInternalImageItem.h"

@interface TGWebSearchInternalImageItemView ()
{
    TGImagePickerCellCheckButton *_checkButton;
}

@property (nonatomic, copy) bool (^isEditing)();
@property (nonatomic, copy) void (^toggleEditing)();
@property (nonatomic, copy) void (^itemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGWebSearchListItem>);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGWebSearchListItem>);

@end

@implementation TGWebSearchInternalImageItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {

    }
    return self;
}

- (void)setItem:(TGWebSearchInternalImageItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    [self setImageUri:item.imageUri synchronously:synchronously];
    
    self.isEditing = item.isEditing;
    self.toggleEditing = item.toggleEditing;
    self.itemSelected = item.itemSelected;
    self.isItemSelected = item.isItemSelected;
    self.isItemHidden = item.isItemHidden;
    
    [self updateItemHiddenAnimated:false];
    [self updateItemSelected];
    
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
    if (_isItemSelected != nil)
    {
        if (_checkButton == nil)
        {
            _checkButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 33.0f)];
            [_checkButton setChecked:false animated:false];
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_checkButton];
        }
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
