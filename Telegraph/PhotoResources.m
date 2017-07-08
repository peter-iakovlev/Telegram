#import "PhotoResources.h"

#import "TGMessage.h"
#import "TelegramMediaResources.h"
#import "MediaBox.h"

#import "TGImageInfo+Telegraph.h"

#import "ImageResourceDatas.h"

#import "DrawingContext.h"
#import "TransformImageView.h"

#import "TGImageUtils.h"
#import "TGImageBlur.h"

#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

#import "TGAppDelegate.h"
#import "TGTelegramNetworking.h"

static NSString *pathForPhotoDirectory(TGImageMediaAttachment *imageAttachment) {
    static NSString *filesDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        filesDirectory = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"files"];
    });
    
    NSString *photoDirectoryName = nil;
    if (imageAttachment.imageId != 0)
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-remote-%" PRIx64 "", imageAttachment.imageId];
    else
        photoDirectoryName = [[NSString alloc] initWithFormat:@"image-local-%" PRIx64 "", imageAttachment.localImageId];
    return [filesDirectory stringByAppendingPathComponent:photoDirectoryName];
}

static id<MediaResource> imageUrlResource(NSString *url, int fileSize, NSString *legacyCacheUrl, NSString *legacyFilePath) {
    if (url != nil) {
        int datacenterId = 0;
        int64_t volumeId = 0;
        int localId = 0;
        int64_t secret = 0;
        if (extractFileUrlComponents(url, &datacenterId, &volumeId, &localId, &secret)) {
            return [[CloudFileMediaResource alloc] initWithDatacenterId:datacenterId volumeId:volumeId localId:localId secret:secret size:fileSize == 0 ? nil : @(fileSize) legacyCacheUrl:legacyCacheUrl legacyCachePath:legacyFilePath mediaType:@(TGNetworkMediaTypeTagImage)];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

static id<MediaResource> imageThumbnailResource(TGImageMediaAttachment *image, CGSize *resultingSize) {
    int fileSize = 0;
    NSString *url = [image.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:resultingSize resultingFileSize:&fileSize];
    if (url != nil) {
        NSString *photoDirectoryPath = pathForPhotoDirectory(image);
        NSString *genericThumbnailPath = [photoDirectoryPath stringByAppendingPathComponent:@"image-thumb.jpg"];
        
        return imageUrlResource(url, fileSize, url, genericThumbnailPath);
    } else {
        return nil;
    }
}

static id<MediaResource> videoThumbnailResource(TGVideoMediaAttachment *video, CGSize *resultingSize) {
    int fileSize = 0;
    NSString *url = [video.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:resultingSize resultingFileSize:&fileSize];
    if (url != nil) {
        return imageUrlResource(url, fileSize, url, nil);
    } else {
        return nil;
    }
}

/*static id<MediaResource> documentThumbnailResource(TGDocumentMediaAttachment *document, CGSize *resultingSize) {
    int fileSize = 0;
    NSString *url = [document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:resultingSize resultingFileSize:&fileSize];
    if (url != nil) {
        return imageUrlResource(url, fileSize, url, nil);
    } else {
        return nil;
    }
}*/

id<MediaResource> imageFullSizeResource(TGImageMediaAttachment *image, CGSize *resultingSize) {
    int fileSize = 0;
    NSString *url = [image.imageInfo closestImageUrlWithSize:CGSizeMake(1136.0f, 1136.0f) resultingSize:resultingSize resultingFileSize:&fileSize];
    if (url != nil) {
        return imageUrlResource(url, fileSize, url, nil);
    } else {
        return nil;
    }
}

id<MediaResource> videoFullSizeResource(TGVideoMediaAttachment *video) {
    NSString *url = [video.videoInfo urlWithQuality:0 actualQuality:nil actualSize:nil];
    NSArray *urlComponents = [url componentsSeparatedByString:@":"];
    if (urlComponents.count >= 5) {
        int64_t videoId = [[urlComponents objectAtIndex:1] longLongValue];
        int64_t accessHash = [[urlComponents objectAtIndex:2] longLongValue];
        int32_t datacenterId = [[urlComponents objectAtIndex:3] intValue];
        int32_t fileSize = [[urlComponents objectAtIndex:4] intValue];
        
        return [[CloudDocumentMediaResource alloc] initWithDatacenterId:datacenterId fileId:videoId accessHash:accessHash size:fileSize == 0 ? nil : @(fileSize) mediaType:@(TGNetworkMediaTypeTagVideo)];
    } else {
        return nil;
    }
}

static SSignal *imageMediaDatas(MediaBox *mediaBox, TGImageMediaAttachment *image, bool autoFetchFullSize) {
    CGSize thumbnailSize = CGSizeZero;
    CGSize fullSize = CGSizeZero;
    id<MediaResource> thumbnailResource = imageThumbnailResource(image, &thumbnailSize);
    id<MediaResource> fullSizeResource = imageFullSizeResource(image, &fullSize);
    
    if (thumbnailResource != nil && fullSizeResource != nil) {
        SSignal *maybeFullSize = [mediaBox resourceData:fullSizeResource pathExtension:nil];
        
        return [[maybeFullSize take:1] mapToSignal:^SSignal *(ResourceData *maybeData) {
            if (maybeData.complete) {
                NSData *data = [NSData dataWithContentsOfFile:maybeData.path options:0 error:nil];
                return [SSignal single:[[ImageResourceDatas alloc] initWithThumbnail:nil fullSize:data complete:true]];
            } else {
                SSignal *fetchedThumbnail = [mediaBox fetchedResource:thumbnailResource];
                SSignal *fetchedFullSize = [mediaBox fetchedResource:fullSizeResource];
                
                SSignal *thumbnail = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                    id<SDisposable> fetchedDisposable = [fetchedThumbnail startWithNext:nil];
                    id<SDisposable> thumbnailDisposable = [[mediaBox resourceData:thumbnailResource pathExtension:nil] startWithNext:^(ResourceData *next) {
                        [subscriber putNext:(next.size == 0 || !next.complete) ? nil : [NSData dataWithContentsOfFile:next.path options:0 error:nil]];
                    } error:^(id error) {
                        [subscriber putError:error];
                    } completed:^{
                        [subscriber putCompletion];
                    }];
                    return [[SBlockDisposable alloc] initWithBlock:^{
                        [fetchedDisposable dispose];
                        [thumbnailDisposable dispose];
                    }];
                }];
                
                SSignal *fullSizeData = nil;
                
                if (autoFetchFullSize) {
                    fullSizeData = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                        id<SDisposable> fetchedFullSizeDisposable = [fetchedFullSize startWithNext:nil];
                        id<SDisposable> fullSizeDisposable = [[mediaBox resourceData:fullSizeResource pathExtension:nil] startWithNext:^(ResourceData *next) {
                            [subscriber putNext:(next.size == 0 || !next.complete) ? nil : [NSData dataWithContentsOfFile:next.path options:0 error:nil]];
                        } error:^(id error) {
                            [subscriber putError:error];
                        } completed:^{
                            [subscriber putCompletion];
                        }];
                        return [[SBlockDisposable alloc] initWithBlock:^{
                            [fetchedFullSizeDisposable dispose];
                            [fullSizeDisposable dispose];
                        }];
                    }];
                } else {
                    fullSizeData = [[mediaBox resourceData:fullSizeResource pathExtension:nil] map:^id(ResourceData *next) {
                        return (next.size == 0 || !next.complete) ? nil : [NSData dataWithContentsOfFile:next.path options:0 error:nil];
                    }];
                }
                
                return [thumbnail mapToSignal:^SSignal *(NSData *thumbnailData) {
                    return [fullSizeData map:^id(NSData *fullSizeData) {
                        return [[ImageResourceDatas alloc] initWithThumbnail:thumbnailData fullSize:fullSizeData complete:fullSizeData != nil];
                    }];
                }];
            }
        }];
    } else {
        return [SSignal fail:nil];
    }
}

