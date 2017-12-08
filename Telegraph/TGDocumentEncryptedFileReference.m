#import "TGDocumentEncryptedFileReference.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGDocumentEncryptedFileReference

- (instancetype)initWithDatacenterId:(int32_t)datacenterId fileId:(int64_t)fileId accessHash:(int64_t)accessHash encryptedSize:(int32_t)encryptedSize decryptedSize:(int32_t)decryptedSize keyFingerprint:(int32_t)keyFingerprint key:(NSData *)key iv:(NSData *)iv {
    self = [super init];
    if (self != nil) {
        _datacenterId = datacenterId;
        _fileId = fileId;
        _accessHash = accessHash;
        _encryptedSize = encryptedSize;
        _decryptedSize = decryptedSize;
        _keyFingerprint = keyFingerprint;
        _key = key;
        _iv = iv;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDatacenterId:[aDecoder decodeInt32ForKey:@"datacenterId"] fileId:[aDecoder decodeInt64ForKey:@"fileId"] accessHash:[aDecoder decodeInt64ForKey:@"accessHash"] encryptedSize:[aDecoder decodeInt32ForKey:@"encryptedSize"] decryptedSize:[aDecoder decodeInt32ForKey:@"decryptedSize"] keyFingerprint:[aDecoder decodeInt32ForKey:@"keyFingerprint"] key:[aDecoder decodeObjectForKey:@"key"] iv:[aDecoder decodeObjectForKey:@"iv"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_datacenterId forKey:@"datacenterId"];
    [aCoder encodeInt64:_fileId forKey:@"fileId"];
    [aCoder encodeInt64:_accessHash forKey:@"accessHash"];
    [aCoder encodeInt32:_encryptedSize forKey:@"encryptedSize"];
    [aCoder encodeInt32:_decryptedSize forKey:@"decryptedSize"];
    [aCoder encodeInt32:_keyFingerprint forKey:@"keyFingerprint"];
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_iv forKey:@"iv"];
}

- (instancetype)initWithKeyValueCoder:(PSKeyValueCoder *)coder {
    return [self initWithDatacenterId:[coder decodeInt32ForCKey:"datacenterId"] fileId:[coder decodeInt64ForCKey:"fileId"] accessHash:[coder decodeInt64ForCKey:"accessHash"] encryptedSize:[coder decodeInt32ForCKey:"encryptedSize"] decryptedSize:[coder decodeInt32ForCKey:"decryptedSize"] keyFingerprint:[coder decodeInt32ForCKey:"keyFingerprint"] key:[coder decodeDataCorCKey:"key"] iv:[coder decodeDataCorCKey:"iv"]];
}

- (void)encodeWithKeyValueCoder:(PSKeyValueCoder *)coder {
    [coder encodeInt32:_datacenterId forCKey:"datacenterId"];
    [coder encodeInt64:_fileId forCKey:"fileId"];
    [coder encodeInt64:_accessHash forCKey:"accessHash"];
    [coder encodeInt32:_encryptedSize forCKey:"encryptedSize"];
    [coder encodeInt32:_decryptedSize forCKey:"decryptedSize"];
    [coder encodeInt32:_keyFingerprint forCKey:"keyFingerprint"];
    [coder encodeData:_key forCKey:"key"];
    [coder encodeData:_iv forCKey:"iv"];
}

@end
