#import <Foundation/Foundation.h>

typedef struct {
    int32_t namespaceId;
    int32_t peerId;
} TGPeerId;

typedef enum {
    TGPeerIdPrivate = 0,
    TGPeerIdGroup = 1,
    TGPeerIdChannel = 2
} TGPeerIdNamespace;

#define TGPeerIdPrivateMake(x) ((TGPeerId){.namespaceId = TGPeerIdPrivate, .peerId = (x)})
#define TGPeerIdGroupMake(x) ((TGPeerId){.namespaceId = TGPeerIdGroup, .peerId = (x)})
#define TGPeerIdChannelMake(x) ((TGPeerId){.namespaceId = TGPeerIdChannel, .peerId = (x)})
#define TGPeerIdEqualToPeerId(x, y) ((x).namespaceId == (y).namespaceId && (x).peerId == (y).peerId)
