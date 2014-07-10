#import "PSLMDBKeyValueStore.h"

#import "lmdb.h"

#import <pthread.h>

#import "PSLMDBTable.h"
#import "PSLMDBKeyValueReader.h"
#import "PSLMDBKeyValueWriter.h"

@interface PSLMDBKeyValueStore ()
{
    NSString *_path;
    MDB_env *_env;
    
    NSMutableDictionary *_tables;
    pthread_rwlock_t _tablesLock;
}

@end

@implementation PSLMDBKeyValueStore

+ (instancetype)storeWithPath:(NSString *)path
{
    if (path.length == 0)
        return nil;
    
    PSLMDBKeyValueStore *result = [[PSLMDBKeyValueStore alloc] init];
    if (result != nil)
    {
        result->_path = path;
        result->_tables = [[NSMutableDictionary alloc] init];
        pthread_rwlock_init(&result->_tablesLock, NULL);
        
        if (![result _open])
        {
            [result close];
            
            return nil;
        }
    }
    
    return result;
}

- (bool)_open
{
    int rc = 0;
    
    rc = mdb_env_create(&_env);
    if (rc != MDB_SUCCESS)
        return false;
    
    bool createDirectory = false;
    
    BOOL isDirectory = false;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_path isDirectory:&isDirectory])
    {
        if (!isDirectory)
        {
            [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
            createDirectory = true;
        }
    }
    else
        createDirectory = true;
    
    if (createDirectory)
        [[NSFileManager defaultManager] createDirectoryAtPath:_path withIntermediateDirectories:true attributes:nil error:nil];
    
    mdb_env_set_mapsize(_env, 256 * 1024 * 1024);
    mdb_env_set_maxdbs(_env, 64);
    
    rc = mdb_env_open(_env, [_path UTF8String], MDB_NOSYNC, 0664);
    if (rc != MDB_SUCCESS)
        return false;
    
    int removedReaders = 0;
    rc = mdb_reader_check(_env, &removedReaders);
    
    if (removedReaders != 0)
        TGLog(@"[PSLMDBKeyValueStore removed %d stale readers]", removedReaders);
    
    return true;
}

- (void)close
{
    pthread_rwlock_wrlock(&_tablesLock);
    for (PSLMDBTable *table in _tables)
    {
        mdb_close(_env, table.dbi);
    }
    [_tables removeAllObjects];
    pthread_rwlock_unlock(&_tablesLock);
    
    mdb_env_close(_env);
    
    _env = NULL;
}

- (void)sync
{
    int rc = 0;
    rc = mdb_env_sync(_env, 1);
    
    if (rc != MDB_SUCCESS)
    {
        TGLog(@"[PSLMDBKeyValueStore sync: mdb_env_sync error %d]", rc);
    }
}

- (void)panic
{
    
}

- (PSLMDBTable *)_tableWithName:(NSString *)name
{
    PSLMDBTable *result = nil;
    
    pthread_rwlock_rdlock(&_tablesLock);
    result = _tables[name];
    pthread_rwlock_unlock(&_tablesLock);
    
    if (result == nil)
    {
        pthread_rwlock_wrlock(&_tablesLock);
        result = _tables[name];
        if (result == nil)
        {
            int rc = 0;
            
            MDB_txn *txn = NULL;
            rc = mdb_txn_begin(_env, NULL, 0, &txn);
            if (rc != MDB_SUCCESS)
            {
                TGLog(@"[PSLMDBKeyValueStore transaction begin failed %d]", rc);
                
                if (rc == MDB_PANIC)
                {
                    TGLog(@"[PSLMDBKeyValueStore critical error received]");
                    
                    [self panic];
                }
            }
            
            MDB_dbi dbi;
            
            rc = mdb_dbi_open(txn, [name UTF8String], MDB_CREATE, &dbi);
            if (rc != MDB_SUCCESS)
            {
                mdb_txn_abort(txn);
                
                TGLog(@"[PSLMDBKeyValueStore mdb_dbi_open failed %d]", rc);
            }
            else
            {
                mdb_txn_commit(txn);
                
                PSLMDBTable *createdTable = [[PSLMDBTable alloc] initWithDbi:dbi];
                _tables[name] = createdTable;
                result = createdTable;
            }
        }
        pthread_rwlock_unlock(&_tablesLock);
    }
    
    return result;
}

- (void)readFromTable:(NSString *)name inTransaction:(void (^)(id<PSKeyValueReader>))transaction
{
    if (transaction == nil)
        return;
    
    PSLMDBTable *table = [self _tableWithName:name];
    if (table != nil)
    {
        int rc = 0;
        MDB_txn *txn = NULL;
        
        rc = mdb_txn_begin(_env, NULL, MDB_RDONLY, &txn);
        if (rc != MDB_SUCCESS)
        {
            TGLog(@"[PSLMDBKeyValueStore mdb_txn_begin failed %d", rc);
            
            if (rc == MDB_PANIC)
            {
                TGLog(@"[PSLMDBKeyValueStore critical error received]");
                
                [self panic];
            }
        }
        else
        {
            transaction([[PSLMDBKeyValueReader alloc] initWithTable:table transaction:txn]);
            
            rc = mdb_txn_commit(txn);
            
            if (rc != MDB_SUCCESS)
                TGLog(@"[PSLMDBKeyValueStore mdb_txn_commit error %d]", rc);
        }
    }
}

- (void)writeToTable:(NSString *)name inTransaction:(void (^)(id<PSKeyValueWriter>))transaction
{
    if (transaction == nil)
        return;
    
    PSLMDBTable *table = [self _tableWithName:name];
    if (table != nil)
    {
        int rc = 0;
        MDB_txn *txn = NULL;
        
        rc = mdb_txn_begin(_env, NULL, 0, &txn);
        if (rc != MDB_SUCCESS)
        {
            TGLog(@"[PSLMDBKeyValueStore mdb_txn_begin failed %d", rc);
            
            if (rc == MDB_PANIC)
            {
                TGLog(@"[PSLMDBKeyValueStore critical error received]");
                
                [self panic];
            }
        }
        else
        {
            transaction([[PSLMDBKeyValueWriter alloc] initWithTable:table transaction:txn]);
            
            rc = mdb_txn_commit(txn);
            
            if (rc != MDB_SUCCESS)
                TGLog(@"[PSLMDBKeyValueStore mdb_txn_commit error %d]", rc);
        }
    }
}

@end
