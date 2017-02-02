#import <CommonCrypto/CommonCrypto.h>
#import <SSignalKit/SSignalKit.h>

void TGCallAesIgeEncryptInplace(uint8_t *inBytes, uint8_t *outBytes, size_t length, uint8_t *key, uint8_t *iv);
void TGCallAesIgeDecryptInplace(uint8_t *inBytes, uint8_t *outBytes, size_t length, uint8_t *key, uint8_t *iv);

void TGCallSha1(uint8_t *msg, size_t length, uint8_t *output);
void TGCallSha256(uint8_t *msg, size_t length, uint8_t *output);

void TGCallRandomBytes(uint8_t *buffer, size_t length);

void TGCallLoggingFunction(const char *msg);

UIImage *TGCallIdenticonImage(NSData *data, NSData *additionalData, CGSize size);

typedef enum {
    TGCallNetworkTypeUnknown,
    TGCallNetworkTypeNone,
    TGCallNetworkTypeGPRS,
    TGCallNetworkTypeEdge,
    TGCallNetworkType3G,
    TGCallNetworkTypeLTE,
    TGCallNetworkTypeWiFi,
} TGCallNetworkType;

@interface TGCallUtils : NSObject

+ (SSignal *)networkTypeSignal;

@end