static SSignal *videoMediaDatas(MediaBox *mediaBox, TGVideoMediaAttachment *video) {
    id<MediaResource> thumnbnailResource = videoThumbnailResource(video, nil);
    id<MediaResource> fullSizeResource = videoFullSizeResource(video);
    
    if (thumnbnailResource != nil && fullSizeResource != nil) {
        SSignal *maybeFullSize = [mediaBox resourceData:fullSizeResource pathExtension:@"mp4"];
        
        return [[maybeFullSize take:1] mapToSignal:^SSignal *(ResourceData *maybeData) {
            if (maybeData.complete) {
                return [SSignal single:[[FileResourceDatas alloc] initWithThumbnail:nil fullSizePath:maybeData.path]];
            } else {
                SSignal *fetchedThumbnail = [mediaBox fetchedResource:thumnbnailResource];
                SSignal *thumbnail = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                    id<SDisposable> fetchedDisposable = [fetchedThumbnail startWithNext:nil];
                    id<SDisposable> thumbnailDisposable = [[mediaBox resourceData:thumnbnailResource pathExtension:nil] startWithNext:^(ResourceData *next) {
                        [subscriber putNext:next.complete ? [NSData dataWithContentsOfFile:next.path] : nil];
                    } error:^(id error) {
                        [subscriber putError:error];
                    } completed:^{
                        [subscriber putCompletion];
                    }];
                    return [[SBlockDisposable alloc] initWithBlock:^{
                        [fetchedDisposable dispose];
                        [thumbnailDisposable dispose];
                    }];
                }];
                
                SSignal *fullSizePath = [[mediaBox resourceData:fullSizeResource pathExtension:@"mp4"] map:^id(ResourceData *next) {
                    return next.complete ? next.path : nil;
                }];
                
                return [thumbnail mapToSignal:^SSignal *(NSData *thumbnailData) {
                    return [fullSizePath map:^id(NSString *fullSizePath) {
                        return [[FileResourceDatas alloc] initWithThumbnail:thumbnailData fullSizePath:fullSizePath];
                    }];
                }];
            }
        }];
    } else {
        return [SSignal fail:nil];
    }
}


