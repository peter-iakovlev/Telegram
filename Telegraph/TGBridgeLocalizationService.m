#import "TGBridgeLocalizationService.h"
#import "TGBridgeServer.h"
#import "TGBridgeCommon.h"

#import "TGAppDelegate.h"

#import <CommonCrypto/CommonCrypto.h>

@interface TGBridgeLocalizationService ()
{
    SSignal *_localizationSignal;
    SMetaDisposable *_disposable;
}
@end


@implementation TGBridgeLocalizationService

- (instancetype)initWithServer:(TGBridgeServer *)server
{
    self = [super initWithServer:server];
    if (self != nil)
    {
        _localizationSignal = [[SSignal single:@(false)] then:[[server server] mapToSignal:^SSignal *(TGBridgeServer *server) {
            return [server pipeForKey:@"localization"];
        }]];
        
        __weak TGBridgeLocalizationService *weakSelf = self;
        _disposable = [[SMetaDisposable alloc] init];
        [_disposable setDisposable:[_localizationSignal startWithNext:^(NSNumber *next)
        {
            __strong TGBridgeLocalizationService *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool localizationEnabled = next.boolValue;
            
            [strongSelf.server setCustomLocalizationEnabled:localizationEnabled];
            
            NSURL *lastSentLocalizationUrl = [NSURL fileURLWithPath:@"Localizable.strings" relativeToURL:[strongSelf.server temporaryFilesURL]];
            if (localizationEnabled)
            {
                NSURL *currentLocalizationUrl = [NSURL fileURLWithPath:[[[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"CustomLocalization.bundle"] stringByAppendingPathComponent:@"Localizable.strings"]];
                
                NSString *currentLocalizationHash = [TGBridgeLocalizationService md5OfFileAtURL:currentLocalizationUrl];
                NSString *lastSentLocalizationHash = [TGBridgeLocalizationService md5OfFileAtURL:lastSentLocalizationUrl];
                
                if (lastSentLocalizationUrl == nil || ![currentLocalizationHash isEqualToString:lastSentLocalizationHash])
                {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:lastSentLocalizationUrl.path])
                        [[NSFileManager defaultManager] removeItemAtURL:lastSentLocalizationUrl error:nil];
                    
                    [[NSFileManager defaultManager] copyItemAtURL:currentLocalizationUrl toURL:lastSentLocalizationUrl error:nil];
                    [strongSelf.server sendFileWithURL:lastSentLocalizationUrl metadata:@{ TGBridgeIncomingFileIdentifierKey: @"localization" }];
                }
            }
            else
            {
                [[NSFileManager defaultManager] removeItemAtURL:lastSentLocalizationUrl error:nil];
            }
        }]];
    }
    return self;
}

+ (NSString *)md5OfFileAtURL:(NSURL *)url
{
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSMappedRead error:&error];
    if (error != nil)
        return nil;
    
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data.bytes, (uint32_t)data.length, md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
