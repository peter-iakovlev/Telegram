#import <Foundation/Foundation.h>
#import "TGStickerPack.h"

@class TGViewController;
@class TGMenuSheetController;
@class TGDocumentMediaAttachment;

@interface TGStickersMenu : NSObject

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController
                                stickerPackReference:(id<TGStickerPackReference>)packReference
                                     showShareAction:(bool)showShareAction
                                         sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker
                                  stickerPackRemoved:(void (^)(id<TGStickerPackReference>))stickerPackRemoved
                                   stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))stickerPackHidden
                                          sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController
                                stickerPackReference:(id<TGStickerPackReference>)packReference
                                     showShareAction:(bool)showShareAction
                                         sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker
                                  stickerPackRemoved:(void (^)(id<TGStickerPackReference>))stickerPackRemoved
                                   stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))stickerPackHidden
                                          sourceView:(UIView *)sourceView centered:(bool)centered;

+ (TGMenuSheetController *)presentInParentController:(TGViewController *)parentController
                                         stickerPack:(TGStickerPack *)stickerPack
                                     showShareAction:(bool)showShareAction
                                         sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker
                                  stickerPackRemoved:(void (^)(id<TGStickerPackReference>))stickerPackRemoved
                                   stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))stickerPackHidden
                                 stickerPackArchived:(bool)stickerPackArchived
                                   stickerPackIsMask:(bool)stickerPackIsMask
                                          sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect;


+ (TGMenuSheetController *)presentWithParentController:(TGViewController *)parentController packReference:(id<TGStickerPackReference>)packReference stickerPack:(TGStickerPack *)stickerPack showShareAction:(bool)showShareAction sendSticker:(void (^)(TGDocumentMediaAttachment *))sendSticker stickerPackRemoved:(void (^)(id<TGStickerPackReference>))__unused stickerPackRemoved stickerPackHidden:(void (^)(id<TGStickerPackReference>, bool hidden))__unused stickerPackHidden stickerPackArchived:(bool)stickerPackArchived stickerPackIsMask:(bool)stickerPackIsMask sourceView:(UIView *)sourceView sourceRect:(CGRect (^)(void))sourceRect centered:(bool)centered existingController:(TGMenuSheetController *)existingController;

@end
