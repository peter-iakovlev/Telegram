#import "TGPaymentCheckoutHeaderItemView.h"

#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGSignalImageView.h"

#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"
#import "TGImageMediaAttachment.h"
#import "TGSharedMediaSignals.h"

@interface TGPaymentCheckoutHeaderItemView () {
    TGSignalImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_textLabel;
    UILabel *_labelLabel;
    UIView *_separatorView;
    TGImageMediaAttachment *_photo;
}

@end

@implementation TGPaymentCheckoutHeaderItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageView = [[TGSignalImageView alloc] init];
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = nil;
        _titleLabel.opaque = false;
        _titleLabel.font = TGBoldSystemFontOfSize(16.0);
        _titleLabel.textColor = [UIColor blackColor];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = nil;
        _textLabel.opaque = false;
        _textLabel.font = TGSystemFontOfSize(14.0);
        _textLabel.numberOfLines = 0;
        _textLabel.textColor = [UIColor blackColor];
        
        _labelLabel = [[UILabel alloc] init];
        _labelLabel.backgroundColor = nil;
        _labelLabel.opaque = false;
        _labelLabel.font = TGSystemFontOfSize(14.0);
        _labelLabel.textColor = UIColorRGB(0x999999);
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_textLabel];
        [self.contentView addSubview:_labelLabel];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = UIColorRGB(0xcccccc);
        [self.contentView addSubview:_separatorView];
    }
    return self;
}

- (void)setPhoto:(TGImageMediaAttachment *)photo title:(NSString *)title text:(NSString *)text label:(NSString *)label {
    NSString *key;
    _photo = photo;
    if (photo != nil) {
        if (photo.imageId != 0) {
            key = [[NSString alloc] initWithFormat:@"webpage-image-thumbnail-%" PRId64 "", photo.imageId];
        } else {
            key = [[NSString alloc] initWithFormat:@"webpage-image-thumbnail-local%" PRId64 "", photo.localImageId];
        }
        
        SSignal *signal = [TGSharedPhotoSignals squarePhotoThumbnail:photo ofSize:CGSizeMake(134.0f, 134.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:10.0f] downloadLargeImage:true placeholder:nil];
        [_imageView setSignal:signal];
        _imageView.hidden = false;
    } else {
        [_imageView setSignal:[SSignal single:nil]];
        _imageView.hidden = true;
    }
    
    _titleLabel.text = title;
    _textLabel.text = text;
    _labelLabel.text = label;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftInset = _photo == nil ? 15.0f : 160.0f;
    CGSize size = self.bounds.size;
    
    _imageView.frame = CGRectMake(15.0f, 15.0f, 134.0f, 134.0f);
    
    _titleLabel.frame = CGRectMake(leftInset, 16.0f, size.width - leftInset - 5.0f, 18.0f);
    
    CGSize textSize = [_textLabel.text sizeWithFont:_textLabel.font constrainedToSize:CGSizeMake(size.width - leftInset, size.height - 35.0f - 20.0f) lineBreakMode:NSLineBreakByWordWrapping];
    textSize.width = CGCeil(textSize.width);
    textSize.height = CGCeil(textSize.height);
    _textLabel.frame = CGRectMake(leftInset, 35.0f, size.width - leftInset - 5.0f, textSize.height);
    
    _labelLabel.frame = CGRectMake(leftInset, CGRectGetMaxY(_textLabel.frame) + 1.0, size.width - leftInset - 5.0f, 18.0f);
    
    _separatorView.frame = CGRectMake(0.0f, size.height - TGScreenPixel, size.width, TGScreenPixel);
}

@end
