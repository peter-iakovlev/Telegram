//
//  AFHTTPRequestOperation+GDFileManager.m
//  GDFileManagerExample
//
//  Created by Graham Dennis on 21/08/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "AFHTTPRequestOperation+GDFileManager.h"

static NSString * cat_AFStringFromIndexSet(NSIndexSet *indexSet) {
    NSMutableString *string = [NSMutableString string];
    
    NSRange range = NSMakeRange([indexSet firstIndex], 1);
    while (range.location != NSNotFound) {
        NSUInteger nextIndex = [indexSet indexGreaterThanIndex:range.location];
        while (nextIndex == range.location + range.length) {
            range.length++;
            nextIndex = [indexSet indexGreaterThanIndex:nextIndex];
        }
        
        if (string.length) {
            [string appendString:@","];
        }
        
        if (range.length == 1) {
            [string appendFormat:@"%lu", (unsigned long)range.location];
        } else {
            NSUInteger firstIndex = range.location;
            NSUInteger lastIndex = firstIndex + range.length - 1;
            [string appendFormat:@"%lu-%lu", (unsigned long)firstIndex, (unsigned long)lastIndex];
        }
        
        range.location = nextIndex;
        range.length = 1;
    }
    
    return string;
}

@interface AFURLConnectionOperation () <NSURLConnectionDataDelegate>

@end

@interface AFHTTPRequestOperation (Private)

@property (readwrite, nonatomic, retain) NSError *HTTPError;

@end

@implementation AFHTTPRequestOperation (GDFileManager)

-  (NSError *)error {
    if (self.response && !self.HTTPError)
    {
        if (![self hasAcceptableStatusCode]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected status code in (%@), got %d", nil), cat_AFStringFromIndexSet(self.acceptableStatusCodes), [self.response statusCode]] forKey:NSLocalizedDescriptionKey];
            [userInfo setValue:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            [userInfo setValue:self.response forKey:@"AFNetworkingOperationFailingURLResponseErrorKey"];
            
            self.HTTPError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
        } else if ([self.responseData length] > 0 && ![self hasAcceptableContentType]) { // Don't invalidate content type if there is no content
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected content type %@, got %@", nil), self.acceptableContentTypes, [self.response MIMEType]] forKey:NSLocalizedDescriptionKey];
            [userInfo setValue:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            [userInfo setValue:self.response forKey:@"AFNetworkingOperationFailingURLResponseErrorKey"];
            
            self.HTTPError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
        }
    }
    
    if (self.HTTPError) {
        return self.HTTPError;
    } else {
        return [super error];
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSIndexSet *acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    NSUInteger statusCode = ([self.response isKindOfClass:[NSHTTPURLResponse class]]) ? (NSUInteger)[self.response statusCode] : 200;
    BOOL hasAcceptableStatusCode = [acceptableStatusCodes containsIndex:statusCode];
    
    if (!hasAcceptableStatusCode) {
        self.outputStream = [NSOutputStream outputStreamToMemory];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        for (NSString *runLoopMode in self.runLoopModes) {
            [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
        }
    }
    
    [super connection:connection didReceiveResponse:response];
}


@end
