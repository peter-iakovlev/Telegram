#import "TGItemProviderSignals.h"

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>
#import <PassKit/PassKit.h>

#import "TGPhoneUtils.h"
#import "TGMimeTypeMap.h"

#import "TGContactModel.h"

@implementation TGItemProviderSignals

+ (NSArray *)itemSignalsForInputItems:(NSArray *)inputItems
{
    NSMutableArray *itemSignals = [[NSMutableArray alloc] init];
    NSMutableArray *providers = [[NSMutableArray alloc] init];
    
    for (NSExtensionItem *item in inputItems)
    {
        for (NSItemProvider *provider in item.attachments)
        {
            if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [providers removeAllObjects];
                
                [providers addObject:provider];
                break;
            }
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeVCard])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeData])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:@"com.apple.pkpass"])
                [providers addObject:provider];
        }
    }
    
    NSInteger providerIndex = -1;
    for (NSItemProvider *provider in providers)
    {
        providerIndex++;
        
        SSignal *dataSignal = nil;
        if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio])
            dataSignal = [self signalForAudioItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie])
            dataSignal = [self signalForVideoItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeGIF])
            dataSignal = [self signalForDataItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage])
            dataSignal = [self signalForImageItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL])
        {
            dataSignal = [[self signalForUrlItemProvider:provider] mapToSignal:^SSignal *(NSURL *url)
            {
                NSData *data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
                if (data == nil)
                    return [SSignal fail:nil];
                NSString *fileName = [[url pathComponents] lastObject];
                if (fileName.length == 0)
                    fileName = @"file.bin";
                NSString *extension = [fileName pathExtension];
                NSString *mimeType = [TGMimeTypeMap mimeTypeForExtension:[extension lowercaseString]];
                if (mimeType == nil)
                    mimeType = @"application/octet-stream";
                return [SSignal single:@{@"data": data, @"fileName": fileName, @"mimeType": mimeType}];
            }];
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeVCard])
            dataSignal = [self signalForVCardItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText])
            dataSignal = [self signalForTextItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL])
            dataSignal = [self signalForTextUrlItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeData])
        {
            dataSignal = [[self signalForDataItemProvider:provider] map:^id(NSDictionary *dict)
            {
                if (dict[@"fileName"] == nil)
                {
                    NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                    for (NSString *typeIdentifier in provider.registeredTypeIdentifiers)
                    {
                        NSString *extension = [TGMimeTypeMap extensionForMimeType:typeIdentifier];
                        if (extension == nil)
                            extension = [TGMimeTypeMap extensionForMimeType:[@"application/" stringByAppendingString:typeIdentifier]];
                        
                        if (extension != nil) {
                            updatedDict[@"fileName"] = [@"file" stringByAppendingPathExtension:extension];
                            updatedDict[@"mimeType"] = [TGMimeTypeMap mimeTypeForExtension:extension];
                        }
                    }
                    return updatedDict;
                }
                else
                {
                    return dict;
                }
            }];
        }
        else if ([provider hasItemConformingToTypeIdentifier:@"com.apple.pkpass"])
        {
            dataSignal = [self signalForPassKitItemProvider:provider];
        }

        if (dataSignal != nil)
            [itemSignals addObject:dataSignal];
    }
    
    return itemSignals;
}

+ (SSignal *)signalForDataItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeData options:nil completionHandler:^(NSData *data, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:@{@"data": data}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)signalForImageItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeData options:nil completionHandler:^(UIImage *image, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:@{@"image": image}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)signalForAudioItemProvider:(NSItemProvider *)itemProvider
{
    SSignal *itemSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeAudio options:nil completionHandler:^(NSURL *url, NSError *error)
        {
            if (error != nil)
               [subscriber putError:nil];
            else
            {
                [subscriber putNext:url];
                [subscriber putCompletion];
            }
        }];
        return nil;
    }];
    
    return [itemSignal map:^id(NSURL *url)
    {
        AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        if (asset == nil)
            return [SSignal fail:nil];
        
        NSString *extension = url.pathExtension;
        NSString *mimeType = [TGMimeTypeMap mimeTypeForExtension:[extension lowercaseString]];
        if (mimeType == nil)
            mimeType = @"application/octet-stream";
        
        NSString *title = (NSString *)[[AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon] firstObject];
        NSString *artist = (NSString *)[[AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon] firstObject];
        
        NSString *software = nil;
        AVMetadataItem *softwareItem = [[AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeySoftware keySpace:AVMetadataKeySpaceCommon] firstObject];
        if ([softwareItem isKindOfClass:[AVMetadataItem class]] && ([softwareItem.value isKindOfClass:[NSString class]]))
            software = (NSString *)[softwareItem value];
        
        bool isVoice = [software hasPrefix:@"com.apple.VoiceMemos"];
            
        NSTimeInterval duration =  CMTimeGetSeconds(asset.duration);
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
        result[@"audio"] = url;
        result[@"mimeType"] = mimeType;
        result[@"duration"] = @(duration);
        result[@"isVoice"] = @(isVoice);
        if (artist.length > 0)
            result[@"artist"] = artist;
        if (title.length > 0)
            result[@"title"] = title;
        
        return result;
    }];
}

