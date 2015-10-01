#import "TGDocumentMessageIconView.h"

#import "TGFont.h"

#import "TGMessageImageView.h"

#import "TGMessageImageViewOverlayView.h"
#import "TGModernButton.h"

@interface TGDocumentMessageIconView ()
{
    UILabel *_extensionLabel;
    
    TGModernButton *_buttonView;
    TGMessageImageViewOverlayView *_overlayView;
    
    CGFloat _progress;
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGDocumentMessageIconView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        static UIImage *backgroundImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            UIImage *rawImage = [UIImage imageNamed:@"ModernDocumentMessageIconBackground.png"];
            backgroundImage = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:(int)(rawImage.size.height / 2)];
        });
        
        _extensionLabel = [[UILabel alloc] init];
        _extensionLabel.backgroundColor = [UIColor clearColor];
        _extensionLabel.opaque = false;
        _extensionLabel.textColor = TGAccentColor();
        _extensionLabel.font = TGSystemFontOfSize(19.0f);
        [self addSubview:_extensionLabel];
        
        CGFloat diameter = 44.0f;
        
        _buttonView = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, diameter, diameter)];
        _buttonView.exclusiveTouch = true;
        _buttonView.modernHighlight = true;
        [_buttonView addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, diameter, diameter)];
        [_overlayView setRadius:diameter];
        _overlayView.userInteractionEnabled = false;
        [_buttonView addSubview:_overlayView];
        
        static UIImage *highlightImage = nil;
        static dispatch_once_t onceToken2;
        dispatch_once(&onceToken2, ^
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.4f).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            highlightImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        });
        
        _buttonView.highlightImage = highlightImage;
    }
    return self;
}

- (void)willBecomeRecycled
{
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _extensionLabel.frame = CGRectMake(CGFloor((frame.size.width - _extensionLabel.bounds.size.width) / 2.0f), CGFloor((frame.size.height - _extensionLabel.bounds.size.height) / 2.0f), _extensionLabel.bounds.size.width, _extensionLabel.bounds.size.height);
    
    CGRect buttonFrame = _buttonView.frame;
    buttonFrame.origin = CGPointMake(CGFloor(frame.size.width - buttonFrame.size.width) / 2.0f, CGFloor(frame.size.height - buttonFrame.size.height) / 2.0f);
    if (!CGRectEqualToRect(_buttonView.frame, buttonFrame))
    {
        _buttonView.frame = buttonFrame;
    }
}

- (void)setIncoming:(bool)incoming
{
    _incoming = incoming;
    
    [_overlayView setOverlayStyle:incoming ? TGMessageImageViewOverlayStyleIncoming : TGMessageImageViewOverlayStyleOutgoing];
}

- (void)setFileName:(NSString *)fileName
{
    if (!TGStringCompare(_fileName, fileName))
    {
        _fileName = fileName;
        
        _extensionLabel.text = [fileName pathExtension];
        CGSize labelSize = [_extensionLabel sizeThatFits:CGSizeMake(65.0f, 1000.0f)];
        _extensionLabel.frame = CGRectMake(CGFloor((self.frame.size.width - labelSize.width) / 2.0f), CGFloor((self.frame.size.height - labelSize.height) / 2.0f), labelSize.width, labelSize.height);
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
        
        switch (_overlayType)
        {
            case TGMessageImageViewOverlayDownload:
            {
                if (_buttonView.superview == nil)
                {
                    [self addSubview:_buttonView];
                }
                
                _buttonView.alpha = 1.0f;
                _extensionLabel.alpha = 0.0f;
                
                [_overlayView setDownload];
                
                break;
            }
            case TGMessageImageViewOverlayPlay:
            {
                if (_buttonView.superview == nil)
                {
                    [self addSubview:_buttonView];
                }
                
                _buttonView.alpha = 1.0f;
                _extensionLabel.alpha = 0.0f;
                
                [_overlayView setPlay];
                
                break;
            }
            case TGMessageImageViewOverlayPlayMedia:
            {
                if (_buttonView.superview == nil)
                {
                    [self addSubview:_buttonView];
                }
                
                _buttonView.alpha = 1.0f;
                _extensionLabel.alpha = 0.0f;
                
                [_overlayView setPlayMedia];
                
                break;
            }
            case TGMessageImageViewOverlayPauseMedia:
            {
                if (_buttonView.superview == nil)
                {
                    [self addSubview:_buttonView];
                }
                
                _buttonView.alpha = 1.0f;
                _extensionLabel.alpha = 0.0f;
                
                [_overlayView setPauseMedia];
                
                break;
            }
            case TGMessageImageViewOverlayProgress:
            {
                if (_buttonView.superview == nil)
                {
                    [self addSubview:_buttonView];
                }
                
                _buttonView.alpha = 1.0f;
                _extensionLabel.alpha = 0.0f;
                
                [_overlayView setProgress:_progress animated:false];
                
                break;
            }
            case TGMessageImageViewOverlayNone:
            default:
            {
                if (_buttonView.superview != nil)
                {
                    if (animated)
                    {
                        [UIView animateWithDuration:0.2 animations:^
                         {
                             _buttonView.alpha = 0.0f;
                             _extensionLabel.alpha = 1.0f;
                         } completion:^(BOOL finished)
                         {
                             if (finished)
                             {
                                 [_buttonView removeFromSuperview];
                             }
                         }];
                    }
                    else
                    {
                        [_buttonView removeFromSuperview];
                        _extensionLabel.alpha = 1.0f;
                    }
                }
                
                break;
            }
        }
    }
    else if (_overlayType == TGMessageImageViewOverlayProgress)
    {
        [_overlayView setProgress:_progress animated:false];
    }
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:false];
}

- (void)setProgress:(CGFloat)progress animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON)
    {
        _progress = progress;
        
        if (_overlayType == TGMessageImageViewOverlayProgress)
            [_overlayView setProgress:progress animated:animated];
    }
}

- (void)actionButtonPressed
{
    TGMessageImageViewActionType action = TGMessageImageViewActionDownload;
    
    switch (_overlayType)
    {
        case TGMessageImageViewOverlayDownload:
        {
            action = TGMessageImageViewActionDownload;
            break;
        }
        case TGMessageImageViewOverlayProgress:
        {
            action = TGMessageImageViewActionCancelDownload;
            break;
        }
        case TGMessageImageViewOverlayPlay:
        case TGMessageImageViewOverlayPlayMedia:
        case TGMessageImageViewOverlayPauseMedia:
        {
            action = TGMessageImageViewActionPlay;
            break;
        }
        default:
            break;
    }
    
    id<TGMessageImageViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(messageImageViewActionButtonPressed:withAction:)])
        [delegate messageImageViewActionButtonPressed:(TGMessageImageView *)self withAction:action];
}

@end
