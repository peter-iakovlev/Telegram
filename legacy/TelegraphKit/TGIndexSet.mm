#import "TGIndexSet.h"

#import <vector>

@interface TGIndexSet : NSObject

- (int)insertIndex:(int32_t)index;

@end

@interface TGIndexSet ()
{
    std::vector<int32_t> _indices;
}

@end

@implementation TGIndexSet

- (int)insertIndex:(int32_t)index
{
    if (index < 0)
        return -1;
    
    for (auto it = _indices.begin(); it != _indices.end(); it++)
    {
        if (*it >= index)
            (*it)++;
    }
    
    auto insertLocation = _indices.end();
    for (auto it = _indices.begin(); it != _indices.end(); it++)
    {
        if (*it >= index)
        {
            insertLocation = it;
            break;
        }
    }
    
    auto indexLocation = insertLocation - _indices.begin();
    _indices.insert(insertLocation, index);
    
    return (int)indexLocation;
}

- (NSIndexSet *)indexSet
{
    NSMutableIndexSet *result = [[NSMutableIndexSet alloc] init];
    
    for (auto it = _indices.begin(); it != _indices.end(); it++)
    {
        [result addIndex:*it];
    }
    
    return result;
}

@end

@interface TGMutableArrayWithIndices ()
{
    TGIndexSet *_insertIndexSet;
    NSMutableArray *_insertArray;
    
    NSMutableArray *_array;
}

@end

@implementation TGMutableArrayWithIndices

- (instancetype)initWithArray:(NSMutableArray *)array
{
    self = [super init];
    if (self != nil)
    {
        _array = array;
        
        _insertIndexSet = [[TGIndexSet alloc] init];
        _insertArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
    [_array insertObject:object atIndex:index];
    int insertIndex = [_insertIndexSet insertIndex:(int)index];
    if (insertIndex >= 0)
        [_insertArray insertObject:object atIndex:insertIndex];
}

- (NSArray *)objectsForInsertOperations:(__autoreleasing NSIndexSet **)indexSet
{
    NSIndexSet *resultIndexSet = [_insertIndexSet indexSet];
    if (indexSet != NULL)
        *indexSet = resultIndexSet;
    
    return _insertArray;
}

@end
