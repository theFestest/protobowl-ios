
#import "ProtobowlConnectionManager.h"
#import "ProtobowlQuestion.h"
#import "ProtobowlScoring.h"
#import "BuzzLogCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ProtobowlChatDescriptor.h"

/*#define LOG(s, ...) do { \
NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
NSLog(@"%@", string); \
} while(0)*/


#define kUserDataIsBuzzingKey @"isBuzzing"
#define kUserDataBuzzTextKey @"buzzText"
#define kUserDataBuzzLineNumberKey @"lineNumber"

#define kTimerInterval 0.05f

@interface ProtobowlConnectionManager ()
@property (nonatomic, strong) SocketIO *socket;

@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic, strong) NSMutableArray *chatLines;
@property (nonatomic, strong) NSMutableArray *logLines;

@property (nonatomic, strong) ProtobowlQuestion *currentQuestion;
@property (nonatomic, strong) NSString *questionDisplayText;
@property (nonatomic) BOOL isQuestionNew;
@property (nonatomic) BOOL isCurrentAttemptPrompt;


@property (nonatomic) float startQuestionTime;
@property (nonatomic) float questionDuration; // In seconds
@property (nonatomic, strong) NSTimer *questionTimer;

@property (nonatomic) BOOL isQuestionPaused;
@property (nonatomic) float startPauseTime;

@property (nonatomic, strong) NSString *buzzSessionId;
@property (nonatomic) BOOL hasPendingBuzz;
@property (nonatomic) BOOL hasPendingPrompt;
@property (nonatomic) BOOL didStartOtherPlayerBuzzTimer;
@property (nonatomic, strong) NSTimer *buzzTimer;
@property (nonatomic) float startBuzzTime;
@property (nonatomic) float buzzDuration;

@property (nonatomic, strong) ProtobowlScoring *scoring;

@property (nonatomic, strong) NSString *roomToConnectTo;
@property (nonatomic, strong) NSString *roomName;

@property (nonatomic) BOOL isChatNew;
@property (nonatomic, strong) NSString *chatSessionId;

@end

@implementation ProtobowlConnectionManager

#pragma mark - Custom Getters and Setters
- (NSMutableDictionary *) userData
{
    if (!_userData)
    {
        _userData = [NSMutableDictionary dictionary];
    }
    return _userData;
}
- (NSMutableArray *) chatLines
{
    if (!_chatLines)
    {
        _chatLines = [NSMutableArray array];
    }
    return _chatLines;
}
- (NSMutableArray *) logLines
{
    if (!_logLines)
    {
        _logLines = [NSMutableArray array];
    }
    return _logLines;
}
- (ProtobowlQuestion *) currentQuestion
{
    if(!_currentQuestion)
    {
        _currentQuestion = [[ProtobowlQuestion alloc] init];
    }
    return _currentQuestion;
}
- (NSString *) questionDisplayText
{
    if(!_questionDisplayText)
    {
        _questionDisplayText = [NSString string];
    }
    return _questionDisplayText;
}

- (ProtobowlUser *) myself
{
    if(!_myself)
    {
        _myself = [[ProtobowlUser alloc] init];
    }
    return _myself;
}


- (void) changeMyName:(NSString *)name
{
    [self.socket sendEvent:@"set_name" withData:name];
}

#define kCookieKey @"cookie_key"
#define kProtobowlHost @"protobowl.nodejitsu.com"
#define kProtobowlSocket 443
#define kProtobowlSecure YES
- (void) connectToRoom:(NSString *)room
{
    if(self.socket == nil)
    {
        self.socket = [[SocketIO alloc] initWithDelegate:self];
        self.socket.useSecure = kProtobowlSecure;
    }
    
    
    // Set room to connect to, which connection callback will read from later
    self.roomToConnectTo = room;
    
    if(self.socket.isConnected)
    {
        [self.socket disconnect];
    }
    else
    {
        [self.socket connectToHost:kProtobowlHost onPort:kProtobowlSocket];
    }
}

