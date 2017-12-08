#import "TGNotificationVenuePreviewView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGNotificationView.h"

#import <LegacyComponents/TGImageView.h>

@interface TGNotificationVenuePreviewView ()
{
    UIView *_wrapperView;
    TGImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_addressLabel;
    
    NSString *_imageUri;
    bool _loaded;
}
@end

@implementation TGNotificationVenuePreviewView

- (instancetype)initWithMessage:(TGMessage *)message conversation:(TGConversation *)conversation attachment:(TGLocationMediaAttachment *)attachment peers:(NSDictionary *)peers
{
    self = [super initWithMessage:message conversation:conversation peers:peers];
    if (self != nil)
    {
        self.userInteractionEnabled = false;
        
        TGVenueAttachment *venue = attachment.venue;
        
        [self setIcon:[UIImage imageNamed:@"MediaLocation"] text:TGLocalized(@"Message.Location")];
        
        _wrapperView = [[UIView alloc] initWithFrame:CGRectMake(TGNotificationPreviewContentInset.left, 0, 0, 29)];
        _wrapperView.alpha = 0.0f;
        _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _wrapperView.userInteractionEnabled = false;
        if (iosMajorVersion() >= 7)
            _wrapperView.layer.allowsGroupOpacity = true;
        [self addSubview:_wrapperView];

        _imageView = [[TGImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        [_wrapperView addSubview:_imageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = TGMediumSystemFontOfSize(13);
        _nameLabel.text = venue.title;
        _nameLabel.textColor = [UIColor whiteColor];
        [_wrapperView addSubview:_nameLabel];
        
        [_nameLabel sizeToFit];
        _nameLabel.frame = CGRectMake(36, -1, ceil(_nameLabel.frame.size.width), ceil(_nameLabel.frame.size.height));
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addressLabel.backgroundColor = [UIColor clearColor];
        _addressLabel.font = TGSystemFontOfSize(13);
        _addressLabel.text = venue.address;
        _addressLabel.textColor = [UIColor whiteColor];
        [_wrapperView addSubview:_addressLabel];
        
        [_addressLabel sizeToFit];
        _addressLabel.frame = CGRectMake(36, 15, ceil(_addressLabel.frame.size.width), ceil(_addressLabel.frame.size.height));
        
        CGSize mapImageSize = CGSizeMake(58.0f, 58.0f);
        _imageUri = [[NSString alloc] initWithFormat:@"map-thumbnail://?latitude=%f&longitude=%f&width=%d&height=%d&flat=1&cornerRadius=%d&offset=-10", attachment.latitude, attachment.longitude, (int)mapImageSize.width, (int)mapImageSize.height, 3];
    }
    return self;
}

- (void)setExpandProgress:(CGFloat)progress
{
    _expandProgress = progress;
    
    if (progress > FLT_EPSILON && !_loaded)
    {
        _loaded = true;
        [_imageView loadUri:_imageUri withOptions:@{}];
    }
    
    _wrapperView.alpha = progress * progress;
    [self _updateExpandProgress:progress hideText:true];
    
    [self setNeedsLayout];
}

- (CGFloat)expandedHeightForContainerSize:(CGSize)containerSize
{
    [super expandedHeightForContainerSize:containerSize];
    return _headerHeight + TGNotificationDefaultHeight + 2;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _wrapperView.frame = CGRectMake(_wrapperView.frame.origin.x, _textLabel.frame.origin.y + 4, self.frame.size.width - _wrapperView.frame.origin.x - TGNotificationPreviewContentInset.right, _wrapperView.frame.size.height);
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _wrapperView.frame.size.width - _nameLabel.frame.origin.x, _nameLabel.frame.size.height);
    _addressLabel.frame = CGRectMake(_addressLabel.frame.origin.x, _addressLabel.frame.origin.y, _wrapperView.frame.size.width - _addressLabel.frame.origin.x, _addressLabel.frame.size.height);
}

@end
