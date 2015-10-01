#import <Foundation/Foundation.h>

@class PHFetchResult;
@class TGMediaPickerAsset;

@interface TGAssetsFetchResult : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) id firstObject;
@property (nonatomic, readonly) id lastObject;

- (instancetype)initWithPHFetchResult:(PHFetchResult *)fetchResult;
- (instancetype)initWithAssets:(NSArray *)assets;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range;

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes;

- (BOOL)containsObject:(id)anObject;

- (void)enumerateWithBlock:(void (^)(TGMediaPickerAsset *))block;

@end
