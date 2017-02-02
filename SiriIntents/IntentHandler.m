#import "IntentHandler.h"

#import <LegacyDatabase/LegacyDatabase.h>
#import <Contacts/Contacts.h>

static INPerson *personWithLegacyUser(TGLegacyUser *user) {
    NSString *displayName = nil;
    if (user.firstName.length != 0 && user.lastName.length != 0) {
        displayName = [[NSString alloc] initWithFormat:@"%@ %@", user.firstName, user.lastName];
    } else if (user.firstName.length != 0) {
        displayName = user.firstName;
    } else if (user.lastName.length != 0) {
        displayName = user.lastName;
    } else {
        displayName = @"";
    }
    NSString *identifier = [NSString stringWithFormat:@"tg%d", (int)user.userId];
    NSString *customIdentifier = [NSString stringWithFormat:@"tg%d_%lld", (int)user.userId, (long long)user.accessHash];
    NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
    nameComponents.givenName = user.firstName;
    nameComponents.familyName = user.lastName;
    return [[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:identifier type:INPersonHandleTypeUnknown] nameComponents:nameComponents displayName:displayName image:nil contactIdentifier:identifier customIdentifier:customIdentifier];
}

static INPerson *personWithContact(CNContact *contact) {
    NSString *displayName = nil;
    if (contact.givenName.length != 0 && contact.familyName.length != 0) {
        displayName = [[NSString alloc] initWithFormat:@"%@ %@", contact.givenName, contact.familyName];
    } else if (contact.givenName.length != 0) {
        displayName = contact.givenName;
    } else if (contact.familyName.length != 0) {
        displayName = contact.familyName;
    } else {
        displayName = @"";
    }
    
    NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
    nameComponents.givenName = contact.givenName;
    nameComponents.familyName = contact.familyName;
    return [[INPerson alloc] initWithPersonHandle:[[INPersonHandle alloc] initWithValue:contact.identifier type:INPersonHandleTypeUnknown] nameComponents:nameComponents displayName:displayName image:nil contactIdentifier:contact.identifier customIdentifier:nil];
}

@interface IntentHandler () <INSendMessageIntentHandling> {
    SQueue *_queue;
    SVariable *_shareContext;
    SVariable *_database;
    
    SMetaDisposable *_resolutionDisposable;
    SMetaDisposable *_sendMessageDisposable;
}

@end

@implementation IntentHandler

- (void)dealloc {
    [_resolutionDisposable dispose];
    [_sendMessageDisposable dispose];
}

- (id)handlerForIntent:(INIntent *)intent {
    return self;
}

#pragma mark - INSendMessageIntentHandling

- (SQueue *)queue {
    if (_queue == nil) {
        _queue = [[SQueue alloc] init];
    }
    return _queue;
}

- (SSignal *)shareContext {
    if (_shareContext == nil) {
        _shareContext = [[SVariable alloc] init];
        [_shareContext set:[TGShareContextSignal shareContext]];
    }
    return [[_shareContext signal] deliverOn:[self queue]];
}

- (SSignal *)database {
    if (_database == nil) {
        _database = [[SVariable alloc] init];
        [_database set:[[self shareContext] mapToSignal:^id(TGShareContext *context) {
            return [context legacyDatabase];
        }]];
    }
    return [[_database signal] deliverOn:[self queue]];
}

- (SMetaDisposable *)resolutionDisposable {
    if (_resolutionDisposable == nil) {
        _resolutionDisposable = [[SMetaDisposable alloc] init];
    }
    return _resolutionDisposable;
}

- (SMetaDisposable *)sendMessageDisposable {
    if (_sendMessageDisposable == nil) {
        _sendMessageDisposable = [[SMetaDisposable alloc] init];
    }
    return _sendMessageDisposable;
}

