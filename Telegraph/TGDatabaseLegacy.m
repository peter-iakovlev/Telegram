#import "TGDatabaseLegacy.h"

@implementation TGDatabaseLegacy

/*- (void)deleteMessages:(NSArray *)mids populateActionQueue:(bool)populateActionQueue fillMessagesByConversationId:(NSMutableDictionary *)messagesByConversationId
{
    [self deleteMessages:mids populateActionQueue:populateActionQueue fillMessagesByConversationId:messagesByConversationId keepDate:false populateActionQueueIfIncoming:false];
}

- (void)deleteMessages:(NSArray *)mids populateActionQueue:(bool)populateActionQueue fillMessagesByConversationId:(NSMutableDictionary *)messagesByConversationId keepDate:(bool)keepDate populateActionQueueIfIncoming:(bool)populateActionQueueIfIncoming
{
    [self dispatchOnDatabaseThread:^
     {
         std::map<int64_t, int> conversationSet;
         
         NSMutableArray *actions = [[NSMutableArray alloc] init];
         
         NSString *messagesDeleteFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _messagesTableName];
         NSString *mediaDeleteFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _conversationMediaTableName];
         NSString *outboxDeleteFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _outgoingMessagesTableName];
         
         sqlite3_exec([_database sqliteHandle], "PRAGMA secure_delete = 1", NULL, NULL, NULL);
         
         int deletedUnreadCount = 0;
         
         TGLog(@"Deleting %d messages", (int)mids.count);
         
         for (NSNumber *nMid in mids)
         {
             FMResultSet *messageResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE mid=? LIMIT 1", _messagesTableName], nMid];
             
             bool found = false;
             int64_t cid = 0;
             NSData *localMedia = nil;
             NSArray *parsedLocalMedia = nil;
             bool outgoing = false;
             
             if ([messageResult next])
             {
                 found = true;
                 
                 int indexMedia = [messageResult columnIndexForName:@"media"];
                 int indexCid = [messageResult columnIndexForName:@"cid"];
                 
                 cid = [messageResult longLongIntForColumnIndex:indexCid];
                 
                 outgoing = [messageResult intForColumn:@"outgoing"] != 0;
                 
                 if (messagesByConversationId != nil)
                 {
                     NSNumber *conversationKey = [[NSNumber alloc] initWithLongLong:cid];
                     NSMutableArray *messagesInConversation = [messagesByConversationId objectForKey:conversationKey];
                     if (messagesInConversation == nil)
                     {
                         messagesInConversation = [[NSMutableArray alloc] init];
                         [messagesByConversationId setObject:messagesInConversation forKey:conversationKey];
                     }
                     [messagesInConversation addObject:nMid];
                 }
                 
                 localMedia = [messageResult dataForColumnIndex:indexMedia];
                 
                 if ([nMid intValue] < TGMessageLocalMidBaseline && [messageResult intForColumn:@"outgoing"] == 0 && [messageResult intForColumn:@"unread"] != 0)
                 {
                     conversationSet[cid]--;
                     deletedUnreadCount++;
                 }
                 else
                 {
                     if (conversationSet.find(cid) == conversationSet.end())
                         conversationSet[cid] = 0;
                 }
             }
             else
             {
                 FMResultSet *mediaResult = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid, media FROM %@ WHERE mid=? LIMIT 1", _conversationMediaTableName], nMid];
                 
                 if ([mediaResult next])
                 {
                     found = true;
                     
                     localMedia = [mediaResult dataForColumn:@"media"];
                     
                     cid = [mediaResult longLongIntForColumn:@"cid"];
                     if (conversationSet.find(cid) == conversationSet.end())
                         conversationSet[cid] = 0;
                     
                     if (messagesByConversationId != nil)
                     {
                         NSNumber *conversationKey = [[NSNumber alloc] initWithLongLong:cid];
                         NSMutableArray *messagesInConversation = [messagesByConversationId objectForKey:conversationKey];
                         if (messagesInConversation == nil)
                         {
                             messagesInConversation = [[NSMutableArray alloc] init];
                             [messagesByConversationId setObject:messagesInConversation forKey:conversationKey];
                         }
                         [messagesInConversation addObject:nMid];
                     }
                 }
                 else
                 {
                     TGMessage *mediaMessage = [self _cachedMediaMessageForId:[nMid intValue]];
                     if (mediaMessage != nil)
                     {
                         found = true;
                         outgoing = mediaMessage.outgoing;
                         cid = mediaMessage.cid;
                         parsedLocalMedia = mediaMessage.mediaAttachments;
                     }
                 }
             }
             
             if (found)
             {
                 if (localMedia != nil && localMedia.length != 0)
                 {
                     cleanupMessage(self, [nMid intValue], [TGMessage parseMediaAttachments:localMedia], _messageCleanupBlock);
                 }
                 if (parsedLocalMedia != nil)
                     cleanupMessage(self, [nMid intValue], parsedLocalMedia, _messageCleanupBlock);
                 
                 if (populateActionQueue || (populateActionQueueIfIncoming && !outgoing))
                 {
                     if (cid <= INT_MIN)
                     {
                         int32_t conversationIdHigh = ((int32_t *)&cid)[0];
                         int32_t conversationIdLow = ((int32_t *)&cid)[1];
                         
                         TGDatabaseAction action = { .type = TGDatabaseActionDeleteSecretMessage, .subject = [nMid intValue], .arg0 = conversationIdHigh, .arg1 = conversationIdLow };
                         [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                     }
                     else if ([nMid intValue] < TGMessageLocalMidBaseline)
                     {
                         TGDatabaseAction action = { .type = TGDatabaseActionDeleteMessage, .subject = [nMid intValue], .arg0 = 0, .arg1 = 0 };
                         [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                     }
                 }
                 
                 [_database executeUpdate:messagesDeleteFormat, nMid];
                 [_database executeUpdate:mediaDeleteFormat, nMid];
             }
             
             [self removeMediaFromCacheForPeerId:cid messageIds:@[nMid]];
             
             if ([nMid intValue] >= 800000000)
                 [_database executeUpdate:outboxDeleteFormat, nMid];
         }
         
         for (auto it = conversationSet.begin(); it != conversationSet.end(); it++)
         {
             [self actualizeConversation:it->first dispatch:true conversation:nil forceUpdate:false addUnreadCount:it->second addServiceUnreadCount:0 keepDate:keepDate];
         }
         
         if (deletedUnreadCount != 0)
         {
             int unreadCount = [self databaseState].unreadCount - deletedUnreadCount;
             if (unreadCount < 0)
                 TGLog(@"***** Warning: wrong unread_count");
             [self setUnreadCount:MAX(unreadCount, 0)];
         }
         
         if (actions.count != 0)
             [self storeQueuedActions:actions];
         
         [_database setSoftShouldCacheStatements:false];
         NSMutableString *midsString = [[NSMutableString alloc] init];
         int count = (int)mids.count;
         for (int j = 0; j < count; )
         {
             [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
             
             for (int i = 0; i < 256 && j < count; i++, j++)
             {
                 if (midsString.length != 0)
                     [midsString appendString:@","];
                 [midsString appendFormat:@"%d", [mids[j] intValue]];
             }
             
             [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE mid IN (%@)", _selfDestructTableName, midsString]];
         }
         [_database setSoftShouldCacheStatements:true];
         
         sqlite3_exec([_database sqliteHandle], "PRAGMA secure_delete = 0", NULL, NULL, NULL);
         
         [self dispatchOnIndexThread:^
          {
              NSString *deleteQueryFormat = [NSString stringWithFormat:@"DELETE FROM %@ WHERE docid=?", _messageIndexTableName];
              [_indexDatabase beginTransaction];
              for (NSNumber *nMid in mids)
              {
#if TARGET_IPHONE_SIMULATOR
                  TGLog(@"index: delete %@", nMid);
#endif
                  [_indexDatabase executeUpdate:deleteQueryFormat, nMid];
              }
              [_indexDatabase commit];
          } synchronous:false];
     } synchronous:(populateActionQueue || messagesByConversationId != nil)];
}*/

