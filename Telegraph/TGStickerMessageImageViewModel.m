#import "TGStickerMessageImageViewModel.h"

#import "TGStickerMesageImageView.h"

@implementation TGStickerMessageImageViewModel

- (Class)viewClass
{
    return [TGStickerMesageImageView class];
}

- (void)setImageUri:(NSString *)imageUri
{
    _imageUri = imageUri;
    
    [((TGStickerMesageImageView *)self.boundView) loadUri:_imageUri withOptions:@{}];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    [((TGStickerMesageImageView *)self.boundView) loadUri:_imageUri withOptions:@{}];
}

@end