+ (SSignal *)signalForVideoItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeMovie options:nil completionHandler:^(NSURL *url, NSError *error)
         {
             if (error != nil)
                 [subscriber putError:nil];
             else
             {
                 NSString *extension = url.pathExtension;
                 NSString *mimeType = [TGMimeTypeMap mimeTypeForExtension:[extension lowercaseString]];
                 if (mimeType == nil)
                     mimeType = @"application/octet-stream";
                 
                 AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                 NSString *software = nil;
                 AVMetadataItem *softwareItem = [[AVMetadataItem metadataItemsFromArray:asset.metadata withKey:AVMetadataCommonKeySoftware keySpace:AVMetadataKeySpaceCommon] firstObject];
                 if ([softwareItem isKindOfClass:[AVMetadataItem class]] && ([softwareItem.value isKindOfClass:[NSString class]]))
                     software = (NSString *)[softwareItem value];
                 
                 bool isAnimation = false;
                 if ([software hasPrefix:@"Boomerang"])
                     isAnimation = true;
                 
                 [subscriber putNext:@{@"video": asset, @"mimeType": mimeType, @"isAnimation": @(isAnimation)}];
                 [subscriber putCompletion];
             }
         }];
        
        return nil;
    }];
}

+ (SSignal *)signalForUrlItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeFileURL options:nil completionHandler:^(NSURL *url, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:url];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)signalForTextItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(NSString *text, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:@{@"text": text}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)signalForTextUrlItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:@{@"url": url}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)signalForVCardItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeVCard options:nil completionHandler:^(NSData *vcard, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                CFDataRef vCardData = CFDataCreate(NULL, vcard.bytes, vcard.length);
                ABAddressBookRef book = ABAddressBookCreate();
                ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
                CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
                CFIndex index = 0;
                ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
                
                NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
                
                if (firstName.length == 0 && lastName.length == 0)
                    lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
                
                ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                NSInteger phoneCount = (phones == NULL) ? 0 : ABMultiValueGetCount(phones);
                NSMutableArray *personPhones = [[NSMutableArray alloc] initWithCapacity:phoneCount];
                
                for (CFIndex i = 0; i < phoneCount; i++)
                {
                    NSString *number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
                    NSString *label = nil;
                    
                    CFStringRef valueLabel = ABMultiValueCopyLabelAtIndex(phones, i);
                    if (valueLabel != NULL)
                    {
                        label = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(valueLabel);
                        CFRelease(valueLabel);
                    }
                    
                    if (number.length != 0)
                    {
                        TGPhoneNumberModel *phoneNumber = [[TGPhoneNumberModel alloc] initWithPhoneNumber:number label:label];
                        [personPhones addObject:phoneNumber];
                    }
                }
                if (phones != NULL)
                    CFRelease(phones);
                
                TGContactModel *contact = [[TGContactModel alloc] initWithFirstName:firstName lastName:lastName phoneNumbers:personPhones];
                [subscriber putNext:@{@"contact": contact}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

+ (SSignal *)signalForPassKitItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:@"com.apple.pkpass" options:nil completionHandler:^(id data, NSError *error)
        {
            if (error != nil)
            {
                [subscriber putError:nil];
            }
            else
            {
                NSError *parseError;
                PKPass *pass = [[PKPass alloc] initWithData:data error:&parseError];
                if (parseError != nil)
                {
                    [subscriber putError:nil];
                }
                else
                {
                    NSString *fileName = [NSString stringWithFormat:@"%@.pkpass", pass.serialNumber];
                    [subscriber putNext:@{@"data": data, @"fileName": fileName, @"mimeType": @"application/vnd.apple.pkpass"}];
                    [subscriber putCompletion];
                }
            }
        }];
        
        return nil;
    }];
}

@end
