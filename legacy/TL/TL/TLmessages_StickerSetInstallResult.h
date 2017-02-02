#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLmessages_StickerSetInstallResult : NSObject <TLObject>


@end

@interface TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultSuccess : TLmessages_StickerSetInstallResult


@end

@interface TLmessages_StickerSetInstallResult$messages_stickerSetInstallResultArchive : TLmessages_StickerSetInstallResult

@property (nonatomic, retain) NSArray *sets;

@end

