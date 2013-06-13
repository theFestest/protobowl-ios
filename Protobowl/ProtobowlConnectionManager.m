
#import "ProtobowlConnectionManager.h"

#define LOG(s, ...) do { \
NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
NSLog(@"%@", string); \
} while(0)

@interface ProtobowlConnectionManager ()
@property (nonatomic, strong) SocketIO *socket;
@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic, strong) NSMutableArray *chatLines;
@end

@implementation ProtobowlConnectionManager

- (id) init
{
    if(self = [super init])
    {
        self.userData = [NSMutableDictionary dictionary];
        self.chatLines = [NSMutableArray array];
    }
    return self;
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
    if([packet.name isEqualToString:@"sync"])
    {
        if(packetData[@"users"])
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
        LOG(@"Sync data: %@", packetData);
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
            self.chatLines[index] = text;
            user[@"lineNumber"] = @(-1);
        }
        else
        {
            int index = [user[@"lineNumber"] intValue];
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
        NSString *json = [self prettyPrintPacketData:packet];
        LOG(@"Received event: \"%@\"\nData: %@\n\n", packet.name, json);
    }
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
