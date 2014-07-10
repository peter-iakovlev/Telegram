/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDebugController.h"

#import "TGTelegramNetworking.h"

#import <MtProtoKit/MTContext.h>

@interface TGDebugController () <MTContextChangeListener>
{
    __weak MTContext *_context;
}

@end

@implementation TGDebugController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _context = [[TGTelegramNetworking instance] context];
        [(MTContext *)_context addChangeListener:self];
    }
    return self;
}

- (void)dealloc
{
    [(MTContext *)_context removeChangeListener:self];
}

- (void)contextDatacenterTransportSchemeUpdated:(MTContext *)context datacenterId:(NSInteger)datacenterId transportScheme:(MTTransportScheme *)transportScheme
{
    
}

@end