static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    CGFloat fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

SSignal *imageMediaTransform(MediaBox *mediaBox, TGImageMediaAttachment *image, bool autoFetchFullSize) {
    return [imageMediaDatas(mediaBox, image, autoFetchFullSize) map:^id(ImageResourceDatas *datas) {
        DrawingContext *(^transform)(TransformImageArguments *) = ^DrawingContext *(TransformImageArguments *arguments) {
            DrawingContext *context = [[DrawingContext alloc] initWithSize:arguments.boundingSize scale:0.0f clear:true];
            
            CGSize fittedSize = TGScaleToFill(arguments.imageSize, arguments.boundingSize);
            CGRect fittedRect = CGRectMake((arguments.boundingSize.width - fittedSize.width) / 2.0f, (arguments.boundingSize.height - fittedSize.height) / 2.0f, fittedSize.width, fittedSize.height);
            
            UIImage *fullSizeImage = nil;
            if (datas.fullSize != nil && datas.complete) {
                NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
                [options setObject:@(MAX(fittedSize.width * context.scale, fittedSize.height * context.scale)) forKey:(__bridge id)kCGImageSourceThumbnailMaxPixelSize];
                [options setObject:@true forKey:(__bridge id)kCGImageSourceCreateThumbnailFromImageAlways];
                CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)datas.fullSize, nil);
                if (imageSource != nil) {
                    CGImageRef cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
                    if (cgImage != nil) {
                        CFRelease(imageSource);
                        fullSizeImage = [[UIImage alloc] initWithCGImage:cgImage];
                        CFRelease(cgImage);
                    } else {
                        cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
                        CFRelease(imageSource);
                        if (cgImage != nil) {
                            fullSizeImage = [[UIImage alloc] initWithCGImage:cgImage];
                            CFRelease(cgImage);
                        }
                    }
                }
            }
            
            UIImage *thumbnailImage = nil;
            if (datas.fullSize == nil && datas.thumbnail != nil) {
                CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)datas.thumbnail, nil);
                if (imageSource != nil) {
                    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
                    CFRelease(imageSource);
                    if (cgImage != nil) {
                        thumbnailImage = [[UIImage alloc] initWithCGImage:cgImage];
                        CFRelease(cgImage);
                    }
                }
            }
            
            UIImage *blurredThumbnailImage = nil;
            if (thumbnailImage != nil) {
                CGSize blurContextSize = thumbnailImage.size;
                DrawingContext *blurContext = [[DrawingContext alloc] initWithSize:blurContextSize scale:1.0f clear:false];
                [blurContext withFlippedContext:^(CGContextRef context) {
                    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
                    CGContextSetBlendMode(context, kCGBlendModeCopy);
                    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, thumbnailImage.size.width, thumbnailImage.size.height), thumbnailImage.CGImage);
                }];
                telegramFastBlur((int32_t)blurContextSize.width, (int32_t)blurContextSize.height, (int32_t)blurContext.bytesPerRow, blurContext.bytes);
                blurredThumbnailImage = [blurContext generateImage];
            }
            
            [context withFlippedContext:^(CGContextRef context) {
                if (arguments.cornerRadius > FLT_EPSILON) {
                    //CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    //CGContextFillRect(context, CGRectMake(0.0f, 0.0f, arguments.boundingSize.width, arguments.boundingSize.height));
                    
                    CGContextBeginPath(context);
                    CGRect rect = CGRectMake(0.0f, 0.0f, arguments.boundingSize.width, arguments.boundingSize.height);
                    addRoundedRectToPath(context, rect, (float)arguments.cornerRadius, (float)arguments.cornerRadius);
                    CGContextClosePath(context);
                    CGContextClip(context);
                }
                
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                if (!CGSizeEqualToSize(arguments.boundingSize, arguments.imageSize)) {
                    //CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    //CGContextFillRect(context, CGRectMake(0.0f, 0.0f, arguments.boundingSize.width, arguments.boundingSize.height));
                }
                
                if (blurredThumbnailImage != nil) {
                    CGContextSetInterpolationQuality(context, kCGInterpolationLow);
                    CGContextDrawImage(context, fittedRect, blurredThumbnailImage.CGImage);
                }
                
                if (fullSizeImage != nil) {
                    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
                    CGContextDrawImage(context, fittedRect, fullSizeImage.CGImage);
                }
            }];
            
            return context;
        };
        
        return [transform copy];
    }];
}

