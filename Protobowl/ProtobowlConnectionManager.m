
#import "ProtobowlConnectionManager.h"
#import "ProtobowlQuestion.h"
#import <QuartzCore/QuartzCore.h>

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

@property (nonatomic, strong) NSString *userID;

@property (nonatomic) float startQuestionTime;
@property (nonatomic) float questionDuration; // In seconds
@property (nonatomic, strong) NSTimer *questionTimer;

@property (nonatomic) BOOL isQuestionPaused;
@property (nonatomic) float startPauseTime;

@property (nonatomic, strong) NSString *buzzSessionId;
@property (nonatomic) BOOL hasPendingBuzz;
@property (nonatomic, strong) NSTimer *buzzTimer;
@property (nonatomic) float startBuzzTime;
@property (nonatomic) float buzzDuration;

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
    self.socket.useSecure = YES;
//    [self.socket connectToHost:@"108.213.77.143" onPort:25565];
    [self.socket connectToHost:@"protobowl.nodejitsu.com" onPort:443];
//    [self.socket connectToHost:@"cab.antimatter15.com" onPort:443];
//    [self.socket connectToHost:@"dino.xvm.mit.edu" onPort:5566];
}


#pragma mark - socket.io delegate methods
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"Disconnect with error: %@", error);
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"Error: %@", error);
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
     @"version" : @8}];
    
    [self.roomDelegate connectionManager:self didConnectWithSuccess:YES];
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
                
                self.currentQuestion.beginTime = [packetData[@"begin_time"] intValue];
                self.currentQuestion.endTime = [packetData[@"end_time"] intValue];
                self.currentQuestion.questionDuration = self.currentQuestion.endTime - self.currentQuestion.beginTime;
                printf("%d\n", self.currentQuestion.questionDuration);
                
                NSDictionary *infoDict = packetData[@"info"];
                self.currentQuestion.tournament = infoDict[@"tournament"];
                self.currentQuestion.year = infoDict[@"year"];
                self.currentQuestion.category = infoDict[@"category"];
                self.currentQuestion.difficulty = infoDict[@"difficulty"];
                
                [self.roomDelegate connectionManager:self didUpdateQuestion:self.currentQuestion];
                [self.roomDelegate connectionManager:self didSetBuzzEnabled:YES];
                
                // Setup timer for question
                self.startQuestionTime = CACurrentMediaTime();
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
            
            if(self.hasPendingBuzz)
            {
                if([userID isEqualToString:self.userID])
                {
                    self.buzzSessionId = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
                    self.hasPendingBuzz = NO;
                    [self.guessDelegate connectionManager:self didClaimBuzz:YES];
                    self.buzzDuration = [attempt[@"duration"] floatValue] / 1000.0;
                    self.buzzTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateBuzzTimer) userInfo:nil repeats:YES];
                    [[NSRunLoop mainRunLoop] addTimer:self.buzzTimer forMode:NSRunLoopCommonModes];
                    self.startBuzzTime = CACurrentMediaTime();
                }
                else
                {
                    self.hasPendingBuzz = NO;
                    self.buzzSessionId = nil;
                    [self.guessDelegate connectionManager:self didClaimBuzz:NO];
                }
            }
            
            /*if([userID isEqualToString:self.userID])
            {
                return;
            }*/
            
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
                
                if([userID isEqualToString:self.userID])
                {
                    [self.guessDelegate connectionManager:self didJudgeGuess:correct];
                }
                
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
            
            [self.roomDelegate connectionManager:self didUpdateBuzzLines:[self.buzzLines copy]];
            
            
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
        
        [self.roomDelegate connectionManager:self didUpdateChatLines:[self.chatLines copy]];
        
        
    }
    else if([packet.name isEqualToString:@"log"])
    {
        NSString *verb = packetData[@"verb"];
        if([verb isEqualToString:@"attempted an invalid buzz"])
        {
            // Log invalid buzz
            NSString *userID = packetData[@"user"];
            NSString *name = self.userData[userID][@"name"];
            NSString *text = [NSString stringWithFormat:@"%@ %@", name, verb];
            [self.buzzLines addObject:text];
            [self.roomDelegate connectionManager:self didUpdateBuzzLines:self.buzzLines];
            
            if([userID isEqualToString:self.userID] && self.hasPendingBuzz)
            {
                self.hasPendingBuzz = NO;
                [self.guessDelegate connectionManager:self didClaimBuzz:NO];
            }
        }
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
    NSLog(@"Pausing question");
    
    self.startPauseTime = CACurrentMediaTime();
    
    self.isQuestionPaused = YES;
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    
    [self.roomDelegate connectionManager:self didSetBuzzEnabled:NO];
}

