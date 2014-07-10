#import "PSLMDBKeyValueWriter.h"

#import "PSLMDBTable.h"

@interface PSLMDBKeyValueWriter ()
{
    MDB_dbi _dbi;
    MDB_txn *_txn;
}

@end

@implementation PSLMDBKeyValueWriter

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

- (void)writeValueForRawKey:(const uint8_t *)key keyLength:(NSUInteger)keyLength value:(const uint8_t *)value valueLength:(NSUInteger)valueLength
{
    if (key == NULL || keyLength == 0)
        return;
    
    MDB_val mdbKey;
    MDB_val mdbData;
    
    mdbKey.mv_data = (uint8_t *)key;
    mdbKey.mv_size = keyLength;
    
    mdbData.mv_data = (uint8_t *)value;
    mdbData.mv_size = valueLength;
    
    if (value == NULL)
    {
        int rc = 0;
        rc = mdb_del(_txn, _dbi, &mdbKey, NULL);
    }
    else
    {
        int rc = 0;
        rc = mdb_put(_txn, _dbi, &mdbKey, &mdbData, 0);
        
        if (rc != MDB_SUCCESS)
            TGLog(@"[PSLMDBKeyValueWriter mdb_put error %d]", rc);
    }
}

@end