/*- (void)markMessagesAsReadInConversation:(int64_t)conversationId maxDate:(int32_t)maxDate referenceDate:(int32_t)referenceDate
{
    [self dispatchOnDatabaseThread:^
     {
         NSMutableString *midsString = [[NSMutableString alloc] init];
         bool firstLoop = true;
         int startingDate = maxDate;
         
         int startingDateLimit = 0;
         
         NSMutableArray *markedMids = [[NSMutableArray alloc] init];
         
         std::vector<std::pair<int, int> > midsWithLifetime;
         
         while (true)
         {
             [midsString deleteCharactersInRange:NSMakeRange(0, midsString.length)];
             
             FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE cid=? AND date<=? ORDER BY date DESC LIMIT ?, ?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:startingDate], [[NSNumber alloc] initWithInt:startingDateLimit], [[NSNumber alloc] initWithInt:firstLoop ? 8 : 64]];
             
             int midIndex = [result columnIndexForName:@"mid"];
             int messageIndex = [result columnIndexForName:@"message"];
             int dateIndex = [result columnIndexForName:@"date"];
             int fromIdIndex = [result columnIndexForName:@"from_id"];
             int toIdIndex = [result columnIndexForName:@"to_id"];
             int unreadIndex = [result columnIndexForName:@"unread"];
             int outgoingIndex = [result columnIndexForName:@"outgoing"];
             int messageLifetimeIndex = [result columnIndexForName:@"localMid"];
             int mediaIndex = [result columnIndexForName:@"media"];
             int deliveryStateIndex = [result columnIndexForName:@"dstate"];
             int flagsIndex = [result columnIndexForName:@"flags"];
             int indexSeqIn = [result columnIndexForName:@"seq_in"];
             int indexSeqOut = [result columnIndexForName:@"seq_out"];
             int indexContentProperties = [result columnIndexForName:@"content_properties"];
             
             firstLoop = false;
             
             bool anyMarked = false;
             bool anyFound = false;
             bool outgoingFound = false;
             
             TGConversation *conversation = [self loadConversationWithId:conversationId];
             
             while ([result next])
             {
                 TGMessage *message = loadMessageFromQueryResult(result, conversationId, midIndex, messageIndex, mediaIndex, fromIdIndex, toIdIndex, outgoingIndex, unreadIndex, deliveryStateIndex, dateIndex, messageLifetimeIndex, flagsIndex, indexSeqIn, indexSeqOut, indexContentProperties);
                 
                 anyFound = true;
                 
                 if (message.outgoing && message.deliveryState == TGMessageDeliveryStateDelivered)
                 {
                     outgoingFound = true;
                     
                     if ([conversation isMessageUnread:message])
                     {
                         int mid = message.mid;
                         
                         if (midsString.length != 0)
                             [midsString appendString:@","];
                         [midsString appendFormat:@"%d", mid];
                         
                         anyMarked = true;
                         
                         [markedMids addObject:[[NSNumber alloc] initWithInt:mid]];
                         
                         bool hasSecretMedia = false;
                         if (message.messageLifetime != 0)
                         {
                             for (TGMediaAttachment *attachment in [TGMessage parseMediaAttachments:[result dataForColumnIndex:mediaIndex]])
                             {
                                 switch (attachment.type)
                                 {
                                     case TGImageMediaAttachmentType:
                                     case TGVideoMediaAttachmentType:
                                     case TGAudioMediaAttachmentType:
                                     {
                                         hasSecretMedia = true;
                                         break;
                                     }
                                     case TGDocumentMediaAttachmentType:
                                     {
                                         for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
                                             if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
                                                 hasSecretMedia = ((TGDocumentAttributeAudio *)attribute).isVoice;
                                             }
                                         }
                                         break;
                                     }
                                     default:
                                         break;
                                 }
                                 
                                 if (hasSecretMedia)
                                     break;
                             }
                             
                             if (hasSecretMedia)
                                 hasSecretMedia = message.messageLifetime > 0 && message.messageLifetime <= 60 && message.layer >= 17;
                         }
                         
                         if (message.messageLifetime != 0 && !hasSecretMedia)
                             midsWithLifetime.push_back(std::pair<int, int>(mid, message.messageLifetime));
                     }
                 }
                 
                 int date = [result intForColumnIndex:dateIndex];
                 
                 if (date < startingDate)
                 {
                     startingDate = date;
                     startingDateLimit = 0;
                 }
                 
                 startingDateLimit++;
             }
             
             if (midsString.length != 0)
             {
                 //TGLog(@"%@", midsString);
                 [_database setSoftShouldCacheStatements:false];
                 [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET unread=NULL WHERE mid IN (%@)", _messagesTableName, midsString]];
                 [_database setSoftShouldCacheStatements:true];
             }
             
             if (!anyFound || (outgoingFound && !anyMarked))
                 break;
         }
         
         if (markedMids.count != 0)
             [self _scheduleSelfDestruct:&midsWithLifetime referenceDate:referenceDate];
         
         [self actualizeConversation:conversationId dispatch:true];
     } synchronous:false];
}*/