void gen_random(char *s, const int len) {
    static const char alphanum[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    
    for (int i = 0; i < len; ++i) {
        s[i] = alphanum[arc4random() % (sizeof(alphanum) - 1)];
    }
    
    s[len] = 0;
}

- (NSString *) randomNSStringWithLength:(int)len
{
    char *randomChars = malloc(sizeof(char) * (len + 1));
    gen_random(randomChars, len);
    return [NSString stringWithUTF8String:randomChars];
}


- (void) joinLobby:(NSString *)lobby
{
    if(self.socket.isConnected)
    {
        // Reset stuff
        [self.userData removeAllObjects];
        self.myself = nil;
        self.isChatNew = YES;
        
        // Use spoofed auth and cookie tokens for now
        NSString *auth = @"apn7am41vytgaujydhfnrvxpafejo4elakqo";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *cookie;
        if([defaults stringForKey:kCookieKey])
        {
            cookie = [defaults stringForKey:kCookieKey];
        }
        else
        {
            // Gen random cookie
            srand(time(NULL));
            cookie = [self randomNSStringWithLength:36];
            [defaults setObject:cookie forKey:kCookieKey];
            [defaults synchronize];
        }
        
        NSLog(@"Joining with cookie: %@", cookie);
        
        // TODO: Use "link" event???
        // Send join request
        [self.socket sendEvent:@"join" withData:@{@"cookie": cookie,
                                                  @"question_type" : @"qb",
                                                  @"room_name" : lobby,
                                                  @"muwave" : @NO,
                                                  @"custom_id" : @"Not applicable",
                                                  @"version" : @8}];
        
        [self.roomDelegate connectionManager:self didJoinLobby:lobby withSuccess:YES];
    }
}


#pragma mark - socket.io delegate methods
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"Disconnect with error: %@", error);
    if(self.roomToConnectTo)
    {
        [self.socket connectToHost:kProtobowlHost onPort:kProtobowlSocket];
    }
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [self.roomDelegate connectionManager:self didJoinLobby:self.roomToConnectTo withSuccess:NO];
}

- (void) socketIODidConnect:(SocketIO *)socket
{    
    [self joinLobby:self.roomToConnectTo];
    self.roomToConnectTo = nil;
}

- (void) saveReconnectData
{
    self.roomToConnectTo = self.roomName;
}

