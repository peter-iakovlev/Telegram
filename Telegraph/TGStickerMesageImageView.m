#import "TGStickerMesageImageView.h"

@interface TGStickerMesageImageView ()

@property (nonatomic, strong) NSString *viewIdentifier;

@end

@implementation TGStickerMesageImageView

- (void)willBecomeRecycled
{
}

- (NSString *)viewStateIdentifier
{
    return [[NSString alloc] initWithFormat:@"TGStickerMesageImageView/%lx", (long)self.image];
}

- (void)setViewStateIdentifier:(NSString *)__unused viewStateIdentifier
{
}

@end
