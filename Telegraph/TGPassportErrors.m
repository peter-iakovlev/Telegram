#import "TGPassportErrors.h"

#import <LegacyComponents/TGStringUtils.h>

#import "TGPassportSignals.h"
#import "TLSecureValueError.h"

NSString *const TGPassportErrorTargetData = @"data";
NSString *const TGPassportErrorTargetFrontSide = @"frontSide";
NSString *const TGPassportErrorTargetReverseSide = @"reverseSide";
NSString *const TGPassportErrorTargetSelfie = @"selfie";
NSString *const TGPassportErrorTargetFiles = @"files";

@implementation NSArray (SPDeepCopy)

- (NSArray *) deepCopy {
    NSUInteger count = [self count];
    id cArray[count];
    
    for (unsigned int i = 0; i < count; ++i) {
        id obj = [self objectAtIndex:i];
        if ([obj respondsToSelector:@selector(deepCopy)])
            cArray[i] = [obj deepCopy];
        else
            cArray[i] = [obj copy];
    }
    
    NSArray *ret = [NSArray arrayWithObjects:cArray count:count];
    return ret;
}
- (NSMutableArray *) mutableDeepCopy {
    NSUInteger count = [self count];
    id cArray[count];
    
    for (unsigned int i = 0; i < count; ++i) {
        id obj = [self objectAtIndex:i];
        
        if ([obj respondsToSelector:@selector(mutableDeepCopy)])
            cArray[i] = [obj mutableDeepCopy];
        else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)])
            cArray[i] = [obj mutableCopy];
        else if ([obj respondsToSelector:@selector(deepCopy)])
            cArray[i] = [obj deepCopy];
        else
            cArray[i] = [obj copy];
    }
    
    NSMutableArray *ret = [NSMutableArray arrayWithObjects:cArray count:count];
    return ret;
}

@end

@implementation NSDictionary (SPDeepCopy)

- (NSDictionary *) deepCopy {
    NSUInteger count = [self count];
    id cObjects[count];
    id cKeys[count];
    
    NSEnumerator *e = [self keyEnumerator];
    unsigned int i = 0;
    id thisKey;
    while ((thisKey = [e nextObject]) != nil) {
        id obj = [self objectForKey:thisKey];
        
        if ([obj respondsToSelector:@selector(deepCopy)])
            cObjects[i] = [obj deepCopy];
        else
            cObjects[i] = [obj copy];
        
        if ([thisKey respondsToSelector:@selector(deepCopy)])
            cKeys[i] = [thisKey deepCopy];
        else
            cKeys[i] = [thisKey copy];
        
        ++i;
    }
    
    NSDictionary *ret = [NSDictionary dictionaryWithObjects:cObjects forKeys:cKeys count:count];
    return ret;
}
- (NSMutableDictionary *)mutableDeepCopy {
    NSUInteger count = [self count];
    id cObjects[count];
    id cKeys[count];
    
    NSEnumerator *e = [self keyEnumerator];
    unsigned int i = 0;
    id thisKey;
    while ((thisKey = [e nextObject]) != nil) {
        id obj = [self objectForKey:thisKey];
        
        if ([obj respondsToSelector:@selector(mutableDeepCopy)])
            cObjects[i] = [obj mutableDeepCopy];
        else if ([obj respondsToSelector:@selector(mutableCopyWithZone:)])
            cObjects[i] = [obj mutableCopy];
        else if ([obj respondsToSelector:@selector(deepCopy)])
            cObjects[i] = [obj deepCopy];
        else
            cObjects[i] = [obj copy];
        
        if ([thisKey respondsToSelector:@selector(deepCopy)])
            cKeys[i] = [thisKey deepCopy];
        else
            cKeys[i] = [thisKey copy];
        
        ++i;
    }
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithObjects:cObjects forKeys:cKeys count:count];
    return ret;
}

@end

@interface TGPassportErrors ()
{
    NSMutableDictionary *_dict;
}
@end

