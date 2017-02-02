#import "TGBotContextResults.h"

@implementation TGBotContextResultsSwitchPm

- (instancetype)initWithText:(NSString *)text startParam:(NSString *)startParam {
    self = [super init];
    if (self != nil) {
        _text = text;
        _startParam = startParam;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithText:[aDecoder decodeObjectForKey:@"text"] startParam:[aDecoder decodeObjectForKey:@"startParam"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:_startParam forKey:@"startParam"];
}

@end

@implementation TGBotContextResults

- (instancetype)initWithUserId:(int32_t)userId peerId:(int64_t)peerId accessHash:(int64_t)accessHash isMedia:(bool)isMedia query:(NSString *)query nextOffset:(NSString *)nextOffset results:(NSArray *)results switchPm:(TGBotContextResultsSwitchPm *)switchPm {
    self = [super init];
    if (self != nil) {
        _userId = userId;
        _peerId = peerId;
        _accessHash = accessHash;
        _isMedia = isMedia;
        _query = query;
        _nextOffset = nextOffset;
        _results = results;
        _switchPm = switchPm;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithUserId:[aDecoder decodeInt32ForKey:@"userId"] peerId:[aDecoder decodeInt64ForKey:@"peerId"] accessHash:[aDecoder decodeInt64ForKey:@"accessHash"] isMedia:[aDecoder decodeBoolForKey:@"isMedia"] query:[aDecoder decodeObjectForKey:@"query"] nextOffset:[aDecoder decodeObjectForKey:@"nextOffset"] results:[aDecoder decodeObjectForKey:@"results"] switchPm:[aDecoder decodeObjectForKey:@"switchPm"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_userId forKey:@"userId"];
    [aCoder encodeInt64:_peerId forKey:@"peerId"];
    [aCoder encodeBool:_isMedia forKey:@"isMedia"];
    [aCoder encodeObject:_query forKey:@"query"];
    [aCoder encodeObject:_nextOffset forKey:@"nextOffset"];
    [aCoder encodeObject:_results forKey:@"results"];
    [aCoder encodeObject:_switchPm forKey:@"switchPm"];
}

@end
