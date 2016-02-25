#import <AVFoundation/AVFoundation.h>
#import "TGMediaSelectionContext.h"
#import "TGMediaEditingContext.h"

@interface AVURLAsset (TGMediaItem) <TGMediaSelectableItem, TGMediaEditableItem>

@end