- (void) reconnectIfNeeded
{
    if(!self.socket.isConnected && self.roomToConnectTo)
    {
        [self.socket connectToHost:kProtobowlHost onPort:kProtobowlSocket];
    }
}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([packet.name isEqualToString:@"finish_question"])
    {
        // Handle logic to finish the question?
        return;
    }
    
    
    NSDictionary *packetData = packet.dataAsJSON[@"args"][0];
    if([packetData isKindOfClass:[NSString class]] || [packetData isKindOfClass:[NSNumber class]])
    {
        NSLog(@"Unknown data received: %@", packet.dataAsJSON);
        return;
    }
    
    if(packetData[@"id"])
    {
        self.myself.userID = packetData[@"id"];
    }
    else if([packet.name isEqualToString:@"sync"]) // Handle the routine sync packet
    {
        self.roomToConnectTo = nil;
        
        // Room settings sync
        BOOL settingChanged = NO;
        if(packetData[@"category"] && ![packetData[@"category"] isKindOfClass:[NSNull class]])
        {
            settingChanged = YES;
            _currentCategory = packetData[@"category"];
            if([_currentCategory isEqualToString:@""])
            {
                _currentCategory = @"Everything";
            }
        }
        if(packetData[@"difficulty"] && ![packetData[@"difficulty"] isKindOfClass:[NSNull class]])
        {
            settingChanged = YES;
            _currentDifficulty = packetData[@"difficulty"];
        }
        if(packetData[@"show_bonus"] && ![packetData[@"show_bonus"] isKindOfClass:[NSNull class]])
        {
            settingChanged = YES;
            _showBonusQuestions = [packetData[@"show_bonus"] boolValue];
        }
        if(packetData[@"no_skip"] && ![packetData[@"no_skip"] isKindOfClass:[NSNull class]])
        {
            settingChanged = YES;
            _allowSkip = ![packetData[@"no_skip"] boolValue];
        }
        if(packetData[@"max_buzz"])
        {
            settingChanged = YES;
            if([packetData[@"max_buzz"] isKindOfClass:[NSNull class]])
            {
                _allowMultipleBuzzes = YES;
            }
            else
            {
                _allowMultipleBuzzes = ![packetData[@"max_buzz"] boolValue];
            }
        }
        if(settingChanged)
        {
            [self.settingsDelegate connectionManagerDidChangeRoomSetting:self];
        }
        
        
        if(packetData[@"name"])
        {
            _roomName = packetData[@"name"];
        }
        
        if(packetData[@"scoring"])
        {
            _scoring = [[ProtobowlScoring alloc] initWithScoringDictionary:packetData[@"scoring"]];
        }
        
        if(packetData[@"users"]) // If it contains user data, update the users
        {
            NSArray *users = packetData[@"users"];
            for (NSDictionary *user in users)
            {
                NSString *userID = user[@"id"];
                NSMutableDictionary *userWithLineNumber = [user mutableCopy];
                userWithLineNumber[@"lineNumber"] = @(-1);
                userWithLineNumber[@"guessing"] = @NO;
                self.userData[userID] = userWithLineNumber;
            }
            
            [self outputUsersToLeaderboardDelegate];
        }
      
        if(packetData[@"qid"] && ![packetData[@"qid"] isKindOfClass:[NSNull class]])
        {
            NSString *newQid = packetData[@"qid"];
            if(![newQid isEqualToString:self.currentQuestion.qid])
            {
                self.isQuestionNew = YES;
                
                self.currentQuestion.qid = newQid;
                self.currentQuestion.answerText = packetData[@"answer"];
                self.currentQuestion.questionText = packetData[@"question"];
//                self.currentQuestion.questionText = @"One incident in this book ends with a character kneeling on a pitcher's mound and proclaiming “Oh God,” after following a man on a train whom he believes to be both God and his missing father because the man is missing one earlobe. In another part of this book, a child who believes that she is about to be put into a small box by a malevolent figure is calmed down by hearing a story about two bears in a bullying relationship, who become friends after a trade involving salmon. One character in this book speculates that the protagonist of Jack London's “To Build a Fire” wanted to die and talks about the meaning of bonfires with Miyake. The limousine driver Nimit takes one character in this book to a fortune teller, who instructs Satsuki to dream of a snake in order to get a stone out of her body. A predicted underground battle with a hate-absorbing worm in this book never comes to pass, and Katagiri is covered with insects after confronting the amphibian which foretold such a fight. The first character described in this book is given a free one-week vacation in exchange for a delivering a package to the sister of one of his coworkers at the electronics store, after his wife leaves him a note accusing him of being a “chunk of air” as the reason for leaving him, but traumatic memories of the (*) title phenomenon causes that character to become impotent with Shimao. Including “Landscape with Flatiron,” “All God's Children Can Dance,” “Thailand,” “Honey Pie,” “UFO in Kushiro,” and “Super-Frog Saves Tokyo,” this book takes place in the weeks after a January 1995 event in Kobe. For 10 points, name this short story cycle by Haruki Murakami about a natural disaster.";
                
                self.currentQuestion.rate = [packetData[@"rate"] floatValue];
                self.currentQuestion.timing = packetData[@"timing"];
                self.currentQuestion.isExpired = NO;
                
                self.currentQuestion.beginTime = [packetData[@"begin_time"] longLongValue];
                self.currentQuestion.endTime = [packetData[@"end_time"] longLongValue];
                self.currentQuestion.questionDuration = self.currentQuestion.endTime - self.currentQuestion.beginTime;
                
                // Calculate time offset in case the user has just joined the lobby
                long long realTime = [packetData[@"real_time"] longLongValue];
                long long timeOffset = [packetData[@"time_offset"] longLongValue];
                double trueTimeOffset = (realTime - self.currentQuestion.beginTime - timeOffset) / 1000.0; // trueTimeOffset is used in timer setup code below
                printf("Time offset: %f\n", trueTimeOffset);
                
                NSDictionary *infoDict = packetData[@"info"];
                self.currentQuestion.tournament = infoDict[@"tournament"];
                self.currentQuestion.year = infoDict[@"year"];
                self.currentQuestion.category = infoDict[@"category"];
                self.currentQuestion.difficulty = infoDict[@"difficulty"];
                
                [self.roomDelegate connectionManager:self didUpdateQuestion:self.currentQuestion];
                [self.roomDelegate connectionManager:self didSetBuzzEnabled:YES];
                
                // Setup timer for question
                self.startQuestionTime = CACurrentMediaTime() - trueTimeOffset;
                self.questionDuration = self.currentQuestion.questionDuration / 1000.0f;
                self.questionTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateQuestionTimer:) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.questionTimer forMode:NSRunLoopCommonModes];
                
                self.currentQuestion.questionTextAsWordArray = [self.currentQuestion.questionText componentsSeparatedByString:@" "];
                self.currentQuestion.questionDisplayWordIndex = [self questionDisplayWordIndexForTimeOffset:trueTimeOffset inTimingArray:self.currentQuestion.timing andQuestionRate:self.currentQuestion.rate];
                self.currentQuestion.questionDisplayText = [[self questionDisplayTextForIndex:self.currentQuestion.questionDisplayWordIndex inWordArray:self.currentQuestion.questionTextAsWordArray] mutableCopy];
                
                [self.roomDelegate connectionManager:self didUpdateQuestionDisplayText:self.currentQuestion.questionDisplayText];
                
                [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
                
            }
            else
            {
                self.isQuestionNew = NO;
            }
        }
        if(packetData[@"attempt"] && ![packetData[@"attempt"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *attempt = packetData[@"attempt"];
            NSString *userID = attempt[@"user"];
            BOOL isPrompt = [attempt[@"correct"] isKindOfClass:[NSString class]] && [attempt[@"correct"] isEqualToString:@"prompt"];
            BOOL isInterrupt = [attempt[@"interrupt"] boolValue];
            
            
            if(self.hasPendingBuzz)
            {
                if([userID isEqualToString:self.myself.userID])
                {
                    self.buzzSessionId = [self randomNSStringWithLength:36];
                    self.hasPendingBuzz = NO;
                    [self.roomDelegate connectionManager:self didClaimBuzz:YES];
                    [self pauseQuestion];
                    self.buzzDuration = [attempt[@"duration"] floatValue] / 1000.0;
                    
                    [self.buzzTimer invalidate];
                    self.buzzTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateBuzzTimer:) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:self.buzzTimer forMode:NSRunLoopCommonModes];
                    self.startBuzzTime = CACurrentMediaTime();
                }
                else
                {
                    self.hasPendingBuzz = NO;
                    self.buzzSessionId = nil;
                    [self.roomDelegate connectionManager:self didClaimBuzz:NO];
                }
            }
            else if(self.hasPendingPrompt && isPrompt)
            {
                // Initiate prompting
                if([userID isEqualToString:self.myself.userID])
                {
                    [self.guessDelegate connectionManagerDidReceivePrompt:self];
                    
                    self.buzzSessionId = [self randomNSStringWithLength:36];
                    self.hasPendingPrompt = NO;
                    self.buzzDuration = [attempt[@"duration"] floatValue] / 1000.0;
                    
                    [self.buzzTimer invalidate];
                    self.buzzTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateBuzzTimer:) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:self.buzzTimer forMode:NSRunLoopCommonModes];
                    self.startBuzzTime = CACurrentMediaTime();
                }
                else
                {
                    self.hasPendingPrompt = NO;
                    self.buzzSessionId = nil;
                }
            }
            else if(!self.didStartOtherPlayerBuzzTimer && !self.buzzSessionId)
            {
                [self pauseQuestion];
                self.buzzDuration = [attempt[@"duration"] floatValue] / 1000.0;
                
                [self.buzzTimer invalidate];
                self.buzzTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateBuzzTimer:) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.buzzTimer forMode:NSRunLoopCommonModes];
                self.startBuzzTime = CACurrentMediaTime();
                
                self.didStartOtherPlayerBuzzTimer = YES;
            }

            
            NSLog(@"Attempt: %@\n", attempt);
            NSString *guessText = attempt[@"text"];
            BOOL done = [attempt[@"done"] boolValue];
            NSString *name = self.userData[userID][@"name"];
            NSString *text = [NSString stringWithFormat:@"%@<b>%@</b> %@", ((isPrompt && !done) || (done && self.isCurrentAttemptPrompt)) ? kBuzzPromptTag : (isInterrupt ? kBuzzInterruptTag : kBuzzTag), name, guessText];
            
            if(done)
            {
                BOOL correct = [attempt[@"correct"] boolValue];
                self.didStartOtherPlayerBuzzTimer = NO;
                [self expireBuzzTime:nil];
                
                if(isPrompt)
                {
                    text = [NSString stringWithFormat:@"%@%@", text, kBuzzPromptTag];
                    int currentLineNumber = [self.userData[userID][kUserDataBuzzLineNumberKey] intValue];
                    self.logLines[currentLineNumber] = text;
                    
                    self.userData[userID][kUserDataBuzzLineNumberKey] = @(-1);
                    self.userData[userID][kUserDataIsBuzzingKey] = @YES;
                    self.userData[userID][kUserDataBuzzTextKey] = @"";
                    
                    self.hasPendingPrompt = YES;
                }
                else
                {
                    text = [NSString stringWithFormat:@"%@%@", text, correct ? kBuzzCorrectTag : kBuzzWrongTag];
                    int currentLineNumber = [self.userData[userID][kUserDataBuzzLineNumberKey] intValue];
                    self.logLines[currentLineNumber] = text;
                    
                    self.userData[userID][kUserDataBuzzLineNumberKey] = @(-1);
                    self.userData[userID][kUserDataIsBuzzingKey] = @NO;
                    self.userData[userID][kUserDataBuzzTextKey] = @"";
                    
                    
                    if([userID isEqualToString:self.myself.userID])
                    {
                        BOOL isEarly = [attempt[@"early"] boolValue];
                        NSString *type = nil;
                        if(isEarly)
                        {
                            type = @"early";
                        }
                        else if(isInterrupt)
                        {
                            type = @"interrupt";
                        }
                        else
                        {
                            type = @"normal";
                        }
                        
                        int score = 0;
                        if(correct)
                        {
                            score = [self.scoring positiveScoreValueOfType:type];
                        }
                        else
                        {
                            score = [self.scoring negativeScoreValueOfType:type];
                        }
                        [self.guessDelegate connectionManager:self didJudgeGuess:correct withReceivedScoreValue:score];
                    }
                    
                    [self unpauseQuestion];
                    
                    if(correct)
                    {
                        [self expireQuestionTime:nil];
                    }
                }
                
            }
            else
            {
                // Update typed text
                int currentLineNumber = [self.userData[userID][kUserDataBuzzLineNumberKey] intValue];
                if(currentLineNumber == -1)
                {
                    currentLineNumber = self.logLines.count;
                    [self.logLines addObject:text];
                    self.userData[userID][kUserDataBuzzLineNumberKey] = @(currentLineNumber);
                }
                self.logLines[currentLineNumber] = text;
                
                
                if(!self.isQuestionPaused)
                {
                    [self pauseQuestion];
                }
                
                self.isCurrentAttemptPrompt = isPrompt;
            }
            
            [self.roomDelegate connectionManager:self didUpdateLogLines:[self.logLines copy]];
            
            
        }
    }
    else if([packet.name isEqualToString:@"chat"])
    {
        NSString *userID = packetData[@"user"];
        NSMutableDictionary *user = self.userData[userID];
        
        NSString *name = user[@"name"];
        NSString *message = packetData[@"text"];
        BOOL isFirst = [packetData[@"first"] boolValue];
        BOOL isDone = [packetData[@"done"] boolValue];
        
        if(isFirst)
        {
            user[@"chatLineNumber"] = @(self.chatLines.count);
            user[@"lineNumber"] = @(self.logLines.count);
            
            ProtobowlChatDescriptor *chatDesc = [[ProtobowlChatDescriptor alloc] init];
            chatDesc.chatText = message;
            chatDesc.playerName = name;
            chatDesc.chatDate = [NSDate date];
            chatDesc.isMe = [self.myself.userID isEqualToString:userID];
            
            [self.chatLines addObject:chatDesc];
            [self.logLines addObject:[NSString stringWithFormat:@"<b>%@</b> %@", name, message]];
        }
        else if(isDone)
        {
            int chatIndex = [user[@"chatLineNumber"] intValue];
            int logIndex = [user[@"lineNumber"] intValue];

            if(chatIndex != -1 && chatIndex < self.chatLines.count)
            {
                if([message isEqualToString:@""])
                {
                    [self.chatLines removeObjectAtIndex:chatIndex];
                }
                else
                {
                    [self.chatLines[chatIndex] setChatText:message];
                }
                user[@"chatLineNumber"] = @(-1);
            }
            if(logIndex != -1 && logIndex < self.logLines.count)
            {
                if([message isEqualToString:@""])
                {
                    [self.logLines removeObjectAtIndex:logIndex];
                }
                else
                {
                    
                    self.logLines[logIndex] = [NSString stringWithFormat:@"<b>%@</b> %@", name, message];
                }
                user[@"lineNumber"] = @(-1);
            }
        }
        else
        {
            int chatIndex = [user[@"chatLineNumber"] intValue];
            int logIndex = [user[@"lineNumber"] intValue];
            if(chatIndex != -1 && chatIndex < self.chatLines.count)
            {
                [self.chatLines[chatIndex] setChatText:message];
            }
            if(logIndex != -1 && logIndex < self.logLines.count)
            {
                self.logLines[logIndex] = [NSString stringWithFormat:@"<b>%@</b> %@", name, message];
            }
        }
        
        [self.roomDelegate connectionManager:self didUpdateLogLines:[self.logLines copy]];
        [self.chatDelegate connectionManager:self didUpdateChatLines:[self.chatLines copy] inRoom:self.roomName];
        
        
    }
    else if([packet.name isEqualToString:@"log"])
    {
        NSString *verb = packetData[@"verb"];
        NSRange leftParenRange;
        if((leftParenRange = [verb rangeOfString:@"("]).location != NSNotFound)
        {
            leftParenRange.length = verb.length - leftParenRange.location;
            verb = [verb stringByReplacingCharactersInRange:leftParenRange withString:@""];
        }
        
        NSString *userID = packetData[@"user"];
        NSString *name = self.userData[userID][@"name"];
        if(!name) return;

        NSString *text = [NSString stringWithFormat:@"<b>%@</b> %@", name, verb];
        if([verb isEqualToString:@"attempted an invalid buzz"])
        {
            if([userID isEqualToString:self.myself.userID] && self.hasPendingBuzz)
            {
                self.hasPendingBuzz = NO;
                [self.roomDelegate connectionManager:self didClaimBuzz:NO];
            }
        }
        [self.logLines addObject:text];
        [self.roomDelegate connectionManager:self didUpdateLogLines:self.logLines];
    }
    else
    {
        NSLog(@"Received event: \"%@\"", packet.name);
    }
}

