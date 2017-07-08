#import "TGExternalShareSignals.h"

#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>

#import "TGStringUtils.h"

#import "TGMessage.h"

#import "TGImageManager.h"
#import "TGDownloadManager.h"
#import "TGVideoDownloadActor.h"
#import "TGRemoteImageView.h"

#import "TGMusicPlayerItemSignals.h"

@implementation TGExternalShareSignals

+ (SSignal *)shareItemForMessage:(TGMessage *)message {
    if (message.mediaAttachments.count > 0) {
        for (TGMediaAttachment *attachment in message.mediaAttachments) {
            switch (attachment.type) {
                case TGImageMediaAttachmentType:
                    return [self shareItemForPhotoMessage:message];
                    
                case TGVideoMediaAttachmentType:
                    return [[self shareItemForAudioVideoMessage:message] map:^id(NSURL *url) {
                        if (url.pathExtension.length > 0) {
                            return url;
                        } else {
                            NSString *path = [url.path stringByAppendingPathExtension:@"mov"];
                            [[NSFileManager defaultManager] createSymbolicLinkAtPath:path withDestinationPath:url.path error:nil];
                            return [NSURL fileURLWithPath:path];
                        }
                    }];
                    
                case TGLocationMediaAttachmentType:
                    return [self shareItemForLocationMessage:message];
                    
                case TGContactMediaAttachmentType:
                    return [self shareItemForContactMessage:message];
                    
                case TGDocumentMediaAttachmentType: {
                    TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                    if (documentAttachment.isSticker) {
                        return [self shareItemForSticker:message];
                    } else if (documentAttachment.isVoice) {
                        return [[self shareItemForAudioVideoMessage:message] map:^id(NSURL *url) {
                            if (url.pathExtension.length > 0) {
                                return url;
                            } else {
                                NSString *path = [url.path stringByAppendingPathExtension:@"ogg"];
                                [[NSFileManager defaultManager] createSymbolicLinkAtPath:path withDestinationPath:url.path error:nil];
                                return [NSURL fileURLWithPath:path];
                            }
                        }];
                    } else if (documentAttachment.isAnimated) {
                        return [self shareItemForAudioVideoMessage:message];
                    }
                }
                    
                case TGAudioMediaAttachmentType:
                    return [[self shareItemForAudioVideoMessage:message] map:^id(NSURL *url) {
                        if (url.pathExtension.length > 0) {
                            return url;
                        } else {
                            NSString *path = [url.path stringByAppendingPathExtension:@"ogg"];
                            [[NSFileManager defaultManager] createSymbolicLinkAtPath:path withDestinationPath:url.path error:nil];
                            return [NSURL fileURLWithPath:path];
                        }
                    }];
                    
                default:
                    break;
            }
        }
    }
    return [self shareItemForTextMessage:message];
}

+ (SSignal *)shareItemForPhotoMessage:(TGMessage *)message {
    TGImageMediaAttachment *imageAttachment = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments) {
        if (attachment.type == TGImageMediaAttachmentType) {
            imageAttachment = (TGImageMediaAttachment *)attachment;
            break;
        }
    }
    
    CGSize largestSize = CGSizeZero;
    NSString *legacyCacheUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&largestSize pickLargest:true];
    if (largestSize.width <= 90.0f + FLT_EPSILON || largestSize.height <= 90.0f + FLT_EPSILON) {
        legacyCacheUrl = [imageAttachment.imageInfo imageUrlForSizeLargerThanSize:CGSizeMake(1000.0f, 1000.0f) actualSize:&largestSize];
    }
    
    NSString *legacyThumbnailCacheUrl = [imageAttachment.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
    int64_t localImageId = 0;
    if (imageAttachment.imageId == 0 && legacyCacheUrl.length != 0)
    {
        localImageId = murMurHash32(legacyCacheUrl);
    }
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSMutableString *uri = [[NSMutableString alloc] initWithString:@"photo-thumbnail://?"];
        if (imageAttachment.imageId != 0)
            [uri appendFormat:@"id=%" PRId64 "", imageAttachment.imageId];
        else
            [uri appendFormat:@"local-id=%" PRId64 "", localImageId];
                
        [uri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)largestSize.width, (int)largestSize.height, (int)largestSize.width, (int)largestSize.height];
        
        NSString *legacyFilePath = nil;
        if ([legacyCacheUrl hasPrefix:@"file://"])
            legacyFilePath = [legacyCacheUrl substringFromIndex:@"file://".length];
        else
            legacyFilePath = [[TGRemoteImageView sharedCache] pathForCachedData:legacyCacheUrl];
        
        if (legacyFilePath != nil)
            [uri appendFormat:@"&legacy-file-path=%@", legacyFilePath];
        
        if (legacyThumbnailCacheUrl != nil)
            [uri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:legacyThumbnailCacheUrl]];
    
        id asyncTaskId = [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil partialCompletion:nil completion:^(UIImage *image)
        {
            if (image != nil)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[TGImageManager instance] cancelTaskWithId:asyncTaskId];
        }];
    }];
}

+ (TGMusicPlayerItem *)itemForMessage:(TGMessage *)message {
    id media = nil;
    
    for (TGMediaAttachment *attachment in message.mediaAttachments) {
        if (attachment.type == TGAudioMediaAttachmentType || attachment.type == TGVideoMediaAttachmentType || attachment.type == TGDocumentMediaAttachmentType) {
            media = attachment;
            break;
        }
    }
    
    if (media == nil)
        return nil;
    
    return [[TGMusicPlayerItem alloc] initWithKey:@(message.mid) media:media peerId:message.cid author:nil date:(int32_t)message.date performer:nil title:nil duration:0.0];
}

