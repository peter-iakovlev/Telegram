#import "PSKeyValueReader.h"
#import "PSKeyValueWriter.h"

#import "lmdb.h"

@class PSLMDBTable;

@interface PSLMDBKeyValueReaderWriter : NSObject <PSKeyValueReader, PSKeyValueWriter>

- (instancetype)initWithTable:(PSLMDBTable *)table transaction:(MDB_txn *)transaction;

@end
