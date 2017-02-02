#import "TGCallUtils.h"
#import "Reachability.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TGObserverProxy.h"

# define AES_MAXNR 14
# define AES_BLOCK_SIZE 16

#define N_WORDS (AES_BLOCK_SIZE / sizeof(unsigned long))
typedef struct {
    unsigned long data[N_WORDS];
} aes_block_t;

/* XXX: probably some better way to do this */
#if defined(__i386__) || defined(__x86_64__)
# define UNALIGNED_MEMOPS_ARE_FAST 1
#else
# define UNALIGNED_MEMOPS_ARE_FAST 0
#endif

#if UNALIGNED_MEMOPS_ARE_FAST
# define load_block(d, s)        (d) = *(const aes_block_t *)(s)
# define store_block(d, s)       *(aes_block_t *)(d) = (s)
#else
# define load_block(d, s)        memcpy((d).data, (s), AES_BLOCK_SIZE)
# define store_block(d, s)       memcpy((d), (s).data, AES_BLOCK_SIZE)
#endif

void TGCallAesIgeEncrypt(uint8_t *inBytes, uint8_t *outBytes, size_t length, uint8_t *key, uint8_t *iv) {
    size_t len;
    size_t n;
    uint8_t const *inB;
    uint8_t *outB;
    
    unsigned char aesIv[AES_BLOCK_SIZE];
    memcpy(aesIv, iv, AES_BLOCK_SIZE);
    unsigned char ccIv[AES_BLOCK_SIZE];
    memcpy(ccIv, (void *)((uint8_t *)iv + AES_BLOCK_SIZE), AES_BLOCK_SIZE);
    
    assert(((size_t)inBytes | (size_t)outBytes | (size_t)aesIv | (size_t)ccIv) % sizeof(long) ==
           0);
    
    void *tmpInBytes = malloc(length);
    len = length / AES_BLOCK_SIZE;
    inB = (uint8_t *)inBytes;
    outB = (uint8_t *)tmpInBytes;
    
    aes_block_t *inp = (aes_block_t *)inB;
    aes_block_t *outp = (aes_block_t *)outB;
    for (n = 0; n < N_WORDS; ++n) {
        outp->data[n] = inp->data[n];
    }
    
    --len;
    inB += AES_BLOCK_SIZE;
    outB += AES_BLOCK_SIZE;
    uint8_t const *inBCC = (uint8_t *)inBytes;
    
    aes_block_t const *iv3p = (aes_block_t *)ccIv;
    
    if (len > 0) {
        while (len) {
            aes_block_t *inp = (aes_block_t *)inB;
            aes_block_t *outp = (aes_block_t *)outB;
            
            for (n = 0; n < N_WORDS; ++n) {
                outp->data[n] = inp->data[n] ^ iv3p->data[n];
            }
            
            iv3p = (const aes_block_t *)inBCC;
            --len;
            inBCC += AES_BLOCK_SIZE;
            inB += AES_BLOCK_SIZE;
            outB += AES_BLOCK_SIZE;
        }
    }
    
    size_t realOutLength = 0;
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0, key, 32, aesIv, tmpInBytes, length, outBytes, length, &realOutLength);
    free(tmpInBytes);
    
    assert(result == kCCSuccess);
    
    len = length / AES_BLOCK_SIZE;
    
    aes_block_t const *ivp = (aes_block_t *)inB;
    aes_block_t *iv2p = (aes_block_t *)ccIv;
    
    inB = (uint8_t *)inBytes;
    outB = (uint8_t *)outBytes;
    
    while (len) {
        aes_block_t *inp = (aes_block_t *)inB;
        aes_block_t *outp = (aes_block_t *)outB;
        
        for (n = 0; n < N_WORDS; ++n) {
            outp->data[n] ^= iv2p->data[n];
        }
        ivp = outp;
        iv2p = inp;
        --len;
        inB += AES_BLOCK_SIZE;
        outB += AES_BLOCK_SIZE;
    }
    
    memcpy(iv, ivp->data, AES_BLOCK_SIZE);
    memcpy((void *)((uint8_t *)iv + AES_BLOCK_SIZE), iv2p->data, AES_BLOCK_SIZE);
}

void TGCallAesIgeEncryptInplace(uint8_t *inBytes, uint8_t *outBytes, size_t length, uint8_t *key, uint8_t *iv)
{
    uint8_t *outData = (uint8_t *)malloc(length);
    TGCallAesIgeEncrypt(inBytes, outData, length, key, iv);
    memcpy(outBytes, outData, length);
    free(outData);
}

