#import "TGMessageRange.h"

#import "TGMessage.h"

bool TGMessageRangeContains(TGMessageRange range, int32_t messageId, int date)
{
    return date >= range.firstDate && date <= range.lastDate && (messageId < TGMessageLocalMidBaseline ? (messageId >= range.firstMessageId && messageId <= range.lastMessageId) : (messageId >= range.firstLocalMessageId && messageId <= range.lastLocalMessageId));
}

bool TGMessageRangeContains(TGMessageRange const &range, int32_t messageId, int date)
{
    return date >= range.firstDate && date <= range.lastDate && (messageId < TGMessageLocalMidBaseline ? (messageId >= range.firstMessageId && messageId <= range.lastMessageId) : (messageId >= range.firstLocalMessageId && messageId <= range.lastLocalMessageId));
}