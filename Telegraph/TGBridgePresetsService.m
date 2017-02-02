#import "TGBridgePresetsService.h"
#import "TGBridgeCommon.h"

#import "TGTelegraph.h"

#import <CommonCrypto/CommonCrypto.h>

NSString *const TGBridgePresetsPipeKey = @"presets";
NSString *const TGBridgePresetsDefaultsKey = @"TG_presets";

@interface TGBridgePresetsService ()
{
    SSignal *_presetsSignal;
    SMetaDisposable *_disposable;
}
@end

@implementation TGBridgePresetsService

- (instancetype)initWithServer:(TGBridgeServer *)server
{
    self = [super initWithServer:server];
    if (self != nil)
    {
        _presetsSignal = [[SSignal single:[TGBridgePresetsService currentPresets]] then:[server pipeForKey:TGBridgePresetsPipeKey]];
        
        __weak TGBridgePresetsService *weakSelf = self;
        _disposable = [[SMetaDisposable alloc] init];
        [_disposable setDisposable:[_presetsSignal startWithNext:^(NSDictionary *next)
        {
            __strong TGBridgePresetsService *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (![next isKindOfClass:[NSDictionary class]])
                return;
            
            NSURL *lastSentPresetsUrl = [NSURL fileURLWithPath:@"Presets.data" relativeToURL:[strongSelf.server temporaryFilesURL]];

            NSData *presetsData = [NSKeyedArchiver archivedDataWithRootObject:next];
        
            NSString *currentPresetsHash = [TGBridgePresetsService md5OfData:presetsData];
            NSString *lastSentPresetsHash = [TGBridgePresetsService md5OfFileAtURL:lastSentPresetsUrl];
            
            if (lastSentPresetsUrl == nil || ![currentPresetsHash isEqualToString:lastSentPresetsHash])
            {
                if ([[NSFileManager defaultManager] fileExistsAtPath:lastSentPresetsUrl.path])
                    [[NSFileManager defaultManager] removeItemAtURL:lastSentPresetsUrl error:nil];
        
                [presetsData writeToURL:lastSentPresetsUrl atomically:true];
                [strongSelf.server sendFileWithURL:lastSentPresetsUrl metadata:@{ TGBridgeIncomingFileIdentifierKey: @"presets" }];
            }
        }]];
    }
    return self;
}

+ (void)storePresets:(NSDictionary *)presets
{
    if (TGTelegraphInstance.clientUserId == 0 || !TGTelegraphInstance.clientIsActivated)
        return;
    
    [[TGBridgeServer instanceSignal] startWithNext:^(TGBridgeServer *server) {
        [server putNext:presets forKey:TGBridgePresetsPipeKey];
    }];
    
    if (presets != nil)
        [[NSUserDefaults standardUserDefaults] setObject:presets forKey:[self userDefaultsKey]];
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self userDefaultsKey]];
}

+ (NSDictionary *)currentPresets
{
    if (TGTelegraphInstance.clientUserId == 0 || !TGTelegraphInstance.clientIsActivated)
        return nil;
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self userDefaultsKey]];
}

+ (NSString *)userDefaultsKey
{
    return [NSString stringWithFormat:@"%@_%d", TGBridgePresetsDefaultsKey, TGTelegraphInstance.clientUserId];
}

+ (NSArray *)presetIdentifiers
{
    return @
    [
     @"Suggestion.OK",
     @"Suggestion.Thanks",
     @"Suggestion.WhatsUp",
     @"Suggestion.TalkLater",
     @"Suggestion.CantTalk",
     @"Suggestion.HoldOn",
     @"Suggestion.BRB",
     @"Suggestion.OnMyWay"
    ];
}

+ (NSString *)md5OfData:(NSData *)data
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data.bytes, (uint32_t)data.length, md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString *)md5OfFileAtURL:(NSURL *)url
{
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSMappedRead error:&error];
    if (error != nil)
        return nil;

    return [self md5OfData:data];
}

@end