- (void) incrementQuestionDisplayText
{
    int index = self.currentQuestion.questionDisplayWordIndex;
    
//    NSLog(@"Updating question text with index: %d", index);
    
    if(index >= self.currentQuestion.questionTextAsWordArray.count) return;
    if(self.isQuestionPaused) return;
    
    [self.currentQuestion.questionDisplayText appendFormat:@"%@ ", self.currentQuestion.questionTextAsWordArray[index]];
    
    [self.roomDelegate connectionManager:self didUpdateQuestionDisplayText:[self.currentQuestion.questionDisplayText copy]];
    
    self.currentQuestion.questionDisplayWordIndex++;
    float timeValue = 0;
    if(index < self.currentQuestion.timing.count)
    {
        timeValue = [self.currentQuestion.timing[index] floatValue];
    }
    float delay = (timeValue * self.currentQuestion.rate) / 1000.0f;
    [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:delay inModes:@[NSRunLoopCommonModes]];
}

- (void) pauseQuestion
{
    if(!self.isQuestionPaused)
    {
        NSLog(@"Pausing question");
        
        self.startPauseTime = CACurrentMediaTime();
        
        self.isQuestionPaused = YES;
        [self.questionTimer invalidate];
        self.questionTimer = nil;
        
        [self.roomDelegate connectionManager:self didSetBuzzEnabled:NO];
    }
}

