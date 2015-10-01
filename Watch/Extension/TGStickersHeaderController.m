#import "TGStickersHeaderController.h"

NSString *const TGStickersHeaderIdentifier = @"TGStickersHeader";

@implementation TGStickersHeaderController

- (void)update
{
    self.nameLabel.text = TGLocalized(@"Stickers.StickerPacks");
}

+ (NSString *)identifier
{
    return TGStickersHeaderIdentifier;
}

@end
