#import "TGMessageRange.h"

#import <LegacyComponents/LegacyComponents.h>

bool TGMessageRangeContains(TGMessageRange range, __unused int64_t peerId, int32_t messageId, int date)
{
    if (range.firstPeerId != 0 || range.lastPeerId != 0)
    {
        return date >= range.firstDate && date <= range.lastDate;
    }
    else
    {
        return date >= range.firstDate && date <= range.lastDate && (messageId < TGMessageLocalMidBaseline ? (messageId >= range.firstMessageId && messageId <= range.lastMessageId) : (messageId >= range.firstLocalMessageId && messageId <= range.lastLocalMessageId));
    }
}

bool TGMessageRangeContains(TGMessageRange const &range, __unused int64_t peerId, int32_t messageId, int date)
{
    if (range.firstPeerId != 0 || range.lastPeerId != 0)
    {
        return date >= range.firstDate && date <= range.lastDate;
    }
    else
    {
        return date >= range.firstDate && date <= range.lastDate && (messageId < TGMessageLocalMidBaseline ? (messageId >= range.firstMessageId && messageId <= range.lastMessageId) : (messageId >= range.firstLocalMessageId && messageId <= range.lastLocalMessageId));
    }
}