+ (SSignal *)shareItemForAudioVideoMessage:(TGMessage *)message {
    
    TGMusicPlayerItem *item = [self itemForMessage:message];
    return [[[TGMusicPlayerItemSignals itemAvailability:item priority:true] filter:^bool(id value) {
        TGMusicPlayerItemAvailability availability = TGMusicPlayerItemAvailabilityUnpack([value int64Value]);
        return availability.downloaded;
    }] map:^id(__unused id value) {
        return [NSURL fileURLWithPath:[TGMusicPlayerItemSignals pathForItem:item]];
    }];
}

+ (SSignal *)shareItemForSticker:(TGMessage *)message {
    TGDocumentMediaAttachment *documentAttachment = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments) {
        if (attachment.type == TGDocumentMediaAttachmentType) {
            documentAttachment = (TGDocumentMediaAttachment *)attachment;
            break;
        }
    }
    
    TGDocumentAttributeSticker *sticker = nil;
    TGDocumentAttributeImageSize *imageSize = nil;
    for (id attribute in documentAttachment.attributes) {
        if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]]) {
            sticker = (TGDocumentAttributeSticker *)attribute;
        } else if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
            imageSize = (TGDocumentAttributeImageSize *)attribute;
        }
    }
    
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSMutableString *uri = [[NSMutableString alloc] initWithString:@"sticker://?"];
        [uri appendFormat:@"documentId=%" PRId64 "", documentAttachment.documentId];
        [uri appendFormat:@"&accessHash=%" PRId64 "", documentAttachment.accessHash];
        [uri appendFormat:@"&datacenterId=%" PRId32 "", documentAttachment.datacenterId];
        [uri appendFormat:@"&fileName=%@", [TGStringUtils stringByEscapingForURL:documentAttachment.fileName]];
        [uri appendFormat:@"&size=%d", (int)documentAttachment.size];
        [uri appendFormat:@"&width=%d&height=%d", (int)imageSize.size.width, (int)imageSize.size.height];
        [uri appendFormat:@"&mime-type=%@", [TGStringUtils stringByEscapingForURL:documentAttachment.mimeType]];

        id asyncTaskId = [[TGImageManager instance] beginLoadingImageAsyncWithUri:uri decode:true progress:nil partialCompletion:nil completion:^(UIImage *image)
        {
            if (image != nil)
            {
                [subscriber putNext:image];
                [subscriber putCompletion];
            }
            else
            {
                [subscriber putError:nil];
            }
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [[TGImageManager instance] cancelTaskWithId:asyncTaskId];
        }];
    }];
}

+ (SSignal *)shareItemForLocationMessage:(TGMessage *)message {
    TGLocationMediaAttachment *locationAttachment = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments) {
        if (attachment.type == TGLocationMediaAttachmentType) {
            locationAttachment = (TGLocationMediaAttachment *)attachment;
            break;
        }
    }
    
    NSString *coordinatePair = [NSString stringWithFormat:@"%lf,%lf", locationAttachment.latitude, locationAttachment.longitude];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.apple.com/maps?ll=%@&q=%@&t=m", coordinatePair, coordinatePair]];
    
    return [SSignal single:url];
}

+ (SSignal *)shareItemForContactMessage:(TGMessage *)message {
    TGContactMediaAttachment *contactAttachment = nil;
    for (TGMediaAttachment *attachment in message.mediaAttachments) {
        if (attachment.type == TGContactMediaAttachmentType) {
            contactAttachment = (TGContactMediaAttachment *)attachment;
            break;
        }
    }
    
    NSString *firstName = contactAttachment.firstName;
    NSString *lastName = contactAttachment.lastName;
    NSString *phoneNumber = contactAttachment.phoneNumber;
    
    NSData *contactData = nil;
    NSString *filename = nil;
    
    if (iosMajorVersion() >= 9)
    {
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.givenName = firstName;
        contact.familyName = lastName;
        
        CNLabeledValue<CNPhoneNumber *> *phoneValue = [CNLabeledValue labeledValueWithLabel:nil value:[CNPhoneNumber phoneNumberWithStringValue:phoneNumber]];
        contact.phoneNumbers = @[ phoneValue ];
        
        NSError *error;
        contactData = [CNContactVCardSerialization dataWithContacts:@[ contact ] error:&error];
        
        if (error != nil)
            return nil;
        
        filename = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    }
    else
    {
        ABRecordRef contact = ABPersonCreate();
        
        ABMutableMultiValueRef phoneNumberMultiValue  = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(phoneNumber), kABPersonPhoneMobileLabel, NULL);
        
        CFErrorRef error = NULL;
        if (firstName.length > 0)
            ABRecordSetValue(contact, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), &error);
        if (lastName.length > 0)
            ABRecordSetValue(contact, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), &error);
        
        ABRecordSetValue(contact, kABPersonPhoneProperty, phoneNumberMultiValue, &error);
        
        if (error != NULL)
            return nil;
        
        contactData = (__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople((__bridge CFArrayRef)@[ (__bridge id)contact ]));
        
        filename = [[NSString stringWithFormat:@"%@ %@", firstName, lastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if (contactData.length == 0)
        return nil;
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.vcf", filename]]];
    if ([contactData writeToURL:tempDirectory atomically:true])
        return [SSignal single:tempDirectory];
    
    return [SSignal fail:nil];
}

+ (SSignal *)shareItemForTextMessage:(TGMessage *)message {
    return [SSignal single:message.text];
}

+ (SSignal *)shareItemsForMessages:(NSArray<TGMessage *> *)messages {
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    for (TGMessage *message in messages) {
        [signals addObject:[self shareItemForMessage:message]];
    }
    
    return [[SSignal combineSignals:signals] deliverOn:[SQueue mainQueue]];
}

@end
