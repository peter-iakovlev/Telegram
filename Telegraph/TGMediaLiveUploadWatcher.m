#import "TGMediaLiveUploadWatcher.h"

#import <sys/stat.h>

#import "ActionStage.h"
#import "TGLiveUploadActor.h"

#import "MP4Atom.h"

#import "TGTelegramNetworking.h"

@interface TGMediaLiveUploadWatcher () <ASWatcher>
{
    NSString *_liveUploadPath;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGMediaLiveUploadWatcher

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        static int nextActionId = 0;
        int actionId = nextActionId++;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        _liveUploadPath = [[NSString alloc] initWithFormat:@"/tg/liveUpload/(%d)", (int)actionId];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)setupWithFileURL:(NSURL *)fileURL
{
    [super setupWithFileURL:fileURL];
    
    NSData *(^dataProvider)(NSUInteger, NSUInteger) = ^NSData *(NSUInteger offset, NSUInteger length)
    {
        __block NSData *result = nil;
        [TGMediaLiveUploadWatcher readFileURL:fileURL processBlock:^(NSFileHandle *file, __unused struct stat s, __unused MP4Atom *mdatAtom)
        {
            [file seekToFileOffset:mdatAtom->_offset + offset];
            result = [file readDataOfLength:length];
        }];
        return result;
    };
    
    [ActionStageInstance() requestActor:_liveUploadPath options:@
    {
        @"filePath": fileURL.path,
        @"unlinkFileAfterCompletion": @true,
        @"encryptFile": @false,
        @"lateHeader": @true,
        @"dataProvider": [dataProvider copy],
        @"mediaTypeTag": @(TGNetworkMediaTypeTagVideo)
    } flags:0 watcher:self];
}

- (id)fileUpdated:(bool)completed
{
    if (completed)
    {
        __block NSData *headerData = nil;
        __block NSUInteger finalSize = 0;
        __block TGLiveUploadActorData *liveData = nil;
        
        [TGMediaLiveUploadWatcher readFileURL:_fileURL processBlock:^(NSFileHandle *file, struct stat s, MP4Atom *mdatAtom)
        {
            [file seekToFileOffset:0];
            headerData = [file readDataOfLength:(NSUInteger)mdatAtom->_offset];
            finalSize = (NSUInteger)s.st_size;
        }];
        
        if (headerData != nil && finalSize != 0)
        {
            dispatch_sync([ActionStageInstance() globalStageDispatchQueue], ^
            {
                TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
                liveData = [actor finishRestOfFileWithHeader:headerData finalSize:finalSize];
            });
        }
        
        return liveData;
    }
    else
    {
        __block NSUInteger availableSize = 0;
        [TGMediaLiveUploadWatcher readFileURL:_fileURL processBlock:^(__unused NSFileHandle *file, __unused struct stat s, MP4Atom *mdatAtom)
        {
            availableSize = MAX(0, ((int)(mdatAtom.length)) - 1024);
        }];
        
        if (availableSize != 0)
        {
            [ActionStageInstance() dispatchOnStageQueue:^
            {
                TGLiveUploadActor *actor = (TGLiveUploadActor *)[ActionStageInstance() executingActorWithPath:_liveUploadPath];
                [actor updateSize:availableSize];
            }];
        }
    }
    
    return nil;
}

+ (NSData *)_finalHeaderDataAndSize:(NSUInteger *)finalSize fileURL:(NSURL *)fileURL
{
    NSData *headerData = nil;
    
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fileURL.path];
    struct stat s;
    fstat([file fileDescriptor], &s);
    MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
    MP4Atom *mdatAtom = [self _findMdat:fileAtom];
    if (mdatAtom != nil)
    {
        [file seekToFileOffset:0];
        headerData = [file readDataOfLength:(NSUInteger)mdatAtom->_offset];
        if (finalSize != NULL)
            *finalSize = (NSUInteger)s.st_size;
    }
    [file closeFile];
    
    return headerData;
}

+ (void)readFileURL:(NSURL *)fileURL processBlock:(void (^)(NSFileHandle *, struct stat, MP4Atom *))processBlock
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fileURL.path];
    struct stat s;
    fstat([file fileDescriptor], &s);
    
    MP4Atom *fileAtom = [MP4Atom atomAt:0 size:(int)s.st_size type:(OSType)('file') inFile:file];
    MP4Atom *mdatAtom = [TGMediaLiveUploadWatcher _findMdat:fileAtom];
    if (mdatAtom != nil && processBlock != nil)
        processBlock(file, s, mdatAtom);
    
    [file closeFile];
}

+ (MP4Atom *)_findMdat:(MP4Atom *)atom
{
    if (atom == nil)
        return nil;
    
    if (atom.type == (OSType)'mdat')
        return atom;
    
    while (true)
    {
        MP4Atom *child = [atom nextChild];
        if (child == nil)
            break;
        
        MP4Atom *result = [self _findMdat:child];
        if (result != nil)
            return result;
    }
    
    return nil;
}

@end