void TGCallAesIgeDecrypt(uint8_t *inBytes, uint8_t *outBytes, size_t length, uint8_t *key, uint8_t *iv) {
    unsigned char aesIv[AES_BLOCK_SIZE];
    memcpy(aesIv, iv, AES_BLOCK_SIZE);
    unsigned char ccIv[AES_BLOCK_SIZE];
    memcpy(ccIv, (void *)((uint8_t *)iv + AES_BLOCK_SIZE), AES_BLOCK_SIZE);
    
    assert(((size_t)inBytes | (size_t)outBytes | (size_t)aesIv | (size_t)ccIv) % sizeof(long) ==
           0);
    
    CCCryptorRef decryptor = NULL;
    CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionECBMode, key, 32, nil, &decryptor);
    if (decryptor != NULL) {
        size_t len;
        size_t n;
        
        len = length / AES_BLOCK_SIZE;
        
        aes_block_t *ivp = (aes_block_t *)(aesIv);
        aes_block_t *iv2p = (aes_block_t *)(ccIv);
        
        uint8_t *inB = (uint8_t *)inBytes;
        uint8_t *outB = (uint8_t *)outBytes;
        
        while (len) {
            aes_block_t tmp;
            aes_block_t *inp = (aes_block_t *)inB;
            aes_block_t *outp = (aes_block_t *)outB;
            
            for (n = 0; n < N_WORDS; ++n)
                tmp.data[n] = inp->data[n] ^ iv2p->data[n];
            
            size_t dataOutMoved = 0;
            CCCryptorStatus result = CCCryptorUpdate(decryptor, &tmp, AES_BLOCK_SIZE, outB, AES_BLOCK_SIZE, &dataOutMoved);
            assert(result == kCCSuccess);
            assert(dataOutMoved == AES_BLOCK_SIZE);
            
            for (n = 0; n < N_WORDS; ++n)
                outp->data[n] ^= ivp->data[n];
            
            ivp = inp;
            iv2p = outp;
            
            inB += AES_BLOCK_SIZE;
            outB += AES_BLOCK_SIZE;
            
            --len;
        }
        
        memcpy(iv, ivp->data, AES_BLOCK_SIZE);
        memcpy((void *)((uint8_t *)iv + AES_BLOCK_SIZE), iv2p->data, AES_BLOCK_SIZE);
        
        CCCryptorRelease(decryptor);
    }
}

void TGCallAesIgeDecryptInplace(uint8_t *inBytes, uint8_t *outBytes, size_t length, uint8_t *key, uint8_t *iv) {
    uint8_t *outData = (uint8_t *)malloc(length);
    TGCallAesIgeDecrypt(inBytes, outData, length, key, iv);
    memcpy(outBytes, outData, length);
    free(outData);
}

void TGCallSha1(uint8_t *msg, size_t length, uint8_t *output)
{
    CC_SHA1(msg, (CC_LONG)length, output);
}

void TGCallSha256(uint8_t *msg, size_t length, uint8_t *output)
{
    CC_SHA256(msg, (CC_LONG)length, output);
}

void TGCallRandomBytes(uint8_t *buffer, size_t length)
{
    arc4random_buf(buffer, length);
}

void TGCallLoggingFunction(const char *msg)
{
    TGLog(@"%s", msg);
}

@interface TGObserverBlockProxy : TGObserverProxy

@property (nonatomic, copy) void (^block)(void);

- (instancetype)initWithName:(NSString *)name block:(void (^)(void))block;

@end

@implementation TGCallUtils

+ (SSignal *)networkTypeSignal
{
    SSignal *reachabilitySignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        [subscriber putNext:@(reachability.currentReachabilityStatus)];
        reachability.reachabilityChanged = ^(NetworkStatus status)
        {
            [subscriber putNext:@(status)];
        };
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [reachability stopNotifier];
        }];
    }];
    
    
    SSignal *cellNetworkSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
        NSString *network = telephonyInfo.currentRadioAccessTechnology;
        if (network == nil)
            network = @"";
        [subscriber putNext:network];

        TGObserverBlockProxy *observer = [[TGObserverBlockProxy alloc] initWithName:CTRadioAccessTechnologyDidChangeNotification block:^
        {
            NSString *network = telephonyInfo.currentRadioAccessTechnology;
            if (network == nil)
                network = @"";
            [subscriber putNext:network];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            [telephonyInfo description];
            [observer description];
        }];
    }];
    
    return [[SSignal combineSignals:@[reachabilitySignal, cellNetworkSignal]] map:^NSNumber *(NSArray *values)
    {
        NSInteger reachability = [values.firstObject integerValue];
        NSString *networkType = values.lastObject;
        
        if (reachability == ReachableViaWWAN)
        {
            if ([networkType isEqualToString:CTRadioAccessTechnologyGPRS])
            {
                return @(TGCallNetworkTypeGPRS);
            }
            else if ([networkType isEqualToString:CTRadioAccessTechnologyEdge] || [networkType isEqualToString:CTRadioAccessTechnologyCDMA1x])
            {
                return @(TGCallNetworkTypeEdge);
            }
            else if ([networkType isEqualToString:CTRadioAccessTechnologyLTE])
            {
                return @(TGCallNetworkTypeLTE);
            }
            else if ([networkType isEqualToString:CTRadioAccessTechnologyWCDMA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyHSDPA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyHSUPA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                     || [networkType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                     || [networkType isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                     || [networkType isEqualToString:CTRadioAccessTechnologyeHRPD])
            {
                return @(TGCallNetworkType3G);
            }
        }
        else if (reachability == ReachableViaWiFi)
        {
            return @(TGCallNetworkTypeWiFi);
        }
        else if (reachability == NotReachable)
        {
            return @(TGCallNetworkTypeNone);
        }
        
        return @(TGCallNetworkTypeUnknown);
    }];
}

@end


@implementation TGObserverBlockProxy

- (instancetype)initWithName:(NSString *)name block:(void (^)(void))block
{
    self = [self initWithTarget:self targetSelector:@selector(handleNotification) name:name];
    if (self != nil)
    {
        self.block = block;
    }
    return self;
}

- (void)handleNotification
{
    if (self.block != nil)
        self.block();
}

@end
