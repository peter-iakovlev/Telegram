#import "TGStickerPackRowController.h"

#import "TGStringUtils.h"

#import "TGBridgeStickerPack.h"

#import "WKInterfaceImage+Signals.h"
#import "TGBridgeMediaSignals.h"

NSString *const TGStickerPackRowIdentifier = @"TGStickerPackRow";

@implementation TGStickerPackRowController

- (void)updateWithStickerPack:(TGBridgeStickerPack *)stickerPack
{
    [self.image setSignal:[TGBridgeMediaSignals stickerWithDocumentAttachment:stickerPack.documents.firstObject type:TGMediaStickerImageTypeList] isVisible:self.isVisible];
    self.nameLabel.text = stickerPack.isBuiltIn ? TGLocalized(@"Stickers.BuiltinPackName") : stickerPack.title;
    self.countLabel.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"Stickers.StickerCount_" value:stickerPack.documents.count]), [[NSString alloc] initWithFormat:@"%d", (int)stickerPack.documents.count]];
}

- (void)notifyVisiblityChange
{
    [self.image updateIfNeeded];
}

+ (NSString *)identifier
{
    return TGStickerPackRowIdentifier;
}

@end
