
#import "ViewController.h"
#import "SocketIOJSONSerialization.h"
#import "LinedTextView.h"

#define LOG(s, ...) do { \
    NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
    NSLog(@"%@", string); \
    [self logToTextView:string]; \
} while(0)

@interface ViewController ()
@property (weak, nonatomic) IBOutlet LinedTextView *textViewLog;
@property (nonatomic, strong) ProtobowlConnectionManager *manager;
@end

@implementation ViewController



#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [[ProtobowlConnectionManager alloc] init];
    self.manager.delegate = self;
    
    [self.manager connect];
}

#pragma mark - Connection Manager Delegate Methods
- (void) connectionManager:(ProtobowlConnectionManager *)manager didConnectWithSuccess:(BOOL)success
{
    if(success)
    {
        LOG(@"Connected to server");
    }
    else
    {
        LOG(@"Failed to connect to server");
    }
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;
{   
    [self.textViewLog setLineArray:lines];
}

#pragma mark - Actions
- (IBAction)clearPressed:(id)sender
{
    [self.textViewLog clearLines];
}

#pragma mark - Interface Helper Methods
- (void) logToTextView:(NSString *)message
{
    [self.textViewLog addLine:message];
}

#pragma mark - Other Helper Methods
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
