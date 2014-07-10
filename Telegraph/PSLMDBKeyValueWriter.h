#import "PSKeyValueWriter.h"

#import "lmdb.h"

@class PSLMDBTable;

@interface PSLMDBKeyValueWriter : NSObject <PSKeyValueWriter>

- (instancetype)initWithTable:(PSLMDBTable *)table transaction:(MDB_txn *)transaction;

@end
