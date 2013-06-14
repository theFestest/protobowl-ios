
#import "ViewController.h"
#import "SocketIOJSONSerialization.h"
#import "LinedTextView.h"
#import "GuessViewController.h"

#define kTimerInterval 0.05f

#define LOG(s, ...) do { \
    NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
    NSLog(@"%@", string); \
    [self logToTextView:string]; \
} while(0)

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet LinedTextView *textViewLog;
@property (nonatomic, strong) ProtobowlConnectionManager *manager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLogHeightConstraint;
@property (weak, nonatomic) IBOutlet UIProgressView *timeBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) float elapsedTime;
@property (nonatomic) float duration;
@end

@implementation ViewController



#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [[ProtobowlConnectionManager alloc] init];
    self.manager.delegate = self;
    
    [self.manager connect];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 10000);
    
    self.questionTextView.frame = CGRectMake(0, 0, self.questionTextView.frame.size.width, 300);

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
    
    CGSize textViewLogSize = [self.textViewLog.text sizeWithFont:self.textViewLog.font constrainedToSize:CGSizeMake(self.textViewLog.frame.size.width, 10000)];
    self.textViewLogHeightConstraint.constant = textViewLogSize.height + 30;
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question
{
    LOG(@"current height:%f", self.questionHeightConstraint.constant);
    CGSize questionSize = [question.questionText sizeWithFont:self.questionTextView.font constrainedToSize:CGSizeMake(self.questionTextView.frame.size.width - 8, 10000)];
    self.questionHeightConstraint.constant = questionSize.height + 30;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.scrollView layoutSubviews];
    } completion:nil];
    
    // Super sketch method to animate the progress bar with a custom time interval
    self.timeBar.progress = 0;
    self.elapsedTime = 0;
    self.duration = question.questionDuration / 1000.0f;
    self.timer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text
{
    self.questionTextView.text = text;
}

- (void) updateTimer
{
    self.elapsedTime += kTimerInterval;
    
    float remaining = MAX(self.duration - self.elapsedTime, 0);
    NSString *timeText = [NSString stringWithFormat:@"%.1f", remaining];
    self.timeLabel.text = timeText;
    
    float progress = self.elapsedTime / self.duration;
    [self.timeBar setProgress:progress animated:NO];
    if(progress >= 1.0)
    {
        // Done with the question
        [self.manager expireTime];
        [self.timer invalidate];
    }
}

- (IBAction)buzzPressed:(id)sender
{
    [self.timer invalidate];
    [self.manager buzz];
    
    [self presentGuessViewController];
}

- (void) presentGuessViewController
{
    GuessViewController *toVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuessViewController"];
    toVC.questionDisplayText = self.questionTextView.text;
    toVC.manager = self.manager;
    [self presentViewController:toVC animated:YES completion:^{
//        [toVC resizeFont];
    }];
}

#pragma mark - Interface Helper Methods
- (void) logToTextView:(NSString *)message
{
    [self.textViewLog addLine:message];
}

@end
