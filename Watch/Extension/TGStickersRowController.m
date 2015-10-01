#import "TGStickersRowController.h"

#import "WKInterfaceGroup+Signals.h"
#import "TGBridgeMediaSignals.h"

NSString *const TGStickersRowIdentifier = @"TGStickersRow";

@implementation TGStickersRowController

- (IBAction)leftStickerPressedAction
{
    if (self.leftStickerPressed != nil)
        self.leftStickerPressed();
}

- (IBAction)rightStickerPressedAction
{
    if (self.rightStickerPressed != nil)
        self.rightStickerPressed();
}

- (void)updateWithLeftSticker:(TGBridgeDocumentMediaAttachment *)leftSticker rightSticker:(TGBridgeDocumentMediaAttachment *)rightSticker
{
    [self.leftStickerImageGroup setBackgroundImageSignal:[TGBridgeMediaSignals stickerWithDocumentAttachment:leftSticker type:TGMediaStickerImageTypeNormal] isVisible:self.isVisible];
    [self.rightStickerImageGroup setBackgroundImageSignal:[TGBridgeMediaSignals stickerWithDocumentAttachment:rightSticker type:TGMediaStickerImageTypeNormal] isVisible:self.isVisible];
}

- (void)notifyVisiblityChange
{
    [self.leftStickerImageGroup updateIfNeeded];
    [self.rightStickerImageGroup updateIfNeeded];
}

+ (NSString *)identifier
{
    return TGStickersRowIdentifier;
}

@end