- (void) unpauseQuestion
{
    
    float now = CACurrentMediaTime();
    float pauseLength = now - self.startPauseTime;
    self.startQuestionTime += pauseLength;
    self.startPauseTime = now;
    
    NSLog(@"Unpause question: %f", pauseLength);

    self.isQuestionPaused = NO;
    [self.questionTimer invalidate];
    self.questionTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateQuestionTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.questionTimer forMode:NSRunLoopCommonModes];
    
    [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    
    [self.roomDelegate connectionManager:self didSetBuzzEnabled:YES];
    
}

- (void) updateQuestionTimer:(NSTimer *)timer
{
    float elapsedQuestionTime = CACurrentMediaTime() - self.startQuestionTime;
    
    float remaining = MAX(self.questionDuration - elapsedQuestionTime, 0);
    float progress = elapsedQuestionTime / self.questionDuration;
    
    if(progress >= 1.0)
    {
        // Done with the question
        [self expireQuestionTime:timer];
        progress = 1;
    }
    
    [self.roomDelegate connectionManager:self didUpdateTime:remaining progress:progress];
}

- (void) updateBuzzTimer:(NSTimer *)timer
{
    float elapsedBuzzTime = CACurrentMediaTime() - self.startBuzzTime;
    
    float remaining = MAX(self.buzzDuration - elapsedBuzzTime, 0);
    float progress = elapsedBuzzTime / self.buzzDuration;
    
    if(progress >= 1.0)
    {
        // Done with the buzz session
        [self expireBuzzTime:timer];
    }
    
    [self.guessDelegate connectionManager:self didUpdateGuessTime:remaining progress:progress];
    [self.roomDelegate connectionManager:self didUpdateGuessTime:remaining progress:progress];

}