/*- (void)addMessagesToConversation:(NSArray *)argMessages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread
{
    [self addMessagesToConversation:argMessages conversationId:conversationId updateConversation:conversation dispatch:dispatch countUnread:countUnread updateDates:true];
}

- (void)addMessagesToConversation:(NSArray *)argMessages conversationId:(int64_t)conversationId updateConversation:(TGConversation *)conversation dispatch:(bool)dispatch countUnread:(bool)countUnread updateDates:(bool)updateDates
{
    int localIdCount = 0;
    for (TGMessage *message in argMessages)
    {
        if (message.mid == 0 || message.mid == INT_MIN)
        {
            localIdCount++;
        }
    }
    if (localIdCount != 0)
    {
        NSArray *localMids = [self generateLocalMids:localIdCount];
        int localMidIndex = 0;
        for (TGMessage *message in argMessages)
        {
            if (message.mid == 0)
            {
                message.mid = [[localMids objectAtIndex:localMidIndex++] intValue];
            }
            else if (message.mid == INT_MIN)
            {
                message.mid = INT_MIN + 1 + ([[localMids objectAtIndex:localMidIndex++] intValue] - 800000000);
            }
        }
    }
    
    if (TGPeerIdIsChannel(conversationId)) {
        if (conversation != nil) {
            [self updateChannels:@[conversation]];
        }
        return;
    }
    
    [self dispatchOnDatabaseThread:^
     {
         NSArray *messages = argMessages;
         
         std::map<int64_t, int> randomIdToPosition;
         
         int positionIndex = -1;
         for (TGMessage *message in argMessages)
         {
             positionIndex++;
             if (message.randomId != 0)
                 randomIdToPosition.insert(std::pair<int64_t, int>(message.randomId, positionIndex));
         }
         
         if (!randomIdToPosition.empty())
         {
             NSMutableArray *modifiedMessages = [[NSMutableArray alloc] initWithArray:argMessages];
             messages = modifiedMessages;
             
             [_database setSoftShouldCacheStatements:false];
             NSMutableString *rangeString = [[NSMutableString alloc] init];
             
             NSMutableIndexSet *removeIndices = [[NSMutableIndexSet alloc] init];
             
             const int batchSize = 256;
             for (auto it = randomIdToPosition.begin(); it != randomIdToPosition.end(); )
             {
                 [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
                 bool first = true;
                 
                 for (int i = 0; i < batchSize && it != randomIdToPosition.end(); i++, it++)
                 {
                     if (first)
                     {
                         first = false;
                         [rangeString appendFormat:@"%lld", it->first];
                     }
                     else
                         [rangeString appendFormat:@",%lld", it->first];
                 }
                 
                 FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT random_id FROM %@ WHERE random_id IN (%@)", _randomIdsTableName, rangeString]];
                 int randomIdIndex = [result columnIndexForName:@"random_id"];
                 while ([result next])
                 {
                     int64_t randomId = [result longLongIntForColumnIndex:randomIdIndex];
                     
                     auto indexIt = randomIdToPosition.find(randomId);
                     if (indexIt != randomIdToPosition.end())
                         [removeIndices addIndex:indexIt->second];
                 }
             }
             [_database setSoftShouldCacheStatements:true];
             
             if (removeIndices.count != 0)
             {
                 TGLog(@"(not adding %d duplicate messages by random id)", removeIndices.count);
                 [modifiedMessages removeObjectsAtIndexes:removeIndices];
             }
         }
         
         int legacyMessageLifetime = 0;
         if (conversationId <= INT_MIN)
             legacyMessageLifetime = [self messageLifetimeForPeerId:conversationId];
         
         NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, localMid, message, media, from_id, to_id, outgoing, unread, dstate, date, flags, seq_in, seq_out, content_properties) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _messagesTableName];
         
         NSString *mediaInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, date, from_id, type, media) VALUES (?, ?, ?, ?, ?, ?)", _conversationMediaTableName];
         
         NSString *outboxInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, dstate, local_media_id) VALUES (?, ?, ?, ?)", _outgoingMessagesTableName];
         
         NSString *randomIdInsertFormat = [[NSString alloc] initWithFormat:@"INSERT OR IGNORE INTO %@ (random_id, mid) VALUES (?, ?)", _randomIdsTableName];
         
         TGMessage *lastMesage = nil;
         TGMessage *lastIncomingMesage = nil;
         TGMessage *lastIncomingMesageWithMarkup = nil;
         struct { int32_t messageId, botId; } lastKickedBot = {0, 0};
         
         std::map<int32_t, bool> userIsBot;
         
         int unreadCount = 0;
         int localUnreadCount = 0;
         
         TGConversation *currentConversation = [self loadConversationWithId:conversationId];
         
         int messagesCount = (int)messages.count;
         NSMutableString *rangeString = [[NSMutableString alloc] init];
         [_database setSoftShouldCacheStatements:false];
         for (int i = 0; i < messagesCount; )
         {
             if (rangeString.length != 0)
                 [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
             
             int maybeUnreadCount = 0;
             int maybeLocalUnreadCount = 0;
             
             std::vector<int> checkingMids;
             
             bool first = true;
             for (int lastI = i + 64; i < messagesCount && i < lastI; i++)
             {
                 TGMessage *message = [messages objectAtIndex:i];
                 int mid = message.mid;
                 if (message.outgoing || ![currentConversation isMessageUnread:message])
                     continue;
                 
                 if (first)
                     first = false;
                 else
                     [rangeString appendString:@","];
                 
                 [rangeString appendFormat:@"%d", mid];
                 checkingMids.push_back(mid);
                 
                 if (mid >= TGMessageLocalMidBaseline)
                     maybeLocalUnreadCount++;
                 else
                     maybeUnreadCount++;
             }
             
             if (maybeUnreadCount != 0 || maybeLocalUnreadCount != 0)
             {
                 if (maybeLocalUnreadCount != 0)
                 {
                     FMResultSet *alreadyThereResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid FROM %@ WHERE mid IN (%@)", _messagesTableName, rangeString]];
                     int midIndex = [alreadyThereResult columnIndexForName:@"mid"];
                     
                     std::set<int> alreadyThereSet;
                     
                     while ([alreadyThereResult next])
                     {
                         int mid = [alreadyThereResult intForColumnIndex:midIndex];
                         alreadyThereSet.insert(mid);
                     }
                     
                     if (alreadyThereSet.empty())
                     {
                         unreadCount += maybeUnreadCount;
                         localUnreadCount += maybeLocalUnreadCount;
                     }
                     else
                     {
                         for (auto it = checkingMids.begin(); it != checkingMids.end(); it++)
                         {
                             if (*it < TGMessageLocalMidBaseline)
                             {
                                 if (alreadyThereSet.find(*it) == alreadyThereSet.end())
                                     unreadCount++;
                             }
                             else
                             {
                                 if (alreadyThereSet.find(*it) == alreadyThereSet.end())
                                     localUnreadCount++;
                             }
                         }
                     }
                 }
                 else
                 {
                     FMResultSet *countResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE mid IN (%@)", _messagesTableName, rangeString]];
                     if ([countResult next])
                     {
                         int alreadyThere = [countResult intForColumn:@"COUNT(*)"];
                         maybeUnreadCount -= alreadyThere;
                     }
                     
                     unreadCount += maybeUnreadCount;
                 }
             }
         }
         [_database setSoftShouldCacheStatements:true];
         
         [_database beginTransaction];
         for (TGMessage *message in messages)
         {
             if (message.mid == 0)
             {
                 TGLog(@"***** Error: message mid = 0");
                 continue;
             }
             
             if (!message.outgoing)
             {
                 bool isBot = false;
                 if (conversationId > INT_MIN && conversationId < 0)
                 {
                     auto isBotIt = userIsBot.find((int32_t)message.fromUid);
                     if (isBotIt == userIsBot.end())
                     {
                         TGUser *user = [self loadUser:(int)message.fromUid];
                         isBot = user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot;
                         userIsBot.insert(std::pair<int32_t, bool>((int32_t)message.fromUid, isBot));
                     }
                     else
                         isBot = isBotIt->second;
                 }
                 
                 if (isBot && ((message.replyMarkup != nil && !message.replyMarkup.isInline) || message.hideReplyMarkup))
                 {
                     if (lastIncomingMesageWithMarkup == nil || message.mid > lastIncomingMesageWithMarkup.mid)
                         lastIncomingMesageWithMarkup = message;
                 }
             }
             
             if (message.actionInfo != nil)
             {
                 if (message.actionInfo.actionType == TGMessageActionChatDeleteMember)
                 {
                     int32_t deletedUserId = [message.actionInfo.actionData[@"uid"] intValue];
                     bool isBot = false;
                     if (conversationId > INT_MIN && conversationId < 0)
                     {
                         auto isBotIt = userIsBot.find((int32_t)deletedUserId);
                         if (isBotIt == userIsBot.end())
                         {
                             TGUser *user = [self loadUser:(int)deletedUserId];
                             isBot = user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot;
                             userIsBot.insert(std::pair<int32_t, bool>((int32_t)deletedUserId, isBot));
                         }
                         else
                             isBot = isBotIt->second;
                     }
                     
                     if (isBot && (lastKickedBot.messageId == 0 || message.mid > lastKickedBot.messageId))
                     {
                         lastKickedBot.messageId = message.mid;
                         lastKickedBot.botId = deletedUserId;
                     }
                 }
             }
             
             if (lastMesage == nil || message.date > lastMesage.date || (message.date == lastMesage.date && message.mid > lastMesage.mid))
             {
                 lastMesage = message;
             }
             
             if (!message.outgoing)
             {
                 if (lastIncomingMesage == nil || message.mid > lastIncomingMesage.mid)
                     lastIncomingMesage = message;
                 
                 if (((message.replyMarkup != nil && !message.replyMarkup.isInline) || message.hideReplyMarkup) && (lastIncomingMesageWithMarkup == nil || message.mid > lastIncomingMesageWithMarkup.mid))
                     lastIncomingMesageWithMarkup = message;
             }
             
             NSData *mediaData = nil;
             int mediaType = 0;
             if (message.mediaAttachments != nil && message.mediaAttachments.count != 0)
             {
                 for (TGMediaAttachment *attachment in message.mediaAttachments)
                 {
                     if (attachment.type == TGImageMediaAttachmentType)
                     {
                         mediaData = [TGMessage serializeAttachment:attachment];
                         mediaType = 0;
                     }
                     else if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         mediaData = [TGMessage serializeAttachment:attachment];
                         mediaType = 1;
                         
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.videoId != 0)
                             addVideoMid(self, 0, message.mid, videoAttachment.videoId, false);
                         else if (videoAttachment.localVideoId != 0)
                             addVideoMid(self, 0, message.mid, videoAttachment.localVideoId, true);
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.documentId != 0)
                             addFileMid(self, 0, message.mid, TGDocumentFileType, documentAttachment.documentId);
                         else if (documentAttachment.localDocumentId != 0)
                             addFileMid(self, 0, message.mid, TGLocalDocumentFileType, documentAttachment.localDocumentId);
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.audioId != 0)
                             addFileMid(self, 0, message.mid, TGAudioFileType, audioAttachment.audioId);
                         else if (audioAttachment.localAudioId != 0)
                             addFileMid(self, 0, message.mid, TGLocalAudioFileType, audioAttachment.localAudioId);
                     }
                 }
             }
             
             int currentLifetime = 0;
             if (message.layer >= 17)
                 currentLifetime = message.messageLifetime;
             else if (message.messageLifetime != 0)
                 currentLifetime = (int)message.messageLifetime;
             else if (message.actionInfo.actionType != TGMessageActionEncryptedChatMessageLifetime)
                 currentLifetime = legacyMessageLifetime;
             
             [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:currentLifetime], message.text, [message serializeMediaAttachments:false], [[NSNumber alloc] initWithLongLong:message.fromUid], [[NSNumber alloc] initWithLongLong:message.toUid], [[NSNumber alloc] initWithInt:message.outgoing ? 1 : 0], [currentConversation isMessageUnread:message] ? [[NSNumber alloc] initWithLongLong:message.outgoing ? INT_MAX : conversationId] : nil, [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:(int)(message.date)], [[NSNumber alloc] initWithLongLong:message.flags], [[NSNumber alloc] initWithInt:message.seqIn], [[NSNumber alloc] initWithInt:message.seqOut], [message serializeContentProperties]];
             
             if (mediaData != nil && mediaData.length != 0)
                 [_database executeUpdate:mediaInsertQueryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:(int)message.date], [[NSNumber alloc] initWithInt:(int)message.fromUid], [[NSNumber alloc] initWithInt:mediaType], mediaData];
             
             if (message.local && message.deliveryState == TGMessageDeliveryStatePending)
             {
                 int localMediaId = 0;
                 
                 for (TGMediaAttachment *attachment in message.mediaAttachments)
                 {
                     if (attachment.type == (int)TGLocalMessageMetaMediaAttachmentType)
                     {
                         localMediaId = ((TGLocalMessageMetaMediaAttachment *)attachment).localMediaId;
                         break;
                     }
                 }
                 
                 [_database executeUpdate:outboxInsertQueryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:localMediaId]];
             }
             
             if (message.randomId != 0)
             {
                 [_database executeUpdate:randomIdInsertFormat, [[NSNumber alloc] initWithLongLong:message.randomId], [[NSNumber alloc] initWithInt:message.mid]];
             }
         }
         
         [self cacheMediaForPeerId:conversationId messages:messages];
         
         [_database commit];
         
         if (!countUnread)
         {
             unreadCount = 0;
             localUnreadCount = 0;
         }
         else if (conversationId < 0 && conversation == nil)
         {
             FMResultSet *result = [_database executeQuery:[[NSString alloc] initWithFormat:@"SELECT cid FROM %@ WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithLongLong:conversationId]];
             if (![result next])
             {
                 unreadCount = 0;
                 localUnreadCount = 0;
             }
         }
         
         if (dispatch)
         {
             if (lastMesage != nil)
             {
                 [self actualizeConversation:conversationId dispatch:true conversation:conversation forceUpdate:(unreadCount != 0 || localUnreadCount != 0) addUnreadCount:unreadCount addServiceUnreadCount:localUnreadCount keepDate:!updateDates];
             }
             else if (conversation != nil)
             {
                 [self actualizeConversation:conversationId dispatch:true conversation:conversation forceUpdate:true addUnreadCount:unreadCount addServiceUnreadCount:localUnreadCount keepDate:!updateDates];
             }
             
             if (unreadCount != 0)
             {
                 int newUnreadCount = [self databaseState].unreadCount + unreadCount;
                 if (newUnreadCount < 0)
                     TGLog(@"***** Warning: wrong unread_count");
                 [self setUnreadCount:MAX(newUnreadCount, 0)];
             }
         }
         
         if (conversationId > 0)
         {
             if (lastIncomingMesageWithMarkup != nil)
             {
                 TGUser *user = [self loadUser:(int)conversationId];
                 if (user.kind == TGUserKindBot || user.kind == TGUserKindSmartBot)
                 {
                     [self storeBotReplyMarkup:lastIncomingMesageWithMarkup.replyMarkup hideMarkupAuthorId:user.uid forPeerId:conversationId messageId:lastIncomingMesageWithMarkup.mid];
                 }
             }
         }
         else if (conversationId > INT_MIN)
         {
             if (lastKickedBot.messageId > lastIncomingMesageWithMarkup.mid)
             {
                 [self storeBotReplyMarkup:nil hideMarkupAuthorId:(int32_t)lastKickedBot.botId forPeerId:conversationId messageId:lastKickedBot.messageId];
             }
             else if (lastIncomingMesageWithMarkup != nil)
             {
                 [self storeBotReplyMarkup:lastIncomingMesageWithMarkup.replyMarkup hideMarkupAuthorId:(int32_t)lastIncomingMesageWithMarkup.fromUid forPeerId:conversationId messageId:lastIncomingMesageWithMarkup.mid];
             }
         }
         
         [self dispatchOnIndexThread:^
          {
              NSString *indexInsertQueryFormat = [NSString stringWithFormat:@"INSERT INTO %@ (docid, text) VALUES (?, ?)", _messageIndexTableName];
              
              [_indexDatabase beginTransaction];
              
              [_indexDatabase setSoftShouldCacheStatements:false];
              NSMutableString *midsString = [[NSMutableString alloc] init];
              for (TGMessage *message in messages)
              {
                  if (midsString.length != 0)
                      [midsString appendString:@","];
                  [midsString appendFormat:@"%d", (int)message.mid];
              }
              NSString *indexSelectQueryFormat = [NSString stringWithFormat:@"SELECT docid FROM %@ WHERE docid IN (%@)", _messageIndexTableName, midsString];
              FMResultSet *existingResult = [_indexDatabase executeQuery:indexSelectQueryFormat];
              int docidIndex = [existingResult columnIndexForName:@"docid"];
              std::set<int32_t> existingMids;
              
              while ([existingResult next])
              {
                  existingMids.insert([existingResult intForColumnIndex:docidIndex]);
              }
              [_indexDatabase setSoftShouldCacheStatements:true];
              
              for (TGMessage *message in messages)
              {
                  if (existingMids.find(message.mid) == existingMids.end())
                  {
                      NSString *text = nil;
                      for (id attachment in message.mediaAttachments)
                      {
                          if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]]) {
                              text = ((TGDocumentMediaAttachment *)attachment).fileName;
                              for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes) {
                                  if ([attribute isKindOfClass:[TGDocumentAttributeSticker class]] || [attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                                      text = nil;
                                  }
                              }
                          }
                          else if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                              text = ((TGImageMediaAttachment *)attachment).caption;
                          else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                              text = ((TGVideoMediaAttachment *)attachment).caption;
                      }
                      
                      if (text.length == 0)
                          text = message.text;
                      
                      if (text.length != 0)
                      {
                          text = [text stringByAppendingFormat:@" z0z9p%lld%s", (long long)ABS(conversationId), conversationId < 0 ? "c" : "p"];
                          
#if TARGET_IPHONE_SIMULATOR
                          TGLog(@"index: insert %@ with %@", @(message.mid), text);
#endif
                          [_indexDatabase executeUpdate:indexInsertQueryFormat, [[NSNumber alloc] initWithInt:message.mid], [text lowercaseString]];
                      }
                  }
              }
              [_indexDatabase commit];
          } synchronous:false];
     } synchronous:false];
}*/

