#import "TGPreparedMessage.h"

#import "TGMediaAssetContentProperty.h"

@class TGImageInfo;
@class SSignalQueue;

@interface TGPreparedAssetVideoMessage : TGPreparedMessage

@property (nonatomic, readonly) NSString *assetIdentifier;
@property (nonatomic, readonly) int64_t localVideoId;
@property (nonatomic, readonly) TGImageInfo *imageInfo;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGSize dimensions;
@property (nonatomic, readonly) NSDictionary *adjustments;
@property (nonatomic, readonly) bool useMediaCache;
@property (nonatomic, readonly) bool liveUpload;
@property (nonatomic, readonly) bool passthrough;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *videoHash;
@property (nonatomic, assign) bool isCloud;

@property (nonatomic, readonly) bool document;
@property (nonatomic, readonly) int64_t localDocumentId;
@property (nonatomic, readonly) NSString *mimeType;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) int fileSize;
@property (nonatomic, strong) NSArray *attributes;

@property (nonatomic, strong) SSignalQueue *uploadQueue;

- (instancetype)initWithAssetIdentifier:(NSString *)assetIdentifier localVideoId:(int64_t)localVideoId imageInfo:(TGImageInfo *)imageInfo duration:(NSTimeInterval)duration dimensions:(CGSize)dimensions adjustments:(NSDictionary *)adjustments useMediaCache:(bool)useMediaCache liveUpload:(bool)liveUpload passthrough:(bool)passthrough caption:(NSString *)caption isCloud:(bool)isCloud document:(bool)document localDocumentId:(int64_t)localDocumentId fileSize:(int)fileSize mimeType:(NSString *)mimeType attributes:(NSArray *)attributes replyMessage:(TGMessage *)replyMessage;

- (void)setImageInfoWithThumbnailData:(NSData *)data thumbnailSize:(CGSize)thumbnailSize;

- (NSString *)localVideoPath;
- (NSString *)localThumbnailDataPath;

- (NSString *)localDocumentDirectory;
- (NSString *)localDocumentFileName;

@end
