/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGImageInfo.h"

#import "TL/TLMetaScheme.h"

#ifdef __cplusplus
extern "C" {
#endif

NSString *extractFileUrl(TLFileLocation *fileLocation);
bool extractFileUrlComponents(NSString *fileUrl, int *datacenterId, int64_t *volumeId, int *localId, int64_t *secret);
    
#ifdef __cplusplus
}
#endif

@interface TGImageInfo (Telegraph)

- (id)initWithTelegraphSizesDescription:(NSArray *)sizesDesc;

@end
