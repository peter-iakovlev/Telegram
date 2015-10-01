#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLStickerPack : NSObject <TLObject>

@property (nonatomic, retain) NSString *emoticon;
@property (nonatomic, retain) NSArray *documents;

@end

@interface TLStickerPack$stickerPack : TLStickerPack


@end

