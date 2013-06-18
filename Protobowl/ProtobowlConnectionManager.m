
#import "ProtobowlConnectionManager.h"
#import "ProtobowlQuestion.h"

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
@property (nonatomic, strong) NSMutableArray *buzzLines;

@property (nonatomic, strong) ProtobowlQuestion *currentQuestion;
@property (nonatomic, strong) NSString *questionDisplayText;
@property (nonatomic) BOOL isQuestionNew;
@property (nonatomic) int questionWordIndex;

@property (nonatomic) NSString *buzzSessionId;

@property (nonatomic, strong) NSString *userID;


@property (nonatomic) float elapsedTime;
@property (nonatomic) float questionDuration; // In seconds
@property (nonatomic, strong) NSTimer *questionTimer;

@property (nonatomic) BOOL isQuestionPaused;
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
- (NSMutableArray *) buzzLines
{
    if (!_buzzLines)
    {
        _buzzLines = [NSMutableArray array];
    }
    return _buzzLines;
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

- (void) connect
{
    self.socket = [[SocketIO alloc] initWithDelegate:self];
    [self.socket connectToHost:@"protobowl.nodejitsu.com" onPort:80];
//    [self.socket connectToHost:@"dino.xvm.mit.edu" onPort:5566];
}



#pragma mark - socket.io delegate methods
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
//    LOG(@"Disconnect with error: %@", error);
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
//    LOG(@"Error: %@", error);
}

- (void) socketIODidConnect:(SocketIO *)socket
{    
    // Use spoofed auth and cookie tokens for now
    NSString *auth = @"fpn7am41vytgaujydhfnrvxpafejo4elakqo";
    NSString *cookie = @"fpn7am41vytgaujydhfnrvxpafejo4elakqo";
    
    // TODO: Use "link" event???
    // Send join request
    [self.socket sendEvent:@"join" withData:@{@"cookie": cookie,
     @"auth" : auth,
     @"question_type" : @"qb",
     @"room_name" : @"minibitapp",
     @"muwave" : @NO,
     @"custom_id" : @"Donald iOS",
     @"version" : @7}];
    
    [self.delegate connectionManager:self didConnectWithSuccess:YES];
}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([packet.name isEqualToString:@"finish_question"])
    {
        // Handle logic to finish the question?
        return;
    }
    
    
    NSDictionary *packetData = packet.dataAsJSON[@"args"][0];
    if([packetData isKindOfClass:[NSString class]])
    {
        NSLog(@"Unknown string data received: %@", packetData);
        return;
    }
    
    if(packetData[@"id"])
    {
        self.userID = packetData[@"id"];
    }
    else if([packet.name isEqualToString:@"sync"]) // Handle the routine sync packet
    {
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
        }
        
        if(packetData[@"qid"])
        {
            NSString *newQid = packetData[@"qid"];
            if(![newQid isEqualToString:self.currentQuestion.qid])
            {
                self.isQuestionNew = YES;
                
                self.currentQuestion.qid = newQid;
                self.currentQuestion.answerText = packetData[@"answer"];
                self.currentQuestion.questionText = packetData[@"question"];
                
                self.currentQuestion.rate = [packetData[@"rate"] floatValue];
                self.currentQuestion.timing = packetData[@"timing"];
                self.currentQuestion.isExpired = NO;
                
                self.currentQuestion.beginTime = [packetData[@"begin_time"] intValue];
                self.currentQuestion.endTime = [packetData[@"end_time"] intValue];
                self.currentQuestion.questionDuration = self.currentQuestion.endTime - self.currentQuestion.beginTime;
                printf("%d\n", self.currentQuestion.questionDuration);
                
                NSDictionary *infoDict = packetData[@"info"];
                self.currentQuestion.tournament = infoDict[@"tournament"];
                self.currentQuestion.year = infoDict[@"year"];
                self.currentQuestion.category = infoDict[@"category"];
                self.currentQuestion.difficulty = infoDict[@"difficulty"];
                
                [self.delegate connectionManager:self didUpdateQuestion:self.currentQuestion];
                [self.delegate connectionManager:self didSetBuzzEnabled:YES];
                
                // Setup timer for question
                self.elapsedTime = 0;
                self.questionDuration = self.currentQuestion.questionDuration / 1000.0f;
                self.questionTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateQuestionTimer) userInfo:nil repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.questionTimer forMode:NSRunLoopCommonModes];
                
                self.currentQuestion.questionDisplayText = [@"" mutableCopy];
                self.currentQuestion.questionDisplayWordIndex = 0;
                self.currentQuestion.questionTextAsWordArray = [self.currentQuestion.questionText componentsSeparatedByString:@" "];
                
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
            NSString *text = attempt[@"text"];
            BOOL done = [attempt[@"done"] boolValue];
            NSString *name = self.userData[userID][@"name"];
            text = [NSString stringWithFormat:@"[Buzz] %@: %@", name, text];
            
            if(done)
            {
                BOOL correct = [attempt[@"correct"] boolValue];
                text = [NSString stringWithFormat:@"%@ [%@]", text, correct ? @"Correct" : @"Wrong"];
                int currentLineNumber = [self.userData[userID][kUserDataBuzzLineNumberKey] intValue];
                self.buzzLines[currentLineNumber] = text;
                // TODO: Do something with correcness (log buzz)
                
                self.userData[userID][kUserDataBuzzLineNumberKey] = @(-1);
                self.userData[userID][kUserDataIsBuzzingKey] = @NO;
                self.userData[userID][kUserDataBuzzTextKey] = @"";
                
                [self unpauseQuestion];
            }
            else
            {
                int currentLineNumber = [self.userData[userID][kUserDataBuzzLineNumberKey] intValue];
                if(currentLineNumber == -1)
                {
                    currentLineNumber = self.buzzLines.count;
                    [self.buzzLines addObject:text];
                    self.userData[userID][kUserDataBuzzLineNumberKey] = @(currentLineNumber);
                }
                self.buzzLines[currentLineNumber] = text;
                
                if(!self.isQuestionPaused)
                {
                    [self pauseQuestion];
                }
            }
            
            [self.delegate connectionManager:self didUpdateBuzzLines:[self.buzzLines copy]];
            
            
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
        
        NSString *text = [NSString stringWithFormat:@"%@: %@", name, message];
        
        if(isFirst)
        {
            user[@"lineNumber"] = @(self.chatLines.count);
            [self.chatLines addObject:text];
        }
        else if(isDone)
        {
            int index = [user[@"lineNumber"] intValue];
            if(index == -1) return;
            self.chatLines[index] = text;
            user[@"lineNumber"] = @(-1);
        }
        else
        {
            int index = [user[@"lineNumber"] intValue];
            if(index == -1) return;
            self.chatLines[index] = text;
        }
        
        [self.delegate connectionManager:self didUpdateChatLines:[self.chatLines copy]];
        
        
    }
    else if([packet.name isEqualToString:@"log"])
    {
        // Do something with log
    }
    else
    {
        NSLog(@"Received event: \"%@\"", packet.name);
    }
}

