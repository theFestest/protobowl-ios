
#import "ProtobowlConnectionManager.h"
#import "ProtobowlQuestion.h"

#define LOG(s, ...) do { \
NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
NSLog(@"%@", string); \
} while(0)

@interface ProtobowlConnectionManager ()
@property (nonatomic, strong) SocketIO *socket;

@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic, strong) NSMutableArray *chatLines;

@property (nonatomic, strong) ProtobowlQuestion *currentQuestion;
@property (nonatomic, strong) NSString *questionDisplayText;
@property (nonatomic) BOOL isQuestionNew;
@property (nonatomic) int questionWordIndex;
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
    LOG(@"Disconnect with error: %@", error);
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    LOG(@"Error: %@", error);
}

- (void) socketIODidConnect:(SocketIO *)socket
{    
    // Use spoofed auth and cookie tokens for now
    NSString *auth = @"fpn7am41vytgaujydhfnrvxpafejo4elakqo";
    NSString *cookie = @"fpn7am41vytgaujydhfnrvxpafejo4elakqo";
    
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
    NSDictionary *packetData = packet.dataAsJSON[@"args"][0];
    if([packet.name isEqualToString:@"sync"]) // Handle the routine sync packet
    {
        if(packetData[@"users"]) // If it contains user data, update the users
        {
            NSArray *users = packetData[@"users"];
            for (NSDictionary *user in users)
            {
                NSString *userID = user[@"id"];
                NSMutableDictionary *userWithLineNumber = [user mutableCopy];
                userWithLineNumber[@"lineNumber"] = @(-1);
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
        
        
//        LOG(@"Sync data: %@", packetData);
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
    if(index >= self.currentQuestion.questionTextAsWordArray.count)
    {
        return;
    }
    
    [self.currentQuestion.questionDisplayText appendFormat:@"%@ ", self.currentQuestion.questionTextAsWordArray[index]];
    
    [self.delegate connectionManager:self didUpdateQuestionDisplayText:[self.currentQuestion.questionDisplayText copy]];
    
    self.currentQuestion.questionDisplayWordIndex++;
    float delay = ([self.currentQuestion.timing[index] floatValue] * self.currentQuestion.rate) / 1000.0f;
    [self performSelector:@selector(incrementQuestionDisplayText) withObject:nil afterDelay:delay inModes:@[NSRunLoopCommonModes]];
}


// This is all just a bunch of sort of complicated code to pretty print the JSON to the console.
- (NSString *) prettyPrintPacketData:(SocketIOPacket *)packet
{
    NSMutableDictionary *data = packet.dataAsJSON[@"args"][0];
    if([data isKindOfClass:[NSString class]])
    {
        return [data description];
    }
    
    NSOutputStream *outStream = [NSOutputStream outputStreamToMemory];
    [outStream open];
    [NSJSONSerialization writeJSONObject:data toStream:outStream options:NSJSONWritingPrettyPrinted error:nil];
    NSData *formattedJSONData = [outStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    return [[NSString alloc] initWithData:formattedJSONData encoding:NSUTF8StringEncoding];
}

@end
