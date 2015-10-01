#import "TGRemoteHttpLocationSignal.h"

#import <thirdparty/AFNetworking/AFHTTPRequestOperation.h>

@implementation TGRemoteHttpLocationSignal

+ (SSignal *)dataForHttpLocation:(NSString *)httpLocation
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:httpLocation]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setSuccessCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [operation setFailureCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        [operation setCompletionBlockWithSuccess:^(__unused AFHTTPRequestOperation *operation, __unused id responseObject)
        {
            [subscriber putNext:[operation responseData]];
            [subscriber putCompletion];
        } failure:^(__unused AFHTTPRequestOperation *operation, __unused NSError *error)
        {
            [subscriber putError:nil];
        }];
        
        [operation start];
        
        __weak AFHTTPRequestOperation *weakOperation = operation;
        
        return [[SBlockDisposable alloc] initWithBlock:^
        {
            __strong AFHTTPRequestOperation *strongOperation = weakOperation;
            [strongOperation cancel];
        }];
    }];
}

+ (SSignal *)jsonForHttpLocation:(NSString *)httpLocation
{
    return [[self dataForHttpLocation:httpLocation] mapToSignal:^SSignal *(NSData *response)
    {
        if (response == nil)
            return [SSignal fail:nil];
        
        @try
        {
            NSError *error = nil;
            id json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            if (error == nil)
                return [SSignal single:json];
            else
                return [SSignal fail:error];
        }
        @catch (NSException *exception)
        {
            return [SSignal fail:nil];
        }
    }];
}

@end
