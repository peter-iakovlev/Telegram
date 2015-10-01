#import "TGICloudItem.h"

#import "TGStringUtils.h"

@implementation TGICloudItem

+ (instancetype)iCloudItemWithUrl:(NSURL *)url
{
    bool succeed = [url startAccessingSecurityScopedResource];
    if (!succeed)
        return nil;
    
    NSError *error;
    NSNumber *fileSizeValue;
    [url getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&error];
    if (error != nil || fileSizeValue == nil)
        return nil;
    
    TGICloudItem *item = [self iCloudItemWithUrl:url fileSize:[fileSizeValue unsignedIntegerValue]];
    
    [url stopAccessingSecurityScopedResource];
    
    return item;
}

+ (instancetype)iCloudItemWithUrl:(NSURL *)url fileSize:(NSUInteger)fileSize
{
    TGICloudItem *item = [[TGICloudItem alloc] init];
    item->_fileId = TGStringMD5(url.absoluteString);
    item->_fileUrl = url;
    item->_fileName = [url.absoluteString.lastPathComponent stringByRemovingPercentEncoding];
    item->_fileSize = fileSize;
    
    return item;
}

@end

@interface TGICloudItemRequest ()
{
    NSURL *_url;
    NSMetadataQuery *_query;
}

@property (nonatomic, copy) void (^completionBlock)(TGICloudItem *);

@end

@implementation TGICloudItemRequest

+ (instancetype)requestICloudItemWithUrl:(NSURL *)url completion:(void (^)(TGICloudItem *))completion
{
    TGICloudItemRequest *request = [[TGICloudItemRequest alloc] init];
    
    NSError *error;
    NSDictionary *fileAttributes = [url resourceValuesForKeys:@[ NSURLUbiquitousItemDownloadingStatusKey ] error:&error];
    
    bool isRemoteFile = false;
    bool isCurrent = true;
    
    if (fileAttributes != nil)
    {
        NSString *downloadingStatusAttribute = fileAttributes[NSURLUbiquitousItemDownloadingStatusKey];
        
        if (downloadingStatusAttribute != nil)
        {
            isRemoteFile = true;
            if (![downloadingStatusAttribute isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent])
                isCurrent = false;
        }
    }

    if (!isRemoteFile || isCurrent)
    {
        request->_completed = true;
        
        TGICloudItem *item = [TGICloudItem iCloudItemWithUrl:url];
        if (completion != nil)
            completion(item);
        
        return request;
    }
    
    request->_url = url;
    request->_completionBlock = completion;

    NSString *fileName = [url.absoluteString.lastPathComponent stringByRemovingPercentEncoding];
    
    request->_query = [[NSMetadataQuery alloc] init];
    [request->_query setSearchScopes:@[ NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope ]];
    [request->_query setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, fileName]];
    [request->_query setValueListAttributes:@[ NSMetadataItemFSSizeKey ]];
    
    [[NSNotificationCenter defaultCenter] addObserver:request selector:@selector(metadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:request->_query];
    
    [request->_query startQuery];
    
    return request;
}

- (void)metadataQueryDidFinishGathering:(NSNotification *)__unused notification
{
    NSMetadataItem *metadataItem = _query.results.firstObject;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:_query];
    _query = nil;

    if (self.completionBlock == nil)
        return;
    
    if (metadataItem == nil)
    {
        self.completionBlock(nil);
        return;
    }
    
    NSUInteger fileSize = [[metadataItem valueForAttribute:NSMetadataItemFSSizeKey] unsignedIntegerValue];
    if (fileSize == 0)
    {
        self.completionBlock(nil);
        return;
    }
    
    TGICloudItem *item = [TGICloudItem iCloudItemWithUrl:_url fileSize:fileSize];
    
    if (self.completionBlock != nil)
        self.completionBlock(item);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
