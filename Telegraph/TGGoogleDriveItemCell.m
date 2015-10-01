#import "TGGoogleDriveItemCell.h"

#import "TGFont.h"
#import "TGImageView.h"
#import "TGStringUtils.h"

#import "GDGoogleDriveURLMetadata.h"
#import "GDGoogleDriveMetadata.h"

NSString *const TGGoogleDriveItemCellKind = @"TGGoogleDriveItemCellKind";

@interface TGGoogleDriveItemCell ()
{
    bool _isDirectory;
    TGImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_attributesLabel;
    UIView *_separatorView;
}
@end

@implementation TGGoogleDriveItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        _iconView = [[TGImageView alloc] init];
        [self.contentView addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
        
        _attributesLabel = [[UILabel alloc] init];
        _attributesLabel.backgroundColor = [UIColor clearColor];
        _attributesLabel.font = TGSystemFontOfSize(12);
        _attributesLabel.textColor = UIColorRGB(0x8e8e93);
        [self.contentView addSubview:_attributesLabel];
        
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_separatorView];
    }
    return self;
}

- (void)prepareForReuse
{
    [_iconView reset];
}

- (void)configureWithMetadata:(GDURLMetadata *)urlMetadata
{
    GDGoogleDriveURLMetadata *driveUrlMetadata = urlMetadata.driveMetadata;
    GDGoogleDriveMetadata *metadata = nil;
    if (driveUrlMetadata != nil)
        metadata = driveUrlMetadata.metadata;
    
    if ([self respondsToSelector:@selector(setSeparatorInset:)])
        self.separatorInset = UIEdgeInsetsMake(0, 52, 0, 0);
    
    _titleLabel.text = urlMetadata.filename;
    _isDirectory = urlMetadata.isDirectory;
    if (urlMetadata.isDirectory)
    {
        [_iconView loadUri:@"embedded://" withOptions:@{TGImageViewOptionEmbeddedImage:[UIImage imageNamed:@"GoogleDriveFolder.png"]}];
        _titleLabel.font = TGBoldSystemFontOfSize(17);
        _attributesLabel.hidden = true;
    }
    else
    {
        if (metadata.thumbnailURLString.length > 0 && ![urlMetadata.filename hasSuffix:@".webp"])
        {
            [_iconView reset];
            NSString *url = [[NSString alloc] initWithFormat:@"google-drive-thumbnail://?url=%@&width=%d&height=%d", [TGStringUtils stringByEscapingForURL:metadata.thumbnailURLString], 72, 72];
            [_iconView loadUri:url withOptions:@{}];
        }
        else
        {
            [_iconView loadUri:@"embedded://" withOptions:@{TGImageViewOptionEmbeddedImage:[UIImage imageNamed:@"GoogleDriveFile.png"]}];
        }
        _titleLabel.font = TGSystemFontOfSize(17);
        _attributesLabel.hidden = false;
    }
    
    _attributesLabel.text = [NSString stringWithFormat:@"%@", [TGStringUtils stringForFileSize:urlMetadata.fileSize precision:2]];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _iconView.frame = CGRectMake(8, 8, 36, 36);
    
    if (_isDirectory)
        _titleLabel.frame = CGRectMake(52, 16, self.frame.size.width - 52 - 16, 20);
    else
        _titleLabel.frame = CGRectMake(52, 9, self.frame.size.width - 52 - 16, 20);
    
    _attributesLabel.frame = CGRectMake(52, 27, self.frame.size.width - 52 - 16, 20);
}

@end
