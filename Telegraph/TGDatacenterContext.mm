#import "TGDatacenterContext.h"

#include <vector>
#include <set>

struct TGServerSalt
{
    int validSince;
    int validUntil;
    int64_t value;
};

@implementation TGDatacenterContext
{
    std::vector<TGServerSalt> _authServerSaltSet;
}

- (id)initWithSerializedData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        int ptr = 0;
        
        int datacenterId = 0;
        [data getBytes:&datacenterId range:NSMakeRange(ptr, 4)];
        ptr += 4;
        _datacenterId = datacenterId;
        
        int16_t addressSetCount = 0;
        [data getBytes:&addressSetCount range:NSMakeRange(ptr, 2)];
        ptr += 2;
        
        NSMutableArray *addressSet = [[NSMutableArray alloc] initWithCapacity:addressSetCount];
        for (int16_t i = 0; i < addressSetCount; i++)
        {
            int16_t hostnameLength = 0;
            [data getBytes:&hostnameLength range:NSMakeRange(ptr, 2)];
            ptr += 2;
            
            uint8_t *hostnameBytes = (uint8_t *)malloc(hostnameLength);
            [data getBytes:hostnameBytes range:NSMakeRange(ptr, hostnameLength)];
            ptr += hostnameLength;
            NSString *hostname = [[NSString alloc] initWithBytesNoCopy:hostnameBytes length:hostnameLength encoding:NSUTF8StringEncoding freeWhenDone:true];
            
            int16_t addressLength = 0;
            [data getBytes:&addressLength range:NSMakeRange(ptr, 2)];
            ptr += 2;
            
            uint8_t *addressBytes = (uint8_t *)malloc(addressLength);
            [data getBytes:addressBytes range:NSMakeRange(ptr, addressLength)];
            ptr += addressLength;
            NSString *address = [[NSString alloc] initWithBytesNoCopy:addressBytes length:addressLength encoding:NSUTF8StringEncoding freeWhenDone:true];
            
            int port = 0;
            [data getBytes:&port range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            [addressSet addObject:[[NSDictionary alloc] initWithObjectsAndKeys:address, @"address", [[NSNumber alloc] initWithInt:port], @"port", hostname, @"hostname", nil]];
        }
        _addressSet = addressSet;
        
        int32_t authKeyLength = 0;
        [data getBytes:&authKeyLength range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        if (authKeyLength == 0)
            _authKey = nil;
        else
        {
            uint8_t *authKeyBytes = (uint8_t *)malloc(authKeyLength);
            [data getBytes:authKeyBytes range:NSMakeRange(ptr, authKeyLength)];
            ptr += authKeyLength;
            _authKey =  [[NSData alloc] initWithBytesNoCopy:authKeyBytes length:authKeyLength freeWhenDone:true];
        }
        
        int32_t authKeyIdLength = 0;
        [data getBytes:&authKeyIdLength range:NSMakeRange(ptr, 4)];
        ptr += 4;
        
        if (authKeyIdLength == 0)
            _authKeyId = nil;
        else
        {
            uint8_t *authKeyIdBytes = (uint8_t *)malloc(authKeyIdLength);
            [data getBytes:authKeyIdBytes range:NSMakeRange(ptr, authKeyIdLength)];
            ptr += authKeyIdLength;
            _authKeyId = [[NSData alloc] initWithBytesNoCopy:authKeyIdBytes length:authKeyIdLength freeWhenDone:true];
        }
        
        int authorized = 0;
        [data getBytes:&authorized range:NSMakeRange(ptr, 4)];
        ptr += 4;
        _authorized = authorized != 0;
        
        int saltCount = 0;
        [data getBytes:&saltCount range:NSMakeRange(ptr, 4)];
        ptr += 4;
        for (int i = 0; i < saltCount; i++)
        {
            int validSince = 0;
            [data getBytes:&validSince range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int validUntil = 0;
            [data getBytes:&validUntil range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            int64_t salt = 0;
            [data getBytes:&salt range:NSMakeRange(ptr, 8)];
            ptr += 8;
            
            TGServerSalt serverSalt;
            serverSalt.validSince = validSince;
            serverSalt.validUntil = validUntil;
            serverSalt.value = salt;
            _authServerSaltSet.push_back(serverSalt);
        }
        
        if (ptr < (int)data.length)
        {
            int32_t initializedConnectionHash = 0;
            [data getBytes:&initializedConnectionHash range:NSMakeRange(ptr, 4)];
            ptr += 4;
            
            _initializedConnectionHash = initializedConnectionHash;
        }
    }
    return self;
}

- (NSData *)serialize
{
    NSMutableData *data = [[NSMutableData alloc] init];
    int32_t datacenterId = _datacenterId;
    [data appendBytes:&datacenterId length:4];
    
    int16_t addressSetCount = (int16_t)_addressSet.count;
    [data appendBytes:&addressSetCount length:2];
    
    for (int16_t i = 0; i < addressSetCount; i++)
    {
        NSDictionary *addressRecord = [_addressSet objectAtIndex:i];
        NSString *hostname = [addressRecord objectForKey:@"hostname"];
        NSString *address = [addressRecord objectForKey:@"address"];
        int port = [[addressRecord objectForKey:@"port"] intValue];
        
        NSData *hostnameBytes = [hostname dataUsingEncoding:NSUTF8StringEncoding];
        int16_t hostnameLength = (int16_t)hostnameBytes.length;
        [data appendBytes:&hostnameLength length:2];
        [data appendData:hostnameBytes];
        
        NSData *addressBytes = [address dataUsingEncoding:NSUTF8StringEncoding];
        int16_t addressLength = (int16_t)addressBytes.length;
        [data appendBytes:&addressLength length:2];
        [data appendData:addressBytes];
        
        [data appendBytes:&port length:4];
    }
    
    int authKeyLength = (int)_authKey.length;
    [data appendBytes:&authKeyLength length:4];
    [data appendData:_authKey];
    
    int authKeyIdLength = (int)_authKeyId.length;
    [data appendBytes:&authKeyIdLength length:4];
    [data appendData:_authKeyId];
    
    int authorized = _authorized ? 1 : 0;
    [data appendBytes:&authorized length:4];
    
    int saltCount = (int)_authServerSaltSet.size();
    [data appendBytes:&saltCount length:4];
    for (std::vector<TGServerSalt>::iterator it = _authServerSaltSet.begin(); it != _authServerSaltSet.end(); it++)
    {
        int validSince = it->validSince;
        int validUntil = it->validUntil;
        int64_t value = it->value;
        
        [data appendBytes:&validSince length:4];
        [data appendBytes:&validUntil length:4];
        [data appendBytes:&value length:8];
    }
    
    [data appendBytes:&_initializedConnectionHash length:4];
    
    return data;
}

- (void)clear
{
    _authKey = nil;
    _authKeyId = nil;
    _authorized = false;
    
    _authServerSaltSet.clear();
}

- (void)clearServerSalts
{
    _authServerSaltSet.clear();    
}

- (int64_t)selectServerSalt:(int)date
{
    bool cleanupNeeded = false;
    
    int64_t result = 0;
    int maxRemainingInterval = 0;
    
    for (std::vector<TGServerSalt>::iterator it = _authServerSaltSet.begin(); it != _authServerSaltSet.end(); it++)
    {
        if (it->validUntil < date || (it->validSince == 0 && it->validUntil == INT_MAX))
            cleanupNeeded = true;
        else if (it->validSince <= date && it->validUntil > date)
        {
            if (maxRemainingInterval == 0 || ABS(it->validUntil - date) > maxRemainingInterval)
            {
                maxRemainingInterval = ABS(it->validUntil - date);
                result = it->value;
            }
        }
    }
    
    if (cleanupNeeded)
    {
        for (int i = 0; i < (int)_authServerSaltSet.size(); i++)
        {
            if (_authServerSaltSet[i].validUntil < date)
            {
                _authServerSaltSet.erase(_authServerSaltSet.begin() + i);
                i--;
            }
        }
    }
    
    if (result == 0)
    {
        TGLog(@"***** Valid salt not found");
    }
    
    return result;
}

bool TGServerSaltDataLessThan(TGServerSalt const &x, TGServerSalt const &y)
{
    return x.validSince < y.validSince;
}

- (void)mergeServerSalts:(int)date salts:(NSArray *)salts
{
    std::set<int64_t> existingSalts;
    for (std::vector<TGServerSalt>::iterator it = _authServerSaltSet.begin(); it != _authServerSaltSet.end(); it++)
    {
        existingSalts.insert(it->value);
    }
    
    for (TLFutureSalt *saltDesc in salts)
    {
        int64_t salt = saltDesc.salt;
        if (existingSalts.find(salt) == existingSalts.end() && saltDesc.valid_until > date)
        {
            TGServerSalt serverSalt;
            serverSalt.validSince = saltDesc.valid_since;
            serverSalt.validUntil = saltDesc.valid_until;
            serverSalt.value = salt;
            
            _authServerSaltSet.push_back(serverSalt);
        }
    }
    
    std::sort(_authServerSaltSet.begin(), _authServerSaltSet.end(), TGServerSaltDataLessThan);
}

- (void)addServerSalt:(TGServerSalt)serverSalt
{
    for (std::vector<TGServerSalt>::iterator it = _authServerSaltSet.begin(); it != _authServerSaltSet.end(); it++)
    {
        if (it->value == serverSalt.value)
            return;
    }
    
    _authServerSaltSet.push_back(serverSalt);
    std::sort(_authServerSaltSet.begin(), _authServerSaltSet.end(), TGServerSaltDataLessThan);
}

- (bool)containsServerSalt:(int64_t)salt
{
    for (std::vector<TGServerSalt>::iterator it = _authServerSaltSet.begin(); it != _authServerSaltSet.end(); it++)
    {
        if (it->value == salt)
            return true;
    }
    
    return false;
}

@end
