#import "PSLMDBKeyValueReader.h"

#import "PSLMDBTable.h"

@interface PSLMDBKeyValueReader ()
{
    MDB_dbi _dbi;
    MDB_txn *_txn;
}

@end

@implementation PSLMDBKeyValueReader

- (instancetype)initWithTable:(PSLMDBTable *)table transaction:(MDB_txn *)transaction
{
    self = [super init];
    if (self != nil)
    {
        _dbi = table.dbi;
        _txn = transaction;
    }
    return self;
}

- (bool)readValueForRawKey:(const uint8_t *)key keyLength:(NSUInteger)keyLength value:(out uint8_t **)value valueLength:(out NSUInteger *)valueLength
{
    MDB_val mdbKey;
    MDB_val mdbData;
    
    mdbKey.mv_data = (uint8_t *)key;
    mdbKey.mv_size = (size_t)keyLength;
    
    int rc = 0;
    rc = mdb_get(_txn, _dbi, &mdbKey, &mdbData);
    
    if (rc == MDB_SUCCESS)
    {
        if (value != NULL)
            *value = mdbData.mv_data;
        
        if (valueLength != NULL)
            *valueLength = mdbData.mv_size;
        
        return true;
    }
    else
    {
        if (rc != MDB_NOTFOUND)
            TGLog(@"[PSLMDBKeyValueReader mdb_get error %d]", rc);
        
        return false;
    }
}

@end