- (void) incrementQuestionDisplayText
{
    int index = self.currentQuestion.questionDisplayWordIndex;
    
    if(index >= self.currentQuestion.questionTextAsWordArray.count) return;
    if(self.isQuestionPaused) return;
    
    [self.currentQuestion.questionDisplayText appendFormat:@"%@ ", self.currentQuestion.questionTextAsWordArray[index]];
    
    [self.delegate connectionManager:self didUpdateQuestionDisplayText:[self.currentQuestion.questionDisplayText copy]];
    
    self.currentQuestion.questionDisplayWordIndex++;
    float delay = ([self.currentQuestion.timing[index] floatValue] * self.currentQuestion.rate) / 1000.0f;
    [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:delay inModes:@[NSRunLoopCommonModes]];
}

- (void) pauseQuestion
{
    self.isQuestionPaused = YES;
    [self.questionTimer invalidate];
    
    [self.delegate connectionManager:self didSetBuzzEnabled:NO];
}

- (void) unpauseQuestion
{
    self.isQuestionPaused = NO;
    self.questionTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateQuestionTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.questionTimer forMode:NSRunLoopCommonModes];
    
    [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    
    [self.delegate connectionManager:self didSetBuzzEnabled:YES];
}

- (void) updateQuestionTimer
{
    self.elapsedTime += kTimerInterval;
    
    float remaining = MAX(self.questionDuration - self.elapsedTime, 0);
    float progress = self.elapsedTime / self.questionDuration;
    
    if(progress >= 1.0)
    {
        // Done with the question
        [self expireTime];
    }
    
    [self.delegate connectionManager:self didUpdateTime:remaining progress:progress];
}

- (void) expireTime
{
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    self.currentQuestion.isExpired = YES;
    [self.delegate connectionManager:self didSetBuzzEnabled:NO];
}

- (BOOL) buzz
{
    if(!self.currentQuestion || self.currentQuestion.isExpired || !self.currentQuestion.qid || [self.currentQuestion.qid isEqualToString:@""])
    {
        return NO;
    }
    
    [self.socket sendEvent:@"buzz" withData:self.currentQuestion.qid];
    self.buzzSessionId = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    
    [self pauseQuestion];
    
    return YES;
}

- (void) updateGuess:(NSString *)guess
{
    if(self.buzzSessionId)
    {
        NSDictionary *data = @{@"text": guess,
                               @"user": self.userID,
                               @"session" : self.buzzSessionId,
                               @"done" : @NO};
        [self.socket sendEvent:@"guess" withData:data];
    }
}

- (void) submitGuess:(NSString *)guess withCallback:(GuessCallback) callback
{
    if(self.buzzSessionId)
    {
        NSDictionary *data = @{@"text": guess,
                               @"user": self.userID,
                               @"session" : self.buzzSessionId,
                               @"done" : @YES};
        [self.socket sendEvent:@"guess" withData:data];
        
        
        // TODO: don't call the callback until we receive a sync message with correct or not in it
        callback(YES);
    }
}

@end
