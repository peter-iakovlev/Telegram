#import "TGDatacenterConnectionContext.h"

#import <MTProtoKit/MTRequest.h>

@implementation TGDatacenterConnectionContext

- (instancetype)initWithMtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService
{
    self = [super init];
    if (self != nil)
    {
        _mtContext = mtContext;
        _mtProto = mtProto;
        _mtRequestService = mtRequestService;
    }
    return self;
}

- (void)dealloc
{
    [_mtProto stop];
}

- (SSignal *)function:(Api38_FunctionContext *)functionContext
{
    __weak TGDatacenterConnectionContext *weakSelf = self;
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        __strong TGDatacenterConnectionContext *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            MTRequest *request = [[MTRequest alloc] init];
            
            [request setPayload:functionContext.payload metadata:functionContext.metadata responseParser:functionContext.responseParser];
            
            [request setCompleted:^(id result, __unused NSTimeInterval timestamp, MTRpcError *error)
            {
                if (error == nil)
                {
                    [subscriber putNext:result];
                    [subscriber putCompletion];
                }
                else
                    [subscriber putError:error];
            }];
            
            //request.dependsOnPasswordEntry = (requestClass & TGRequestClassIgnorePasswordEntryRequired) == 0;
            
            [request setShouldContinueExecutionWithErrorContext:^bool(MTRequestErrorContext *errorContext)
            {
                return false;
            }];
            
            [strongSelf->_mtRequestService addRequest:request];
            id requestToken = request.internalId;
            
            return [[SBlockDisposable alloc] initWithBlock:^
            {
                __strong TGDatacenterConnectionContext *strongSelf = weakSelf;
                [strongSelf.mtRequestService removeRequestByInternalId:requestToken];
            }];
        }
        else
        {
            [subscriber putError:nil];
            return nil;
        }
    }];
}

@end

@implementation TGPooledDatacenterConnectionContext

- (instancetype)initWithDatacenterConnectionContext:(TGDatacenterConnectionContext *)context returnContext:(void (^)(TGDatacenterConnectionContext *))returnContext
{
    self = [super init];
    if (self != nil)
    {
        _context = context;
        _returnContext = [returnContext copy];
    }
    return self;
}

- (void)dealloc
{
    TGDatacenterConnectionContext *context = _context;
    if (_returnContext)
        _returnContext(context);
}

@end
