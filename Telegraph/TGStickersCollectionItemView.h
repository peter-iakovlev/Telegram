#import <LegacyComponents/TGMenuSheetItemView.h>

#import <LegacyComponents/LegacyComponentsContext.h>

@class TGStickerPack;
@class TGDocumentMediaAttachment;
@class TGPresentation;

@interface TGStickersCollectionItemView : TGMenuSheetItemView

@property (nonatomic, copy) void (^sendSticker)(TGDocumentMediaAttachment *);
@property (nonatomic, copy) void (^openLink)(NSString *);
@property (nonatomic, assign) bool collapseInLandscape;
@property (nonatomic, assign) bool hasShare;
@property (nonatomic, assign) bool largerTopMargin;

- (void)setStickerPack:(TGStickerPack *)stickerPack animated:(bool)animated;
- (void)setFailed;

- (void)setPresentation:(TGPresentation *)presentation;

@end