- (void) expireQuestionTime:(NSTimer *)timer
{
    NSLog(@"Expiring question");
    
    [self.roomDelegate connectionManager:self didUpdateTime:0 progress:1];
    
    self.currentQuestion.questionDisplayWordIndex = self.currentQuestion.questionTextAsWordArray.count;
    [self.roomDelegate connectionManager:self didUpdateQuestionDisplayText:self.currentQuestion.questionText];
    
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    
    [timer invalidate];
    timer = nil;
    
    self.currentQuestion.isExpired = YES;
    [self.roomDelegate connectionManager:self didSetBuzzEnabled:NO];
    [self.roomDelegate connectionManager:self didEndQuestion:self.currentQuestion];
}

- (void) expireBuzzTime:(NSTimer *)timer
{
//    if(self.buzzSessionId || self.didStartOtherPlayerBuzzTimer)
//    {
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
    else
    {
        [self.buzzTimer invalidate];
        self.buzzTimer = nil;
    }

    self.hasPendingBuzz = NO;
    self.buzzSessionId = nil;
    [self.guessDelegate connectionManagerDidEndBuzzTime:self];
        
        //[self unpauseQuestion];
//    }
}

- (BOOL) buzz
{
    if(!self.currentQuestion || self.currentQuestion.isExpired || !self.currentQuestion.qid || [self.currentQuestion.qid isEqualToString:@""])
    {
        return NO;
    }
    
    [self.socket sendEvent:@"buzz" withData:self.currentQuestion.qid];
    self.hasPendingBuzz = YES;
    
    return YES;
}

