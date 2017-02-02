#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "MediaBox.h"

@class TGImageMediaAttachment;
@class TGVideoMediaAttachment;

SSignal *imageMediaTransform(MediaBox *mediaBox, TGImageMediaAttachment *image, bool autoFetchFullSize);
SSignal *videoMediaTransform(MediaBox *mediaBox, TGVideoMediaAttachment *video);
id<MediaResource> imageFullSizeResource(TGImageMediaAttachment *image, CGSize *resultingSize);
id<MediaResource> videoFullSizeResource(TGVideoMediaAttachment *video);
