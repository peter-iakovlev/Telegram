/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGAudioMediaAttachment+Telegraph.h"

@implementation TGAudioMediaAttachment (Telegraph)

- (instancetype)initWithTelegraphAudioDesc:(TLAudio *)desc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGAudioMediaAttachmentType;
        
        self.audioId = desc.n_id;
        
        if ([desc isKindOfClass:[TLAudio$audio class]])
        {
            TLAudio$audio *concreteAudio = (TLAudio$audio *)desc;
            
            self.accessHash = concreteAudio.access_hash;
            self.datacenterId = concreteAudio.dc_id;
            self.duration = concreteAudio.duration;
            self.fileSize = concreteAudio.size;
        }
    }
    return self;
}

@end