- (void) unpauseQuestion
{
    NSLog(@"Unpause question");
    
    float now = CACurrentMediaTime();
    float pauseLength = now - self.startPauseTime;
    self.startQuestionTime += pauseLength;
    self.startPauseTime = now;
    
    self.isQuestionPaused = NO;
    [self.questionTimer invalidate];
    self.questionTimer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateQuestionTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.questionTimer forMode:NSRunLoopCommonModes];
    
    [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
    
    [self.roomDelegate connectionManager:self didSetBuzzEnabled:YES];
    
}

- (void) updateQuestionTimer
{
    float elapsedQuestionTime = CACurrentMediaTime() - self.startQuestionTime;
    
    float remaining = MAX(self.questionDuration - elapsedQuestionTime, 0);
    float progress = elapsedQuestionTime / self.questionDuration;
    
    if(progress >= 1.0)
    {
        // Done with the question
        [self expireQuestionTime];
    }
    
    [self.roomDelegate connectionManager:self didUpdateTime:remaining progress:progress];
}

- (void) updateBuzzTimer
{
    float elapsedBuzzTime = CACurrentMediaTime() - self.startBuzzTime;
    
    float remaining = MAX(self.buzzDuration - elapsedBuzzTime, 0);
    float progress = elapsedBuzzTime / self.buzzDuration;
    
    if(progress >= 1.0)
    {
        // Done with the buzz session
        [self expireBuzzTime];
    }
    
    [self.guessDelegate connectionManager:self didUpdateGuessTime:remaining progress:progress];

}

- (void) expireQuestionTime
{
    [self.questionTimer invalidate];
    self.questionTimer = nil;
    self.currentQuestion.isExpired = YES;
    [self.roomDelegate connectionManager:self didSetBuzzEnabled:NO];
    [self.roomDelegate connectionManager:self didEndQuestion:self.currentQuestion];
}

- (void) expireBuzzTime
{
    if(self.buzzSessionId)
    {
        [self.buzzTimer invalidate];
        self.buzzTimer = nil;
        self.hasPendingBuzz = NO;
        self.buzzSessionId = nil;
        [self.guessDelegate connectionManagerDidEndBuzzTime:self];
        
        [self unpauseQuestion];
    }
}

- (BOOL) buzz
{
    if(!self.currentQuestion || self.currentQuestion.isExpired || !self.currentQuestion.qid || [self.currentQuestion.qid isEqualToString:@""])
    {
        return NO;
    }
    
    [self.socket sendEvent:@"buzz" withData:self.currentQuestion.qid];
    self.hasPendingBuzz = YES;
    
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

- (void) submitGuess:(NSString *)guess;
{
    if(self.buzzSessionId)
    {
        NSDictionary *data = @{@"text": guess,
                               @"user": self.userID,
                               @"session" : self.buzzSessionId,
                               @"done" : @YES};
        [self.socket sendEvent:@"guess" withData:data];
        
        self.buzzSessionId = nil;
        
        [self expireBuzzTime];
        
        // TODO: don't call the callback until we receive a sync message with correct or not in it
        
    }
}

- (BOOL) next
{
    if(self.currentQuestion.isExpired)
    {
        [self.socket sendEvent:@"next" withData:nil];
        [self.buzzLines removeAllObjects];
        [self.roomDelegate connectionManager:self didUpdateBuzzLines:[self.buzzLines copy]];
        return YES;
    }
    return NO;
}

@end
