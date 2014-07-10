#import "TGVideoMediaAttachment+Telegraph.h"

#import "TGImageInfo+Telegraph.h"

@implementation TGVideoMediaAttachment (Telegraph)

- (id)initWithTelegraphVideoDesc:(TLVideo *)videoDesc
{
    self = [super init];
    if (self != nil)
    {
        self.type = TGVideoMediaAttachmentType;
        
        if ([videoDesc isKindOfClass:[TLVideo$video class]])
        {
            TLVideo$video *concreteVideo = (TLVideo$video *)videoDesc;
            
            self.videoId = concreteVideo.n_id;
            self.accessHash = concreteVideo.access_hash;
            
            TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
            [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"video:%lld:%lld:%d:%d", self.videoId, self.accessHash, concreteVideo.dc_id, concreteVideo.size] size:concreteVideo.size];
            self.videoInfo = videoInfo;
            
            self.duration = concreteVideo.duration;
            self.dimensions = CGSizeMake(concreteVideo.w, concreteVideo.h);
            
            self.thumbnailInfo = [[TGImageInfo alloc] initWithTelegraphSizesDescription:[[NSArray alloc] initWithObjects:concreteVideo.thumb, nil]];
        }
    }
    return self;
}

@end
