#ifndef Telegraph_TGMessageRange_h
#define Telegraph_TGMessageRange_h

typedef struct {
    int32_t firstMessageId;
    int32_t firstLocalMessageId;
    int firstDate;
    int32_t lastMessageId;
    int32_t lastLocalMessageId;
    int lastDate;
} TGMessageRange;

#ifdef __cplusplus
extern "C" {
#endif

inline bool TGMessageRangeIsEmpty(TGMessageRange range)
{
    return range.firstDate > range.lastDate && range.firstMessageId > range.lastMessageId && range.firstLocalMessageId > range.lastLocalMessageId;
}

inline TGMessageRange TGMessageRangeEmpty()
{
    return (TGMessageRange){ .firstMessageId = INT32_MAX, .firstLocalMessageId = INT32_MAX, .firstDate = INT_MAX, .lastMessageId = INT32_MIN, .lastLocalMessageId = INT32_MIN, .lastDate = INT_MIN};
}

#ifndef __cplusplus
bool TGMessageRangeContains(TGMessageRange range, int32_t messageId, int date);
#endif
    
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
bool TGMessageRangeContains(TGMessageRange const &range, int32_t messageId, int date);
#endif

#endif
