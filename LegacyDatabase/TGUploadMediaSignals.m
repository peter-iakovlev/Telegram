#import "TGUploadMediaSignals.h"

@implementation TGUploadMediaSignals

+ (SSignal *)uploadDataWithContext:(TGShareContext *)context data:(NSData *)data outFileId:(int64_t *)outFileId outLargeParts:(bool *)outLargeParts outNumberOfParts:(NSUInteger *)outNumberOfParts
{
    int64_t fileId = 0;
    arc4random_buf(&fileId, 8);
    if (outFileId)
        *outFileId = fileId;
    
    NSUInteger partSize = 0;
    if (data.length >= 10 * 1024 * 1024)
        partSize = 512 * 1024;
    else
        partSize = 12 * 1024;
    
    bool largeParts = partSize >= 500 * 1024;
    if (outLargeParts)
        *outLargeParts = largeParts;
    
    NSUInteger numberOfParts = data.length / partSize + (data.length % partSize == 0 ? 0 : 1);
    if (outNumberOfParts)
        *outNumberOfParts = numberOfParts;
    
    SSignal *uploadSignal = [[context connectionContextForDatacenter:context.mtProto.datacenterId] mapToSignal:^SSignal *(TGPooledDatacenterConnectionContext *datacenterContext)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            SDisposableSet *partsDisposables = [[SDisposableSet alloc] init];
            NSMutableArray *partsSignals = [[NSMutableArray alloc] init];
            
            for (NSUInteger i = 0; i < numberOfParts; i++)
            {
                SSignal *uploadPart = [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
                {
                    Api70_FunctionContext *functionContext = nil;
                    if (largeParts)
                    {
                        functionContext = [Api70 upload_saveBigFilePartWithFileId:@(fileId) filePart:@(i) fileTotalParts:@(numberOfParts) bytes:[data subdataWithRange:NSMakeRange(i * partSize, MIN(data.length - i * partSize, partSize))]];
                    }
                    else
                    {
                        functionContext = [Api70 upload_saveFilePartWithFileId:@(fileId) filePart:@(i) bytes:[data subdataWithRange:NSMakeRange(i * partSize, MIN(data.length - i * partSize, partSize))]];
                    }
                    return [[datacenterContext.context function:functionContext] map:^id(__unused id next)
                    {
                        return @((float)i / (float)numberOfParts);
                    }];
                }];
                [partsSignals addObject:uploadPart];
            }
            
            __block bool cancelled = false;
            
            SAtomic *partsState = [[SAtomic alloc] initWithValue:@{@"remainingParts": partsSignals, @"uploadingParts": @(0)}];
            
            __block void (^maybeTakeParts)() = nil;
            
            void (^maybeTakePartsImpl)() = ^
            {
                if (cancelled)
                    return;
                
                __block bool complete = false;
                NSMutableArray *takenParts = [[NSMutableArray alloc] init];
                
                [partsState modify:^id(NSDictionary *state)
                {
                    if (((NSArray *)state[@"remainingParts"]).count == 0 && [state[@"uploadingParts"] intValue] <= 0)
                    {
                        complete = true;
                    }
                    else if (((NSArray *)state[@"remainingParts"]).count != 0 && [state[@"uploadingParts"] intValue] < 3)
                    {
                        NSMutableArray *remainingParts = [[NSMutableArray alloc] initWithArray:state[@"remainingParts"]];
                        for (int i = 0; i < 3 && remainingParts.count != 0; i++)
                        {
                            [takenParts addObject:remainingParts[0]];
                            [remainingParts removeObjectAtIndex:0];
                        }
                        
                        return @{@"remainingParts": remainingParts, @"uploadingParts": @([state[@"uploadingParts"] intValue] + takenParts.count)};
                    }
                    
                    return state;
                }];
                
                if (complete)
                    [subscriber putCompletion];
                else if (takenParts.count != 0)
                {
                    for (SSignal *uploadPart in takenParts)
                    {
                        id<SDisposable> disposable = [uploadPart startWithNext:^(id next)
                        {
                            [subscriber putNext:next];
                        } error:^(id error)
                        {
                            [subscriber putError:error];
                        } completed:^
                        {
                            [partsState modify:^id(NSDictionary *state)
                            {
                                return @{@"remainingParts": state[@"remainingParts"], @"uploadingParts": @([state[@"uploadingParts"] intValue] - 1)};
                            }];
                            maybeTakeParts();
                        }];
                        [partsDisposables add:disposable];
                    }
                }
            };
            
            maybeTakeParts = [maybeTakePartsImpl copy];
            
            [partsDisposables add:[[SBlockDisposable alloc] initWithBlock:^
            {
                cancelled = true;
            }]];
            
            maybeTakeParts();
            
            return partsDisposables;
        }];
    }];
    
    return uploadSignal;
}

