
#import "ViewController.h"
#import "SocketIOJSONSerialization.h"
#import "LinedTextView.h"
#import "GuessViewController.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "iOS7ProgressView.h"

/*#define LOG(s, ...) do { \
    NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
    NSLog(@"%@", string); \
    [self logToTextView:string]; \
} while(0)*/

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet LinedTextView *textViewLog;
@property (nonatomic, strong) ProtobowlConnectionManager *manager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLogHeightConstraint;
@property (weak, nonatomic) IBOutlet iOS7ProgressView *timeBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *buzzButton;
@property (nonatomic, strong) UISwipeGestureRecognizer *nextGesture;
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
    
    // Setup attributed string with bell glyph on buzz button
    NSString *bell = [NSString fontAwesomeIconStringForEnum:FAIconBell];
    NSString *buzzText = [NSString stringWithFormat:@"   %@ Buzz", bell];
    NSMutableAttributedString *attributedBuzzText = [[NSMutableAttributedString alloc] initWithString:buzzText];
    
    UIFont *mainTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    
    [attributedBuzzText setAttributes:@{NSFontAttributeName : mainTextFont,
                                        NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, buzzText.length)];
    [attributedBuzzText setAttributes:@{NSFontAttributeName: [UIFont iconicFontOfSize:20],
                                        NSForegroundColorAttributeName : [UIColor whiteColor]} range:[buzzText rangeOfString:bell]];
    
    [self.buzzButton setAttributedTitle:attributedBuzzText forState:UIControlStateNormal];
    
    
    self.timeBar.progressColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    self.timeBar.trackColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    
    
    self.nextGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
//    self.nextGesture.minimumNumberOfTouches = 1;
    self.nextGesture.direction = UISwipeGestureRecognizerDirectionUp;
    self.nextGesture.delegate = self;
    [self.view addGestureRecognizer:self.nextGesture];
    
    // Question BG color = #f5f5f5
    // Question Border: 1px solid #e3e3e3
}

#pragma mark - Connection Manager Delegate Methods
- (void) connectionManager:(ProtobowlConnectionManager *)manager didConnectWithSuccess:(BOOL)success
{
    if(success)
    {
//        LOG(@"Connected to server");
    }
    else
    {
//        LOG(@"Failed to connect to server");
    }
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;
{   
    /*[self.textViewLog setLineArray:lines];
    
    CGSize textViewLogSize = [self.textViewLog.text sizeWithFont:self.textViewLog.font constrainedToSize:CGSizeMake(self.textViewLog.frame.size.width, 10000)];
    self.textViewLogHeightConstraint.constant = textViewLogSize.height + 30;*/
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateBuzzLines:(NSArray *)lines
{
    [self.textViewLog setLineArray:lines];
     
     CGSize textViewLogSize = [self.textViewLog.text sizeWithFont:self.textViewLog.font constrainedToSize:CGSizeMake(self.textViewLog.frame.size.width, 10000)];
     self.textViewLogHeightConstraint.constant = textViewLogSize.height + 30;
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question
{
//    LOG(@"current height:%f", self.questionHeightConstraint.constant);
    CGSize questionSize = [question.questionText sizeWithFont:self.questionTextView.font constrainedToSize:CGSizeMake(self.questionTextView.frame.size.width - 8, 10000)];
    self.questionHeightConstraint.constant = questionSize.height + 30;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.scrollView layoutSubviews];
    } completion:nil];
    
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text
{
    self.questionTextView.text = text;
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateTime:(float)remainingTime progress:(float)progress
{
    NSString *timeText = [NSString stringWithFormat:@"%.1f", remainingTime];
    self.timeLabel.text = timeText;
    
    [self.timeBar setProgress:progress animated:NO];
}


- (void) connectionManager:(ProtobowlConnectionManager *)manager didSetBuzzEnabled:(BOOL)isBuzzEnabled
{
    self.buzzButton.enabled = isBuzzEnabled;
}
/*- (void) updateTimer
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
}*/

- (IBAction)buzzPressed:(id)sender
{
    //[self.timer invalidate];
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

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer == self.nextGesture || otherGestureRecognizer == self.nextGesture)
    {
        return YES;
    }
    return NO;
}

- (void) panGesture:(UISwipeGestureRecognizer *)pan
{
    if(pan.state == UIGestureRecognizerStateEnded)
    {
        [self gotoNextQuestion];
    }
}

- (void) gotoNextQuestion
{
    NSLog(@"Next");
    BOOL shouldTransition = [self.manager next];
}

#pragma mark - Interface Helper Methods
- (void) logToTextView:(NSString *)message
{
    [self.textViewLog addLine:message];
}

@end
