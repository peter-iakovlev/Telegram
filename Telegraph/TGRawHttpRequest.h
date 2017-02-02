/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#import <thirdparty/AFNetworking/AFHTTPRequestOperation.h>

typedef void (^TGRawHttpRequestCompletionBlock)(NSData *response);

@interface TGRawHttpRequest : NSObject

@property (nonatomic) bool cancelled;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSArray *acceptCodes;
@property (nonatomic, strong) NSDictionary *httpHeaders;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, copy) TGRawHttpRequestCompletionBlock completionBlock;
@property (nonatomic, copy) void (^progressBlock)(float progress);
@property (nonatomic, assign) NSInteger expectedFileSize;
@property (nonatomic) int retryCount;
@property (nonatomic) int maxRetryCount;

- (void)cancel;
- (void)dispose;

@end