- (void)resolveRecipientsForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(NSArray<INPersonResolutionResult *> *resolutionResults))completion {
    NSArray<INPerson *> *recipients = intent.recipients;
    
    if (recipients.count == 0) {
        completion(@[[INPersonResolutionResult needsValue]]);
        return;
    } else if (recipients.count != 1) {
        completion(@[[INPersonResolutionResult needsValue]]);
        return;
    }
    
    bool allRecepientsAlreadyMatched = true;
    for (INPerson *recipient in recipients) {
        if (![recipient.customIdentifier hasPrefix:@"tg"]) {
            allRecepientsAlreadyMatched = false;
            break;
        }
    }
    
    if (allRecepientsAlreadyMatched && recipients.count != 0) {
        completion(@[[INPersonResolutionResult successWithResolvedPerson:recipients.firstObject]]);
        return;
    }
    
    __weak IntentHandler *weakSelf = self;
    [[self resolutionDisposable] setDisposable:[[[self database] map:^id(TGLegacyDatabase *database) {
        __strong IntentHandler *strongSelf = weakSelf;
        NSArray<CNContact *> *contacts = nil;
        if (recipients.count == 1 && recipients[0].contactIdentifier.length != 0) {
            contacts = [strongSelf matchedNativeContactsByContactId:recipients[0].contactIdentifier];
        } else if (recipients.count != 0) {
            contacts = [strongSelf matchedNativeContacts:[recipients[0] displayName]];
        }
        
        if (contacts.count == 0) {
            return @[[INPersonResolutionResult needsValue]];
        } else if (contacts.count != 1) {
            NSMutableArray<INPerson *> *persons = [[NSMutableArray alloc] init];
            for (CNContact *contact in contacts) {
                [persons addObject:personWithContact(contact)];
            }
            return @[[INPersonResolutionResult disambiguationWithPeopleToDisambiguate:persons]];
        } else {
            NSString *phone = contacts[0].phoneNumbers.firstObject.value.stringValue;
            if (phone.length == 0) {
                return @[[INPersonResolutionResult needsValue]];
            } else {
                //NSArray<TGLegacyUser *> *users = [database contactUsersMatchingQuery:[recipient displayName]];
                NSArray<TGLegacyUser *> *users = [database contactUsersMatchingPhone:phone];
                if (users.count == 0) {
                    return @[[INPersonResolutionResult unsupported]];
                } else if (users.count == 1) {
                    return @[[INPersonResolutionResult successWithResolvedPerson:personWithLegacyUser(users[0])]];
                } else {
                    NSMutableArray<INPerson *> *persons = [[NSMutableArray alloc] init];
                    for (TGLegacyUser *user in users) {
                        [persons addObject:personWithLegacyUser(user)];
                    }
                    return @[[INPersonResolutionResult disambiguationWithPeopleToDisambiguate:persons]];
                }
            }
        }
        
        return @[[INPersonResolutionResult needsValue]];
    }] startWithNext:^(NSArray<INPersonResolutionResult *> *result) {
        [[SQueue mainQueue] dispatch:^{
            completion(result);
        }];
    }]];
}

- (void)resolveContentForSendMessage:(INSendMessageIntent *)intent withCompletion:(void (^)(INStringResolutionResult *resolutionResult))completion {
    NSString *text = intent.content;
    if (text && ![text isEqualToString:@""]) {
        completion([INStringResolutionResult successWithResolvedString:text]);
    } else {
        completion([INStringResolutionResult needsValue]);
    }
}

- (void)confirmSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
    INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeReady userActivity:userActivity];
    completion(response);
}

- (void)handleSendMessage:(INSendMessageIntent *)intent completion:(void (^)(INSendMessageIntentResponse *response))completion {
    [[self sendMessageDisposable] setDisposable:[[[[[self shareContext] take:1] mapToSignal:^SSignal *(TGShareContext *context) {
        INPerson *person = [[intent recipients] firstObject];
        if (person != nil) {
            NSMutableArray<TGUserModel *> *users = [[NSMutableArray alloc] init];
            if ([person.customIdentifier hasPrefix:@"tg"]) {
                NSRange underscoreRange = [person.customIdentifier rangeOfString:@"_"];
                if (underscoreRange.location != NSNotFound) {
                    int32_t userId = [[[person.customIdentifier substringToIndex:underscoreRange.location] substringFromIndex:2] intValue];
                    int64_t accessHash = [[person.customIdentifier substringFromIndex:underscoreRange.location + underscoreRange.length] longLongValue];
                    [users addObject:[[TGUserModel alloc] initWithUserId:userId accessHash:accessHash firstName:@"" lastName:@"" avatarLocation:nil]];
                }
            }
            if (users.count != 0) {
                return [TGSendMessageSignals sendTextMessageWithContext:context peerId:TGPeerIdPrivateMake(users[0].userId) users:users text:intent.content];
            } else {
                return [SSignal fail:nil];
            }
        } else {
            return [SSignal fail:nil];
        }
    }] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error) {
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
        INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeFailureRequiringAppLaunch userActivity:userActivity];
        completion(response);
    } completed:^{
        NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:NSStringFromClass([INSendMessageIntent class])];
        INSendMessageIntentResponse *response = [[INSendMessageIntentResponse alloc] initWithCode:INSendMessageIntentResponseCodeSuccess userActivity:userActivity];
        completion(response);
    }]];
}

- (NSArray<CNContact *> *)matchedNativeContacts:(NSString *)query {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        CNContactStore *store = [[CNContactStore alloc] init];
        NSArray<CNContact *> *contacts = [store unifiedContactsMatchingPredicate:[CNContact predicateForContactsMatchingName:query] keysToFetch:@[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] error:nil];
        return contacts;
    } else {
        return @[];
    }
}

- (NSArray<CNContact *> *)matchedNativeContactsByContactId:(NSString *)contactId {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        CNContactStore *store = [[CNContactStore alloc] init];
        NSArray<CNContact *> *contacts = [store unifiedContactsMatchingPredicate:[CNContact predicateForContactsWithIdentifiers:@[contactId]] keysToFetch:@[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] error:nil];
        return contacts;
    } else {
        return @[];
    }
}

@end
