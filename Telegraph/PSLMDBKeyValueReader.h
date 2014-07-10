#import "PSKeyValueReader.h"

#import "lmdb.h"

@class PSLMDBTable;

@interface PSLMDBKeyValueReader : NSObject <PSKeyValueReader>

- (instancetype)initWithTable:(PSLMDBTable *)table transaction:(MDB_txn *)transaction;

@end