SSignal *videoMediaTransform(MediaBox *mediaBox, TGVideoMediaAttachment *video) {
    SSignal *videoDatas = videoMediaDatas(mediaBox, video);
    
    return [videoDatas map:^id(FileResourceDatas *datas) {
        DrawingContext *(^transform)(TransformImageArguments *) = ^DrawingContext *(TransformImageArguments *arguments) {
            UIImage *fullSizeImage = nil;
            if (datas.fullSizePath != nil) {
                AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:datas.fullSizePath]];
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                imageGenerator.maximumSize = CGSizeMake(800.0f, 800.0f);
                imageGenerator.appliesPreferredTrackTransform = true;
                CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, asset.duration.timescale) actualTime:nil error:nil];
                if (cgImage != nil) {
                    fullSizeImage = [[UIImage alloc] initWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                }
            }
            
            UIImage *thumbnailImage = nil;
            if (fullSizeImage == nil && datas.thumbnail != nil) {
                CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)datas.thumbnail, nil);
                if (imageSource != nil) {
                    CGImageRef cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
                    CFRelease(imageSource);
                    if (cgImage != nil) {
                        thumbnailImage = [[UIImage alloc] initWithCGImage:cgImage];
                        CFRelease(cgImage);
                    }
                }
            }
            
            UIImage *blurredThumbnailImage = nil;
            if (thumbnailImage != nil) {
                CGSize blurContextSize = thumbnailImage.size;
                DrawingContext *blurContext = [[DrawingContext alloc] initWithSize:blurContextSize scale:1.0f clear:false];
                [blurContext withFlippedContext:^(CGContextRef context) {
                    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
                    CGContextSetBlendMode(context, kCGBlendModeCopy);
                    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, thumbnailImage.size.width, thumbnailImage.size.height), thumbnailImage.CGImage);
                }];
                telegramFastBlur((int32_t)blurContextSize.width, (int32_t)blurContextSize.height, (int32_t)blurContext.bytesPerRow, blurContext.bytes);
                blurredThumbnailImage = [blurContext generateImage];
            }
            
            if (arguments.scaleToFit) {
                if (fullSizeImage != nil) {
                    arguments = [[TransformImageArguments alloc] initWithImageSize:fullSizeImage.size boundingSize:fullSizeImage.size cornerRadius:0.0f];
                } else if (blurredThumbnailImage != nil) {
                    arguments = [[TransformImageArguments alloc] initWithImageSize:blurredThumbnailImage.size boundingSize:blurredThumbnailImage.size cornerRadius:0.0f];
                } else {
                    arguments = [[TransformImageArguments alloc] initWithImageSize:CGSizeMake(1.0f, 1.0f) boundingSize:CGSizeMake(1.0f, 1.0f) cornerRadius:0.0f];
                }
            }
            
            DrawingContext *context = [[DrawingContext alloc] initWithSize:arguments.boundingSize scale:0.0 clear:true];
            
            CGSize fittedSize = TGScaleToFill(arguments.imageSize, arguments.boundingSize);
            CGRect fittedRect = CGRectMake((arguments.boundingSize.width - fittedSize.width) / 2.0f, (arguments.boundingSize.height - fittedSize.height) / 2.0f, fittedSize.width, fittedSize.height);
            
            [context withFlippedContext:^(CGContextRef context) {
                CGContextSetBlendMode(context, kCGBlendModeCopy);
                if (!CGSizeEqualToSize(arguments.boundingSize, arguments.imageSize)) {
                    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
                    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, arguments.boundingSize.width, arguments.boundingSize.height));
                }
                
                if (blurredThumbnailImage != nil) {
                    CGContextSetInterpolationQuality(context, kCGInterpolationLow);
                    CGContextDrawImage(context, fittedRect, blurredThumbnailImage.CGImage);
                }
                
                if (fullSizeImage != nil) {
                    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);
                    CGContextDrawImage(context, fittedRect, fullSizeImage.CGImage);
                }
            }];
            
            return context;
        };
        return [transform copy];
    }];
}