- (void) updateGuess:(NSString *)guess
{
    if(self.buzzSessionId)
    {
        NSDictionary *data = @{@"text": guess,
                               @"user": self.myself.userID,
                               @"session" : self.buzzSessionId,
                               @"done" : @NO};
        [self.socket sendEvent:@"guess" withData:data];
    }
}

- (void) submitGuess:(NSString *)guess;
{
    if(self.buzzSessionId)
    {
        NSDictionary *data = @{@"text": guess,
                               @"user": self.myself.userID,
                               @"session" : self.buzzSessionId,
                               @"done" : @YES};
        [self.socket sendEvent:@"guess" withData:data];
        
        self.buzzSessionId = nil;
        
        [self expireBuzzTime:nil];
        
        // TODO: don't call the callback until we receive a sync message with correct or not in it
        
    }
}

- (BOOL) next
{
    if(self.currentQuestion.isExpired)
    {
        [self.socket sendEvent:@"next" withData:nil];
        [self.logLines removeAllObjects];
        [self.roomDelegate connectionManager:self didUpdateLogLines:[self.logLines copy]];
        return YES;
    }
    return NO;
}

- (void) outputUsersToLeaderboardDelegate
{
    if(self.scoring == nil) return;
    
    // Setup user objects, calculate their scores, and add them to the users array
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:self.userData.count];
    for (NSString *userID in self.userData)
    {
        NSDictionary *userData = self.userData[userID];
        BOOL isIdle = [userData[@"idle"] boolValue];
        BOOL isOnline = [userData[@"online_state"] boolValue];
        
        ProtobowlUser *user = [[ProtobowlUser alloc] init];
        user.userID = userID;
        user.name = userData[@"name"];
        user.score = [self.scoring calculateScoreForUser:userData];
        user.corrects = [self.scoring calculateCorrectsForUser:userData];
        user.negatives = [self.scoring calculateNegsForUser:userData];
        user.bestStreak = [userData[@"streak_record"] intValue];
        user.lastTimeOnline = [userData[@"last_session"] longLongValue] / 1000.0;
        if([userID isEqualToString:self.myself.userID])
        {
            user.status = ProtobowlUserStatusSelf;
        }
        else if(isIdle)
        {
            user.status = ProtobowlUserStatusIdle;
        }
        else
        {
            user.status = isOnline ? ProtobowlUserStatusOnline : ProtobowlUserStatusOffline;
        }
        
        [users addObject:user];
    }
    
    // Sort the users array by score
    [users sortUsingComparator:^NSComparisonResult(ProtobowlUser *obj1, ProtobowlUser *obj2) {
        if(obj1.score < obj2.score)
        {
            return NSOrderedDescending;
        }
        else if(obj1.score > obj2.score)
        {
            return NSOrderedAscending;
        }
        else
        {
            if(obj2.negatives > obj1.negatives)
            {
                return NSOrderedAscending;
            }
            else if(obj1.negatives > obj2.negatives)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedSame;
            }
        }
    }];
    
    // Calculate user ranks
    int lastScore = INT_MAX;
    int currentRank = 0;
    for (int i = 0; i < users.count; i++)
    {
        ProtobowlUser *user = users[i];
        int score = user.score;
        if(score < lastScore)
        {
            user.rank = ++currentRank;
        }
        else
        {
            user.rank = currentRank;
        }
        
        lastScore = score;
    }
    
    int indexOfMyself = [users indexOfObjectPassingTest:^BOOL(ProtobowlUser *obj, NSUInteger idx, BOOL *stop) {
        if([obj.userID isEqualToString:self.myself.userID])
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if(indexOfMyself == NSNotFound)
    {
        self.myself.name = @"";
        self.myself.score = 0;
        self.myself.rank = 0;
    }
    else
    {
        ProtobowlUser *myself = users[indexOfMyself];
        self.myself.name = myself.name;
        self.myself.score = myself.score;
        self.myself.rank = myself.rank;
    }
    
    
    [self.leaderboardDelegate connectionManager:self didUpdateUsers:users inRoom:self.roomName];
    [self.roomDelegate connectionManager:self didUpdateUsers:users];
}



- (int) questionDisplayWordIndexForTimeOffset:(float)seconds inTimingArray:(NSArray *)timingArray andQuestionRate:(float)rate
{
    float sumSeconds = 0;
    int i = 0;
    while(i < timingArray.count && sumSeconds <= seconds)
    {
        float timeValue = [timingArray[i] floatValue];
        sumSeconds += (timeValue * rate) / 1000.0f;
        i++;
    }
    return i;
}

- (NSString *) questionDisplayTextForIndex:(int)index inWordArray:(NSArray *) wordArray
{
    NSString *retVal = @"";
    for(int i = 0; i < index; i++)
    {
        retVal = [retVal stringByAppendingString:wordArray[i]];
        retVal = [retVal stringByAppendingString:@" "];
    }
    return retVal;
}

- (void) resetScore
{
    [self.socket sendEvent:@"reset_score" withData:@YES];
}

- (void) chat:(NSString *)chatText isDone:(BOOL)done
{
    if(!self.socket.isConnected || !self.myself.userID) return;
    
    if(self.isChatNew)
    {
        self.chatSessionId = [self randomNSStringWithLength:36];
    }
    
    NSLog(@"%@", self.chatSessionId);

    NSDictionary *chatDict = @{@"user": self.myself.userID,
                               @"text": chatText,
                               @"session": self.chatSessionId,
                               @"done": @(done),
                               @"first": @(self.isChatNew)};
    [self.socket sendEvent:@"chat" withData:chatDict];
    NSLog(@"Sending chat");
    
    if(self.isChatNew)
    {
        self.isChatNew = NO;
    }
    
    if(done)
    {
        self.isChatNew = YES;
    }
}

- (void) setChatDelegate:(id<ProtobowlChatDelegate>)chatDelegate
{
    _chatDelegate = chatDelegate;
    [_chatDelegate connectionManager:self didUpdateChatLines:self.chatLines inRoom:self.roomName];
}
- (void) setCurrentCategory:(NSString *)currentCategory
{
    _currentCategory = currentCategory;
    if([currentCategory isEqualToString:@"Everything"])
    {
        currentCategory = @"";
    }
    [self.socket sendEvent:@"set_category" withData:currentCategory];
}

- (void) setCurrentDifficulty:(NSString *)currentDifficulty
{
    _currentDifficulty = currentDifficulty;
    [self.socket sendEvent:@"set_difficulty" withData:currentDifficulty];
}

- (void) setShowBonusQuestions:(BOOL)showBonusQuestions
{
    _showBonusQuestions = showBonusQuestions;
    
    [self.socket sendEvent:@"set_bonus" withData:@(showBonusQuestions)];
}

- (void) setAllowSkip:(BOOL)allowSkip
{
    _allowSkip = allowSkip;
    
    [self.socket sendEvent:@"set_skip" withData:@(allowSkip)];
}

- (void) setAllowMultipleBuzzes:(BOOL)allowMultipleBuzzes
{
    _allowMultipleBuzzes = allowMultipleBuzzes;
    
    if(allowMultipleBuzzes)
    {
        [self.socket sendEvent:@"set_max_buzz" withData:@0];
    }
    else
    {
        [self.socket sendEvent:@"set_max_buzz" withData:@1];
    }
}

- (NSString *)currentRoomName
{
    return _roomName;
}


#define kHasViewedTutorialKey @"HAS_VIEWED_TUTORIAL"
- (BOOL) hasViewedTutorial
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasViewedTutorialKey];
}

- (void) setHasViewedTutorial:(BOOL)viewed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:viewed forKey:kHasViewedTutorialKey];
    [defaults synchronize];
}



@end