/*- (void)updateMessage:(int)mid peerId:(int64_t)peerId flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags1 media:(NSArray *)media dispatch:(bool)dispatch {
    [self updateMessage:mid peerId:peerId flags:flags1 media:media text:nil messageFlags:nil dispatch:dispatch];
}

- (void)updateMessage:(int)mid peerId:(int64_t)peerId flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags1 media:(NSArray *)media text:(NSString *)text dispatch:(bool)dispatch {
    [self updateMessage:mid peerId:peerId flags:flags1 media:media text:text messageFlags:nil dispatch:dispatch];
}

- (void)updateMessageTextOrMedia:(int)mid peerId:(int64_t)peerId media:(NSArray *)media text:(NSString *)text messageFlags:(NSNumber *)messageFlags dispatch:(bool)dispatch {
    std::vector<TGDatabaseMessageFlagValue> flags;
    [self updateMessage:mid peerId:peerId flags:flags media:media text:text messageFlags:messageFlags dispatch:dispatch];
}

- (void)updateMessage:(int)mid peerId:(int64_t)peerId flags:(std::vector<TGDatabaseMessageFlagValue> const &)flags1 media:(NSArray *)media text:(NSString *)text messageFlags:(NSNumber *)messageFlags dispatch:(bool)dispatch
{
    std::vector<TGDatabaseMessageFlagValue> flags = flags1;
    [self dispatchOnDatabaseThread:^
     {
         if (TGPeerIdIsChannel(peerId)) {
             TGMessage *message = [[self _loadChannelMessage:peerId messageId:mid] copy];
             if (message != nil) {
                 NSArray *updatedMedia = media;
                 if (media == nil) {
                     updatedMedia = message.mediaAttachments;
                 }
                 
                 int32_t previousMid = message.mid;
                 TGMessageSortKey previousSortKey = message.sortKey;
                 TGMessageDeliveryState previousDeliveryState = message.deliveryState;
                 
                 for (std::vector<TGDatabaseMessageFlagValue>::const_iterator it = flags.begin(); it != flags.end(); it++)
                 {
                     switch (it->flag)
                     {
                         case TGDatabaseMessageFlagDeliveryState:
                             message.deliveryState = (TGMessageDeliveryState)it->value;
                             break;
                         case TGDatabaseMessageFlagMid:
                             message.mid = it->value;
                             break;
                         case TGDatabaseMessageFlagDate:
                             message.date = it->value;
                             break;
                         case TGDatabaseMessageFlagPts:
                             message.pts = it->value;
                             break;
                         default:
                             break;
                     }
                 }
                 
                 if (message.deliveryState != previousDeliveryState) {
                     if (message.deliveryState == TGMessageDeliveryStatePending) {
                         [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, mid) VALUES (?, ?)", _channelPendingMessagesTableName], @(message.cid), @(message.mid)];
                     } else if (previousDeliveryState == TGMessageDeliveryStatePending) {
                         [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelPendingMessagesTableName], @(message.cid), @(previousMid)];
                     }
                 } else if (previousDeliveryState == TGMessageDeliveryStatePending && previousDeliveryState != message.mid) {
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelPendingMessagesTableName], @(message.cid), @(previousMid)];
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"INSERT INTO %@ (cid, mid) VALUES (?, ?)", _channelPendingMessagesTableName], @(message.cid), @(message.mid)];
                 }
                 
                 int32_t updatedMid = message.mid;
                 
                 int64_t previousLocalImageId = 0;
                 int64_t previousRemoteImageId = 0;
                 
                 int64_t previousLocalVideoId = 0;
                 int64_t previousRemoteVideoId = 0;
                 
                 int64_t previousLocalDocumentId = 0;
                 int64_t previousRemoteDocumentId = 0;
                 
                 int64_t previousLocalAudioId = 0;
                 int64_t previousRemoteAudioId = 0;
                 
                 for (TGMediaAttachment *attachment in message.mediaAttachments)
                 {
                     if (attachment.type == TGImageMediaAttachmentType)
                     {
                         TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                         if (imageAttachment.imageId != 0)
                             previousRemoteImageId = imageAttachment.imageId;
                         else
                             previousLocalImageId = imageAttachment.localImageId;
                     }
                     else if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.localVideoId != 0)
                             previousLocalVideoId = videoAttachment.localVideoId;
                         else if (videoAttachment.videoId != 0)
                             previousRemoteVideoId = videoAttachment.videoId;
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.localDocumentId != 0)
                             previousLocalDocumentId = documentAttachment.localDocumentId;
                         else if (documentAttachment.documentId != 0)
                             previousRemoteDocumentId = documentAttachment.documentId;
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.localAudioId != 0)
                             previousLocalAudioId = audioAttachment.localAudioId;
                         else if (audioAttachment.audioId != 0)
                             previousRemoteAudioId = audioAttachment.audioId;
                     }
                 }
                 
                 int64_t currentLocalImageId = 0;
                 int64_t currentRemoteImageId = 0;
                 
                 int64_t currentLocalVideoId = 0;
                 int64_t currentRemoteVideoId = 0;
                 
                 int64_t currentLocalDocumentId = 0;
                 int64_t currentRemoteDocumentId = 0;
                 
                 int64_t currentLocalAudioId = 0;
                 int64_t currentRemoteAudioId = 0;
                 
                 for (TGMediaAttachment *attachment in updatedMedia)
                 {
                     if (attachment.type == TGImageMediaAttachmentType)
                     {
                         TGImageMediaAttachment *imageAttachment = (TGImageMediaAttachment *)attachment;
                         if (imageAttachment.imageId != 0)
                             currentRemoteImageId = imageAttachment.imageId;
                         else
                             currentLocalImageId = imageAttachment.localImageId;
                     }
                     else if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.localVideoId != 0)
                             currentLocalVideoId = videoAttachment.localVideoId;
                         else if (videoAttachment.videoId != 0)
                             currentRemoteVideoId = videoAttachment.videoId;
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.localDocumentId != 0)
                             currentLocalDocumentId = documentAttachment.localDocumentId;
                         else if (documentAttachment.documentId != 0)
                             currentRemoteDocumentId = documentAttachment.documentId;
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.localAudioId != 0)
                             currentLocalAudioId = audioAttachment.localAudioId;
                         else if (audioAttachment.audioId != 0)
                             currentRemoteAudioId = audioAttachment.audioId;
                     }
                 }
                 
                 if (previousMid != updatedMid) {
                     if (currentLocalImageId != 0)
                         addFileMid(self, peerId, updatedMid, TGLocalImageFileType, currentLocalImageId);
                     else if (currentRemoteImageId != 0)
                         addFileMid(self, peerId, updatedMid, TGImageFileType, currentRemoteImageId);
                     
                     if (currentLocalVideoId != 0)
                         addVideoMid(self, peerId, updatedMid, currentLocalVideoId, true);
                     else if (currentRemoteVideoId != 0)
                         addVideoMid(self, peerId, updatedMid, currentRemoteVideoId, false);
                     
                     if (currentLocalDocumentId != 0)
                         addFileMid(self, peerId, updatedMid, TGLocalDocumentFileType, currentLocalDocumentId);
                     else if (currentRemoteDocumentId != 0)
                         addFileMid(self, peerId, updatedMid, TGDocumentFileType, currentRemoteDocumentId);
                     
                     if (currentLocalAudioId != 0)
                         addFileMid(self, peerId, updatedMid, TGLocalAudioFileType, currentLocalAudioId);
                     else if (currentRemoteAudioId != 0)
                         addFileMid(self, peerId, updatedMid, TGAudioFileType, currentRemoteAudioId);
                     
                     if (previousRemoteImageId != 0) {
                         removeFileMid(self, peerId, previousMid, TGImageFileType, previousRemoteImageId);
                     } else if (previousLocalImageId != 0) {
                         removeFileMid(self, peerId, previousMid, TGLocalImageFileType, previousLocalImageId);
                     }
                     
                     if (previousLocalVideoId != 0)
                         removeVideoMid(self, peerId, previousMid, previousLocalVideoId, true);
                     else if (previousRemoteVideoId != 0)
                         removeVideoMid(self, peerId, previousMid, previousRemoteVideoId, false);
                     
                     if (previousLocalDocumentId != 0)
                         removeFileMid(self, peerId, previousMid, TGLocalDocumentFileType, previousLocalDocumentId);
                     else if (previousRemoteDocumentId != 0)
                         removeFileMid(self, peerId, previousMid, TGDocumentFileType, previousRemoteDocumentId);
                     
                     if (previousLocalAudioId != 0)
                         removeFileMid(self, peerId, previousMid, TGLocalAudioFileType, previousLocalAudioId);
                     else if (previousRemoteAudioId != 0)
                         removeFileMid(self, peerId, previousMid, TGAudioFileType, previousRemoteAudioId);
                 }
                 
                 message.sortKey = TGMessageSortKeyMake(peerId, TGMessageSortKeySpace(message.sortKey), (int32_t)message.date, message.mid);
                 message.mediaAttachments = updatedMedia;
                 if (text != nil) {
                     message.text = text;
                 }
                 if (messageFlags != nil) {
                     message.flags = [messageFlags longLongValue];
                 }
                 PSKeyValueEncoder *encoder = [[PSKeyValueEncoder alloc] init];
                 [message encodeWithKeyValueCoder:encoder];
                 
                 [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET mid=?, data=?, sort_key=?, transparent_sort_key=? WHERE cid=? AND mid=?", _channelMessagesTableName], @(message.mid), encoder.data, TGMessageSortKeyData(message.sortKey), TGMessageTransparentSortKeyData(message.transparentSortKey), @(peerId), @(mid)];
                 
                 if (previousMid != message.mid) {
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE cid=? AND mid=?", _channelMessageTagsTableName], @(peerId), @(previousMid)];
                     [self cacheMediaForPeerId:peerId messages:@[message]];
                 }
                 
                 [self updateChannelMessageSortKeyAndDispatch:peerId previousSortKey:previousSortKey updatedSortKey:message.sortKey updatedMessage:message];
                 
                 [self _updateChannelConversation:peerId];
             }
         } else {
             NSMutableArray *changedMessageIds = [[NSMutableArray alloc] init];
             
             FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE mid=? LIMIT 1", _messagesTableName], [[NSNumber alloc] initWithInt:mid]];
             if ([result next])
             {
                 int64_t isUnread = [result longLongIntForColumn:@"unread"];
                 int deliveryState = [result intForColumn:@"dstate"];
                 int date = [result intForColumn:@"date"];
                 bool wasPending = deliveryState == TGMessageDeliveryStatePending || deliveryState == TGMessageDeliveryStateFailed;
                 bool wasDelivered = deliveryState == TGMessageDeliveryStateDelivered;
                 bool wasFailed = deliveryState == TGMessageDeliveryStateFailed;
                 int newMid = mid;
                 int newDate = date;
                 int64_t conversationId = [result longLongIntForColumn:@"cid"];
                 bool outgoing = [result intForColumn:@"outgoing"];
                 
                 bool changed = false;
                 
                 if (messageFlags != nil) {
                     changed = true;
                 }
                 
                 int64_t previousLocalVideoId = 0;
                 int64_t previousRemoteVideoId = 0;
                 
                 int64_t previousLocalDocumentId = 0;
                 int64_t previousRemoteDocumentId = 0;
                 
                 int64_t previousLocalAudioId = 0;
                 int64_t previousRemoteAudioId = 0;
                 
                 NSArray *mediaAttachments = [TGMessage parseMediaAttachments:[result dataForColumn:@"media"]];
                 NSArray *updatedMedia = media;
                 if (media == nil) {
                     updatedMedia = mediaAttachments;
                 }
                 
                 for (TGMediaAttachment *attachment in mediaAttachments)
                 {
                     if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.localVideoId != 0)
                             previousLocalVideoId = videoAttachment.localVideoId;
                         else if (videoAttachment.videoId != 0)
                             previousRemoteVideoId = videoAttachment.videoId;
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.localDocumentId != 0)
                             previousLocalDocumentId = documentAttachment.localDocumentId;
                         else if (documentAttachment.documentId != 0)
                             previousRemoteDocumentId = documentAttachment.documentId;
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.localAudioId != 0)
                             previousLocalAudioId = audioAttachment.localAudioId;
                         else if (audioAttachment.audioId != 0)
                             previousRemoteAudioId = audioAttachment.audioId;
                     }
                 }
                 
                 for (TGMediaAttachment *attachment in media)
                 {
                     if (attachment.type == TGVideoMediaAttachmentType)
                     {
                         TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                         if (videoAttachment.localVideoId != 0)
                             previousLocalVideoId = videoAttachment.localVideoId;
                         else if (videoAttachment.videoId != 0)
                             previousRemoteVideoId = videoAttachment.videoId;
                     }
                     else if (attachment.type == TGDocumentMediaAttachmentType)
                     {
                         TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                         if (documentAttachment.localDocumentId != 0)
                             previousLocalDocumentId = documentAttachment.localDocumentId;
                         else if (documentAttachment.documentId != 0)
                             previousRemoteDocumentId = documentAttachment.documentId;
                     }
                     else if (attachment.type == TGAudioMediaAttachmentType)
                     {
                         TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                         if (audioAttachment.localAudioId != 0)
                             previousLocalAudioId = audioAttachment.localAudioId;
                         else if (audioAttachment.audioId != 0)
                             previousRemoteAudioId = audioAttachment.audioId;
                     }
                 }
                 
                 for (std::vector<TGDatabaseMessageFlagValue>::const_iterator it = flags.begin(); it != flags.end(); it++)
                 {
                     switch (it->flag)
                     {
                         case TGDatabaseMessageFlagDeliveryState:
                             deliveryState = it->value;
                             changed = true;
                             break;
                         case TGDatabaseMessageFlagMid:
                             newMid = it->value;
                             changed = true;
                             break;
                         case TGDatabaseMessageFlagDate:
                             newDate = it->value;
                             changed = true;
                             break;
                         default:
                             break;
                     }
                 }
                 
                 if (media != nil && mid != newMid)
                 {
                     int64_t currentLocalVideoId = 0;
                     int64_t currentRemoteVideoId = 0;
                     
                     int64_t currentLocalDocumentId = 0;
                     int64_t currentRemoteDocumentId = 0;
                     
                     int64_t currentLocalAudioId = 0;
                     int64_t currentRemoteAudioId = 0;
                     
                     for (TGMediaAttachment *attachment in media)
                     {
                         if (attachment.type == TGVideoMediaAttachmentType)
                         {
                             TGVideoMediaAttachment *videoAttachment = (TGVideoMediaAttachment *)attachment;
                             if (videoAttachment.localVideoId != 0)
                                 currentLocalVideoId = videoAttachment.localVideoId;
                             else if (videoAttachment.videoId != 0)
                                 currentRemoteVideoId = videoAttachment.videoId;
                         }
                         else if (attachment.type == TGDocumentMediaAttachmentType)
                         {
                             TGDocumentMediaAttachment *documentAttachment = (TGDocumentMediaAttachment *)attachment;
                             if (documentAttachment.localDocumentId != 0)
                                 currentLocalDocumentId = documentAttachment.localDocumentId;
                             else if (documentAttachment.documentId != 0)
                                 currentRemoteDocumentId = documentAttachment.documentId;
                         }
                         else if (attachment.type == TGAudioMediaAttachmentType)
                         {
                             TGAudioMediaAttachment *audioAttachment = (TGAudioMediaAttachment *)attachment;
                             if (audioAttachment.localAudioId != 0)
                                 currentLocalAudioId = audioAttachment.localAudioId;
                             else if (audioAttachment.audioId != 0)
                                 currentRemoteAudioId = audioAttachment.audioId;
                         }
                     }
                     
                     if (currentLocalVideoId != 0)
                         addVideoMid(self, 0, newMid, currentLocalVideoId, true);
                     else if (currentRemoteVideoId != 0)
                         addVideoMid(self, 0, newMid, currentRemoteVideoId, false);
                     
                     if (currentLocalDocumentId != 0)
                         addFileMid(self, 0, newMid, TGLocalDocumentFileType, currentLocalDocumentId);
                     else if (currentRemoteDocumentId != 0)
                         addFileMid(self, 0, newMid, TGDocumentFileType, currentRemoteDocumentId);
                     
                     if (currentLocalAudioId != 0)
                         addFileMid(self, 0, newMid, TGLocalAudioFileType, currentLocalAudioId);
                     else if (currentRemoteAudioId != 0)
                         addFileMid(self, 0, newMid, TGAudioFileType, currentRemoteAudioId);
                     
                     if (previousLocalVideoId != 0)
                         removeVideoMid(self, 0, mid, previousLocalVideoId, true);
                     else if (previousRemoteVideoId != 0)
                         removeVideoMid(self, 0, mid, previousRemoteVideoId, false);
                     
                     if (previousLocalDocumentId != 0)
                         removeFileMid(self, 0, mid, TGLocalDocumentFileType, previousLocalDocumentId);
                     else if (previousRemoteDocumentId != 0)
                         removeFileMid(self, 0, mid, TGDocumentFileType, previousRemoteDocumentId);
                     
                     if (previousLocalAudioId != 0)
                         removeFileMid(self, 0, mid, TGLocalAudioFileType, previousLocalAudioId);
                     else if (previousRemoteAudioId != 0)
                         removeFileMid(self, 0, mid, TGAudioFileType, previousRemoteAudioId);
                 }
                 
                 if (changed)
                 {
                     if (wasPending && deliveryState == TGMessageDeliveryStateDelivered)
                         [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE mid=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithInt:mid]];
                     else if (wasDelivered && deliveryState == TGMessageDeliveryStateFailed)
                     {
                         NSString *outboxInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, dstate, local_media_id) VALUES (?, ?, ?, ?)", _outgoingMessagesTableName];
                         [_database executeUpdate:outboxInsertQueryFormat, [[NSNumber alloc] initWithInt:newMid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:0]];
                     }
                     else if (deliveryState == TGMessageDeliveryStatePending && wasFailed)
                     {
                         NSString *outboxInsertQueryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, dstate, local_media_id) VALUES (?, ?, ?, ?)", _outgoingMessagesTableName];
                         [_database executeUpdate:outboxInsertQueryFormat, [[NSNumber alloc] initWithInt:newMid], [[NSNumber alloc] initWithLongLong:conversationId], [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:0]];
                     }
                     else
                     {
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET dstate=? WHERE mid=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:mid]];
                     }
                     
                     if (newMid != mid)
                     {
                         [changedMessageIds addObject:[[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:mid], [[NSNumber alloc] initWithInt:newMid], nil]];
                         
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mid=?, unread=?, dstate=?, date=? WHERE mid=?", _messagesTableName], [[NSNumber alloc] initWithInt:newMid], isUnread ? [[NSNumber alloc] initWithLongLong:outgoing ? INT_MAX : conversationId] : nil, [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:newDate], [[NSNumber alloc] initWithInt:mid]];
                         
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET mid=?, date=? WHERE mid=?", _conversationMediaTableName], [[NSNumber alloc] initWithInt:newMid], [[NSNumber alloc] initWithInt:newDate], [[NSNumber alloc] initWithInt:mid]];
                     }
                     else
                     {
                         [_database executeUpdate:[NSString stringWithFormat:@"UPDATE OR IGNORE %@ SET unread=?, dstate=?, date=? WHERE mid=?", _messagesTableName], isUnread ? [[NSNumber alloc] initWithLongLong:outgoing ? INT_MAX : conversationId] : nil, [[NSNumber alloc] initWithInt:deliveryState], [[NSNumber alloc] initWithInt:newDate], [[NSNumber alloc] initWithInt:mid]];
                     }
                 }
                 
                 if (text != nil) {
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET message=? WHERE mid=?", _messagesTableName], text, @(newMid)];
                 }
                 
                 if (updatedMedia != nil)
                 {
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET media=? WHERE mid=?", _messagesTableName], [TGMessage serializeMediaAttachments:true attachments:updatedMedia], @(newMid)];
                     [_database executeUpdate:[[NSString alloc] initWithFormat:@"UPDATE %@ SET media=? WHERE mid=?", _conversationMediaTableName], [TGMessage serializeMediaAttachments:true attachments:updatedMedia], @(newMid)];
                 }
                 
                 if (messageFlags != nil) {
                     [_database executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET flags=? WHERE mid=?", _messagesTableName], messageFlags, @(newMid)];
                 }
                 
                 TGMessage *newMessage = [self loadMessageWithMid:newMid peerId:peerId];
                 
                 [self removeMediaFromCacheForPeerId:conversationId messageIds:@[@(mid)]];
                 if (newMessage != nil)
                     [self cacheMediaForPeerId:conversationId messages:@[newMessage]];
                 
                 [self actualizeConversation:conversationId dispatch:dispatch];
             }
             else
             {
                 TGLog(@"***** Warning: message %d not found", mid);
             }
             
             if (changedMessageIds.count != 0)
             {
                 [self dispatchOnIndexThread:^
                  {
                      NSString *indexInsertFormat = [NSString stringWithFormat:@"UPDATE %@ SET docid=? WHERE docid=?", _messageIndexTableName];
                      
                      [_indexDatabase beginTransaction];
                      for (NSArray *mids in changedMessageIds)
                      {
#if TARGET_IPHONE_SIMULATOR
                          TGLog(@"index: moving %@ to %@", mids[0], mids[1]);
#endif
                          [_indexDatabase executeUpdate:indexInsertFormat, [mids objectAtIndex:1], [mids objectAtIndex:0]];
                      }
                      [_indexDatabase commit];
                  } synchronous:false];
             }
         }
     } synchronous:false];
}

- (void)updateMessage:(int32_t)__unused mid peerId:(int64_t)peerId withMessage:(TGMessage *)message
{
    [self dispatchOnDatabaseThread:^
     {
         NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, localMid, message, media, from_id, to_id, outgoing, unread, dstate, date, flags, seq_in, seq_out, content_properties) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _messagesTableName];
         
         TGConversation *conversation = [self loadConversationWithId:peerId];
         
         [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:peerId], [[NSNumber alloc] initWithInt:0], message.text, [message serializeMediaAttachments:false], [[NSNumber alloc] initWithLongLong:message.fromUid], [[NSNumber alloc] initWithLongLong:message.toUid], [[NSNumber alloc] initWithInt:message.outgoing ? 1 : 0], [conversation isMessageUnread:message] ? [[NSNumber alloc] initWithLongLong:message.outgoing ? INT_MAX : peerId] : nil, [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:(int)(message.date)], [[NSNumber alloc] initWithLongLong:message.flags], [[NSNumber alloc] initWithInt:message.seqIn], [[NSNumber alloc] initWithInt:message.seqOut], [message serializeContentProperties]];
     } synchronous:false];
}

- (void)updateMessages:(NSArray *)messages
{
    [self dispatchOnDatabaseThread:^
     {
         NSString *queryFormat = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (mid, cid, localMid, message, media, from_id, to_id, outgoing, unread, dstate, date, flags, seq_in, seq_out, content_properties) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", _messagesTableName];
         
         [_database beginTransaction];
         
         NSMutableSet *conversationIds = [[NSMutableSet alloc] init];
         for (TGMessage *message in messages) {
             [conversationIds addObject:@(message.cid)];
         }
         
         NSMutableDictionary<NSNumber *, TGConversation *> *conversations = [[NSMutableDictionary alloc] init];
         for (NSNumber *peerId in conversationIds) {
             TGConversation *conversation = [self loadConversationWithId:[peerId longLongValue]];
             if (conversationIds != nil) {
                 conversations[peerId] = conversation;
             }
         }
         
         for (TGMessage *message in messages)
         {
             [_database executeUpdate:queryFormat, [[NSNumber alloc] initWithInt:message.mid], [[NSNumber alloc] initWithLongLong:message.cid], [[NSNumber alloc] initWithInt:0], message.text, [message serializeMediaAttachments:false], [[NSNumber alloc] initWithLongLong:message.fromUid], [[NSNumber alloc] initWithLongLong:message.toUid], [[NSNumber alloc] initWithInt:message.outgoing ? 1 : 0], [conversations[@(message.cid)] isMessageUnread:message] ? [[NSNumber alloc] initWithLongLong:message.outgoing ? INT_MAX : message.cid] : nil, [[NSNumber alloc] initWithInt:message.deliveryState], [[NSNumber alloc] initWithInt:(int)(message.date)], [[NSNumber alloc] initWithLongLong:message.flags], [[NSNumber alloc] initWithInt:message.seqIn], [[NSNumber alloc] initWithInt:message.seqOut], [message serializeContentProperties]];
         }
         [_database commit];
     } synchronous:false];
}*/