@implementation TGPassportErrors

- (instancetype)initWithArray:(NSArray *)array fileHashes:(NSSet *)fileHashes
{
    if (array.count == 0)
        return nil;
    
    self = [super init];
    if (self != nil)
    {
        _dict = [[NSMutableDictionary alloc] init];
        
        for (TLSecureValueError *error in array)
        {
            TGPassportType scope = [TGPassportSignals typeForSecureValueType:error.type];
            
            NSDictionary *scopeDict = _dict[@(scope)];
            if (scopeDict == nil)
            {
                NSMutableDictionary *dataErrors = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *frontSideErrors = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *reverseSideErrors = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *selfieErrors = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *fileErrors = [[NSMutableDictionary alloc] init];
                scopeDict = @{ TGPassportErrorTargetData: dataErrors, TGPassportErrorTargetFrontSide: frontSideErrors, TGPassportErrorTargetReverseSide: reverseSideErrors, TGPassportErrorTargetSelfie: selfieErrors, TGPassportErrorTargetFiles: fileErrors };
                _dict[@(scope)] = scopeDict;
            }
            
            if ([error isKindOfClass:[TLSecureValueError$secureValueErrorData class]])
            {
                NSMutableDictionary *dataErrors = scopeDict[TGPassportErrorTargetData];
                NSString *field = ((TLSecureValueError$secureValueErrorData *)error).field;
                if (field.length > 0)
                    dataErrors[field] = [[TGPassportError alloc] initWithError:error];
            }
            else if ([error isKindOfClass:[TLSecureValueError$secureValueErrorFrontSide class]])
            {
                NSMutableDictionary *frontSideErrors = scopeDict[TGPassportErrorTargetFrontSide];
                NSString *fileHash = [TGStringUtils stringByEncodingInBase64:((TLSecureValueError$secureValueErrorFrontSide *)error).file_hash];
                if ([fileHashes containsObject:fileHash])
                    frontSideErrors[@"common"] = [[TGPassportError alloc] initWithError:error];
            }
            else if ([error isKindOfClass:[TLSecureValueError$secureValueErrorReverseSide class]])
            {
                NSMutableDictionary *reverseSideErrors = scopeDict[TGPassportErrorTargetReverseSide];
                NSString *fileHash = [TGStringUtils stringByEncodingInBase64:((TLSecureValueError$secureValueErrorReverseSide *)error).file_hash];
                if ([fileHashes containsObject:fileHash])
                    reverseSideErrors[@"common"] = [[TGPassportError alloc] initWithError:error];
            }
            else if ([error isKindOfClass:[TLSecureValueError$secureValueErrorSelfie class]])
            {
                NSMutableDictionary *selfieErrors = scopeDict[TGPassportErrorTargetSelfie];
                NSString *fileHash = [TGStringUtils stringByEncodingInBase64:((TLSecureValueError$secureValueErrorSelfie *)error).file_hash];
                if ([fileHashes containsObject:fileHash])
                    selfieErrors[@"common"] = [[TGPassportError alloc] initWithError:error];
            }
            else if ([error isKindOfClass:[TLSecureValueError$secureValueErrorFile class]])
            {
                NSMutableDictionary *fileErrors = scopeDict[TGPassportErrorTargetFiles];
                NSString *fileHash = [TGStringUtils stringByEncodingInBase64:((TLSecureValueError$secureValueErrorFile *)error).file_hash];
                if (fileHash == nil)
                    fileErrors[@"common"] = [[TGPassportError alloc] initWithError:error];
                else if ([fileHashes containsObject:fileHash])
                    fileErrors[fileHash] = [[TGPassportError alloc] initWithError:error];
            }
            else if ([error isKindOfClass:[TLSecureValueError$secureValueErrorFiles class]])
            {
                NSMutableDictionary *fileErrors = scopeDict[TGPassportErrorTargetFiles];
                fileErrors[@"common"] = [[TGPassportError alloc] initWithError:error];
            }
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGPassportErrors *errors = [[TGPassportErrors alloc] init];
    errors->_dict = [_dict mutableDeepCopy];
    return errors;
}

- (NSArray *)errorsForType:(TGPassportType)type
{
    NSArray *dataErrors = [_dict[@(type)][TGPassportErrorTargetData] allValues];
    NSArray *frontSideErrors = [_dict[@(type)][TGPassportErrorTargetFrontSide] allValues];
    NSArray *reverseSideErrors = [_dict[@(type)][TGPassportErrorTargetReverseSide] allValues];
    NSArray *selfieErrors = [_dict[@(type)][TGPassportErrorTargetSelfie] allValues];
    NSArray *fileErrors = [_dict[@(type)][TGPassportErrorTargetFiles] allValues];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObjectsFromArray:dataErrors];
    [result addObjectsFromArray:frontSideErrors];
    [result addObjectsFromArray:reverseSideErrors];
    [result addObjectsFromArray:selfieErrors];
    [result addObjectsFromArray:fileErrors];
    return result;
}

- (NSArray *)fieldErrorsForType:(TGPassportType)type
{
    return [_dict[@(type)][TGPassportErrorTargetData] allValues];
}

- (TGPassportError *)errorForType:(TGPassportType)type dataField:(NSString *)field
{
    return _dict[@(type)][TGPassportErrorTargetData][field];
}

- (TGPassportError *)errorForTypeFiles:(TGPassportType)type
{
    return _dict[@(type)][TGPassportErrorTargetFiles][@"common"];
}

- (TGPassportError *)errorForTypeFrontSide:(TGPassportType)type
{
    return _dict[@(type)][TGPassportErrorTargetFrontSide][@"common"];
}

- (TGPassportError *)errorForTypeReverseSide:(TGPassportType)type
{
    return _dict[@(type)][TGPassportErrorTargetReverseSide][@"common"];
}

- (TGPassportError *)errorForTypeSelfie:(TGPassportType)type
{
    return _dict[@(type)][TGPassportErrorTargetSelfie][@"common"];
}

- (NSString *)errorForType:(TGPassportType)type fileHash:(NSString *)fileHash
{
    return _dict[@(type)][TGPassportErrorTargetFiles][fileHash];
}

- (void)correctErrorForType:(TGPassportType)type dataField:(NSString *)field
{
    [_dict[@(type)][TGPassportErrorTargetData] removeObjectForKey:field];
}

- (void)correctFrontSideErrorForType:(TGPassportType)type
{
    [_dict[@(type)][TGPassportErrorTargetFrontSide] removeObjectForKey:@"common"];
}

- (void)correctReverseSideErrorForType:(TGPassportType)type
{
    [_dict[@(type)][TGPassportErrorTargetReverseSide] removeObjectForKey:@"common"];
}

- (void)correctSelfieErrorForType:(TGPassportType)type
{
    [_dict[@(type)][TGPassportErrorTargetSelfie] removeObjectForKey:@"common"];
}


- (void)correctFilesErrorForType:(TGPassportType)type
{
    [_dict[@(type)][TGPassportErrorTargetFiles] removeObjectForKey:@"common"];
}

- (void)correctFileErrorForType:(TGPassportType)type fileHash:(NSString *)fileHash
{
    [_dict[@(type)][TGPassportErrorTargetFiles] removeObjectForKey:fileHash];
}

@end


@implementation TGPassportError

- (instancetype)initWithError:(TLSecureValueError *)error
{
    self = [super init];
    if (self != nil)
    {
        if ([error isKindOfClass:[TLSecureValueError$secureValueErrorData class]])
            _key = ((TLSecureValueError$secureValueErrorData *)error).field;
        _text = error.text;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGPassportError *error = [[TGPassportError alloc] init];
    error->_key = _key;
    error->_text = _text;
    return error;
}

@end