+ (SSignal *)uploadPhotoWithContext:(TGShareContext *)context data:(NSData *)data
{
    int64_t fileId = 0;
    bool largeParts = false;
    NSUInteger numberOfParts = 0;
    SSignal *uploadSignal = [self uploadDataWithContext:context data:data outFileId:&fileId outLargeParts:&largeParts outNumberOfParts:&numberOfParts];
    
    Api70_InputFile *inputFile = nil;
    if (largeParts)
        inputFile = [Api70_InputFile inputFileBigWithPid:@(fileId) parts:@(numberOfParts) name:@"file.jpg"];
    else
        inputFile = [Api70_InputFile inputFileWithPid:@(fileId) parts:@(numberOfParts) name:@"file.jpg" md5Checksum:@""];
    
    Api70_InputMedia_inputMediaUploadedPhoto *inputMedia = [Api70_InputMedia inputMediaUploadedPhotoWithFlags:@(0) file:inputFile caption:@"" stickers:nil ttlSeconds:nil];
    
    uploadSignal = [uploadSignal then:[SSignal single:inputMedia]];
    
    return uploadSignal;
}

+ (SSignal *)uploadFileWithContext:(TGShareContext *)context data:(NSData *)data name:(NSString *)name mimeType:(NSString *)mimeType attributes:(NSArray *)attributes
{
    int64_t fileId = 0;
    bool largeParts = false;
    NSUInteger numberOfParts = 0;
    SSignal *uploadSignal = [self uploadDataWithContext:context data:data outFileId:&fileId outLargeParts:&largeParts outNumberOfParts:&numberOfParts];
    
    Api70_InputFile *inputFile = nil;
    if (largeParts)
        inputFile = [Api70_InputFile inputFileBigWithPid:@(fileId) parts:@(numberOfParts) name:name];
    else
        inputFile = [Api70_InputFile inputFileWithPid:@(fileId) parts:@(numberOfParts) name:name md5Checksum:@""];
    
    NSMutableArray *completeAttributes = [[NSMutableArray alloc] init];
    [completeAttributes addObject:[Api70_DocumentAttribute documentAttributeFilenameWithFileName:name]];
    [completeAttributes addObjectsFromArray:attributes];
    
    Api70_InputMedia_inputMediaUploadedDocument *inputMedia = [Api70_InputMedia inputMediaUploadedDocumentWithFlags:@(0) file:inputFile thumb:nil mimeType:mimeType.length == 0 ? @"application/octet-stream" : mimeType attributes:completeAttributes caption:@"" stickers:nil ttlSeconds:nil];
    
    uploadSignal = [uploadSignal then:[SSignal single:inputMedia]];
    
    return uploadSignal;
}

+ (SSignal *)uploadVideoWithContext:(TGShareContext *)context data:(NSData *)data thumbData:(NSData *)thumbData duration:(int32_t)duration width:(int32_t)width height:(int32_t)height mimeType:(NSString *)mimeType
{
    int64_t fileId = 0;
    bool largeParts = false;
    NSUInteger numberOfParts = 0;
    SSignal *uploadSignal = [self uploadDataWithContext:context data:data outFileId:&fileId outLargeParts:&largeParts outNumberOfParts:&numberOfParts];
    
    NSString *fileName = @"file.mov";
    Api70_InputFile *inputFile = nil;
    if (largeParts)
        inputFile = [Api70_InputFile inputFileBigWithPid:@(fileId) parts:@(numberOfParts) name:fileName];
    else
        inputFile = [Api70_InputFile inputFileWithPid:@(fileId) parts:@(numberOfParts) name:fileName md5Checksum:@""];
    
    int64_t thumbFileId = 0;
    bool thumbLargeParts = false;
    NSUInteger thumbNumberOfParts = 0;
    SSignal *thumbUploadSignal = [[self uploadDataWithContext:context data:thumbData outFileId:&thumbFileId outLargeParts:&thumbLargeParts outNumberOfParts:&thumbNumberOfParts] filter:^bool(id value)
    {
        return ![value isKindOfClass:[NSNumber class]];
    }];
    
    NSString *thumbFileName = @"file.jpg";
    Api70_InputFile *inputThumbFile = nil;
    if (thumbLargeParts)
        inputThumbFile = [Api70_InputFile inputFileBigWithPid:@(thumbFileId) parts:@(thumbNumberOfParts) name:thumbFileName];
    else
        inputThumbFile = [Api70_InputFile inputFileWithPid:@(thumbFileId) parts:@(thumbNumberOfParts) name:thumbFileName md5Checksum:@""];
    
    Api70_InputMedia_inputMediaUploadedDocument *inputMedia = [Api70_InputMedia inputMediaUploadedDocumentWithFlags:@(1 << 2) file:inputFile thumb:inputThumbFile mimeType:@"video/mp4" attributes:@[
                                                                                                                                                                                                          [Api70_DocumentAttribute documentAttributeVideoWithFlags:@(0) duration:@(duration) w:@(width) h:@(height)],
        [Api70_DocumentAttribute documentAttributeFilenameWithFileName:@"video.mp4"]
    ] caption:@"" stickers:nil ttlSeconds:nil];
    
    uploadSignal = [[uploadSignal then:thumbUploadSignal] then:[SSignal single:inputMedia]];
    
    return uploadSignal;
}

@end
