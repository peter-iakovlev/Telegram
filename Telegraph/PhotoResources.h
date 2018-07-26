#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "MediaBox.h"

@class TGImageMediaAttachment;
@class TGVideoMediaAttachment;
@class TGPassportFile;

SSignal *imageMediaTransform(MediaBox *mediaBox, TGImageMediaAttachment *image, bool autoFetchFullSize);
SSignal *videoMediaTransform(MediaBox *mediaBox, TGVideoMediaAttachment *video);
SSignal *secureMediaTransform(MediaBox *mediaBox, TGPassportFile *file, bool thumbnail);
SSignal *secureUploadThumbnailTransform(UIImage *image);
id<MediaResource> imageFullSizeResource(TGImageMediaAttachment *image, CGSize *resultingSize);
id<MediaResource> videoFullSizeResource(TGVideoMediaAttachment *video);
id<MediaResource> secureResource(TGPassportFile *file, bool thumbnail);
