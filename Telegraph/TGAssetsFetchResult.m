#import "TGAssetsFetchResult.h"

#import <Photos/Photos.h>

@interface TGAssetsFetchResult ()
{
    PHFetchResult *_fetchResult;
    NSArray *_assets;
}
@end

@implementation TGAssetsFetchResult

- (instancetype)initWithPHFetchResult:(PHFetchResult *)fetchResult
{
    self = [super init];
    if (self != nil)
    {
        _fetchResult = fetchResult;
    }
    return self;
}

- (instancetype)initWithAssets:(NSArray *)assets
{
    self = [super init];
    if (self != nil)
    {
        _assets = assets;
    }
    return self;
}

- (NSUInteger)count
{
    if (_fetchResult != nil)
        return _fetchResult.count;
    else if (_assets != nil)
        return _assets.count;
    
    return 0;
}

- (id)firstObject
{
    if (_fetchResult != nil)
        return _fetchResult.firstObject;
    else if (_assets != nil)
        return _assets.firstObject;
    
    return nil;
}

- (id)lastObject
{
    if (_fetchResult != nil)
        return _fetchResult.lastObject;
    else if (_assets != nil)
        return _assets.lastObject;
    
    return nil;
}

- (id)objectAtIndex:(NSUInteger)index
{
    if (_fetchResult != nil)
        return [_fetchResult objectAtIndex:index];
    else if (_assets != nil)
        return [_assets objectAtIndex:index];
    
    return nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self objectAtIndex:idx];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    if (_fetchResult != nil)
        return [_fetchResult indexOfObject:anObject];
    else if (_assets != nil)
        return [_assets indexOfObject:anObject];
    
    return NSNotFound;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{
    if (_fetchResult != nil)
        return [_fetchResult indexOfObject:anObject inRange:range];
    else if (_assets != nil)
        return [_assets indexOfObject:anObject inRange:range];
    
    return NSNotFound;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    if (_fetchResult != nil)
        return [_fetchResult objectsAtIndexes:indexes];
    else if (_assets != nil)
        return [_assets objectsAtIndexes:indexes];
    
    return nil;
}

- (BOOL)containsObject:(id)anObject
{
    if (_fetchResult != nil)
        return [_fetchResult containsObject:anObject];
    else if (_assets != nil)
        return [_assets containsObject:anObject];
    
    return NO;
}

- (void)enumerateWithBlock:(void (^)(TGMediaPickerAsset *))block
{
    if (block == nil)
        return;
    
    if (_fetchResult != nil)
    {
        
    }
    else if (_assets != nil)
    {
        for (TGMediaPickerAsset *asset in _assets)
            block(asset);
    }
}

@end