/*- (void)deleteConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue
{
    [self clearConversation:conversationId populateActionQueue:populateActionQueue clearOnly:false];
}

- (void)clearConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue
{
    [self clearConversation:conversationId populateActionQueue:populateActionQueue clearOnly:true];
}

- (void)clearConversation:(int64_t)conversationId populateActionQueue:(bool)populateActionQueue clearOnly:(bool)clearOnly
{
    [self dispatchOnDatabaseThread:^
     {
         if (!clearOnly) {
             _spotlightIndexPipe.sink([self deleteSpotlightPeerIds:@[@(conversationId)]]);
         }
         
         NSMutableSet *cleanedUpMessageIds = [[NSMutableSet alloc] init];
         
         FMResultSet *result = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid, media FROM %@ WHERE cid=? AND media NOT NULL", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
         int midIndex = [result columnIndexForName:@"mid"];
         int mediaIndex = [result columnIndexForName:@"media"];
         while ([result next])
         {
             int mid = [result intForColumnIndex:midIndex];
             NSData *media = [result dataForColumnIndex:mediaIndex];
             if (media != nil && media.length != 0)
             {
                 [cleanedUpMessageIds addObject:@(mid)];
                 cleanupMessage(self, mid, [TGMessage parseMediaAttachments:media], _messageCleanupBlock);
             }
         }
         
         result = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid, media FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
         midIndex = [result columnIndexForName:@"mid"];
         mediaIndex = [result columnIndexForName:@"media"];
         while ([result next])
         {
             int mid = [result intForColumnIndex:midIndex];
             NSNumber *nMid = @(mid);
             if (![cleanedUpMessageIds containsObject:nMid])
             {
                 [cleanedUpMessageIds addObject:nMid];
                 NSData *media = [result dataForColumnIndex:mediaIndex];
                 if (media != nil && media.length != 0)
                 {
                     cleanupMessage(self, mid, [TGMessage parseMediaAttachments:media], _messageCleanupBlock);
                 }
             }
         }
         
         [self cachedMediaForPeerId:conversationId itemType:TGSharedMediaCacheItemTypePhotoVideoFile limit:0 important:false completion:^(NSArray *cachedMediaMessages, bool)
          {
              for (TGMessage *message in cachedMediaMessages)
              {
                  NSNumber *nMid = @(message.mid);
                  if (![cleanedUpMessageIds containsObject:nMid])
                  {
                      cleanupMessage(self, message.mid, message.mediaAttachments, _messageCleanupBlock);
                  }
              }
          } buildIndex:false isCancelled:nil];
         
         [self removeMediaFromCacheForPeerId:conversationId];
         
         NSMutableArray *midsInConversation = [[NSMutableArray alloc] init];
         FMResultSet *midsResult = [_database executeQuery:[NSString stringWithFormat:@"SELECT mid FROM %@ WHERE cid=?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
         int midsResultMidIndex = [midsResult columnIndexForName:@"mid"];
         while ([midsResult next])
         {
             [midsInConversation addObject:[[NSNumber alloc] initWithInt:[midsResult intForColumnIndex:midsResultMidIndex]]];
         }
         
         [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", _messagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
         [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", _conversationMediaTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
         [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", _outgoingMessagesTableName], [[NSNumber alloc] initWithLongLong:conversationId]];
         
         TGConversation *conversation = [self loadConversationWithId:conversationId];
         if (conversation != nil)
         {
             int previousConversationUnreadCount = 0;
             
             if (conversation.unreadCount != 0)
             {
                 previousConversationUnreadCount = conversation.unreadCount;
                 int unreadCount = [self databaseState].unreadCount - conversation.unreadCount;
                 if (unreadCount < 0)
                     TGLog(@"***** Warning: wrong unread_count");
                 [self setUnreadCount:MAX(unreadCount, 0)];
             }
             
             if (clearOnly)
             {
                 [self loadConversationWithId:conversationId];
                 [self actualizeConversation:conversationId dispatch:true];
                 
                 if (populateActionQueue)
                 {
                     if (conversationId <= INT_MIN)
                     {
                         NSMutableArray *actions = [[NSMutableArray alloc] init];
                         
                         TGDatabaseAction action = { .type = TGDatabaseActionClearSecretConversation, .subject = conversationId, .arg0 = 0, .arg1 = 0 };
                         [actions addObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]];
                         
                         [self storeQueuedActions:actions];
                     }
                     else
                     {
                         TGDatabaseAction action = { .type = TGDatabaseActionClearConversation, .subject = conversationId, .arg0 = 0, .arg1 = previousConversationUnreadCount };
                         [self storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                     }
                 }
             }
             else
             {
                 [_database executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE cid=?", [self _listTableNameForConversationId:conversationId]], [[NSNumber alloc] initWithLongLong:conversationId]];
                 
                 [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerIncomingTableName], @(conversationId)];
                 [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerIncomingEncryptedTableName], @(conversationId)];
                 [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerOutgoingTableName], @(conversationId)];
                 [_database executeUpdate:[[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE peer_id=?", _secretPeerOutgoingResendTableName], @(conversationId)];
                 
                 TG_SYNCHRONIZED_BEGIN(_cachedConversations);
                 _cachedConversations.erase(conversationId);
                 TG_SYNCHRONIZED_END(_cachedConversations);
                 
                 if (populateActionQueue)
                 {
                     TGDatabaseAction action = { .type = TGDatabaseActionDeleteConversation, .subject = conversationId, .arg0 = 0, .arg1 = previousConversationUnreadCount };
                     [self storeQueuedActions:[NSArray arrayWithObject:[[NSValue alloc] initWithBytes:&action objCType:@encode(TGDatabaseAction)]]];
                 }
             }
         }
         
         if (!clearOnly)
         {
             if (conversationId <= INT_MIN)
             {
                 [self setConversationCustomProperty:conversationId name:murMurHash32(@"key") value:nil];
             }
         }
         
         [self dispatchOnIndexThread:^
          {
              int midsCount = (int)midsInConversation.count;
              
              [_indexDatabase setSoftShouldCacheStatements:false];
              [_indexDatabase beginTransaction];
              NSMutableString *rangeString = [[NSMutableString alloc] init];
              for (int i = 0; i < midsCount; i++)
              {
                  if (rangeString.length != 0)
                      [rangeString deleteCharactersInRange:NSMakeRange(0, rangeString.length)];
                  
                  bool first = true;
                  int count = 0;
                  for (; count < 20 && i < midsCount; i++, count++)
                  {
                      if (first)
                          first = false;
                      else
                          [rangeString appendString:@","];
                      
                      [rangeString appendFormat:@"%d", [[midsInConversation objectAtIndex:i] intValue]];
                  }
                  
                  NSString *deleteQueryFormat = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE docid IN (%@)", _messageIndexTableName, rangeString];
#if TARGET_IPHONE_SIMULATOR
                  TGLog(@"index: delete %@", rangeString);
#endif
                  [_indexDatabase executeUpdate:deleteQueryFormat];
              }
              [_indexDatabase commit];
              [_indexDatabase setSoftShouldCacheStatements:true];
          } synchronous:false];
     } synchronous:false];
}*/

@end
