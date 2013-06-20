
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

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) float lastTransitionOffset;
@property (nonatomic) BOOL isAnimating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundHorizontalSpace;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic) BOOL isNextAnimationEnabled;
@end

@implementation ViewController



#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [[ProtobowlConnectionManager alloc] init];
    self.manager.delegate = self;
    
    [self.manager connect];
    
    [self resizeContentSize];
    
    self.questionTextView.frame = CGRectMake(0, 0, self.questionTextView.frame.size.width, 200);
    
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
    
    
    self.scrollView.delegate = self;
    
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
    self.isNextAnimationEnabled = NO;
    
//    [self resizeContentSize];
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text
{
    self.questionTextView.text = text;
    
//    [self resizeContentSize];
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

- (void) connectionManager:(ProtobowlConnectionManager *)manager didEndQuestion:(ProtobowlQuestion *)question
{
    self.isNextAnimationEnabled = YES;
    
    [self resizeContentSize];
}


- (IBAction)buzzPressed:(id)sender
{
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


#define kScrollTransitionInteractionThreshold 50
#define kScrollTransitionCompletionThreshold 60
#define kScrollTransitionBackgroundImageInset 30
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.isAnimating || !self.isNextAnimationEnabled) return;
    
    // Calculate the maximum scroll offset for looking at normal content: only after this value do we consider transitioning
    CGPoint originalOffset = scrollView.contentOffset;
    float offsetY = originalOffset.y;
    float bottomScroll = scrollView.contentSize.height - scrollView.frame.size.height;
    if(offsetY <= bottomScroll) return;
    offsetY -= bottomScroll; // Shift offset to start at 0 from the bottom of the scroll view
    
    if(offsetY >= kScrollTransitionInteractionThreshold)
    {
        float transitionOffset = offsetY - kScrollTransitionInteractionThreshold;
        float diff = transitionOffset - self.lastTransitionOffset;
        CGRect frame = self.contentView.frame;
        frame.origin.y -= diff;
        self.contentView.frame = frame;
        
        self.lastTransitionOffset = transitionOffset;
        
        if(transitionOffset >= kScrollTransitionCompletionThreshold)
        {
            if(diff > 1)
            {
                __weak ViewController *weakSelf = self;
                self.lastTransitionOffset = 0;
                self.isAnimating = YES;
                [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    CGRect animatedFrame = frame;
                    animatedFrame.origin.y = -600;
                    weakSelf.contentView.frame = animatedFrame;
                } completion:^(BOOL finished) {
                    weakSelf.questionTextView.text = @"";
                    weakSelf.scrollView.contentOffset = CGPointMake(0, 0);
                    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        weakSelf.backgroundImageView.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
                    } completion:^(BOOL finished) {
                        weakSelf.isAnimating = NO;
                        weakSelf.contentView.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
                        weakSelf.questionHeightConstraint.constant = 200;
                        weakSelf.backgroundImageView.frame = CGRectMake(kScrollTransitionBackgroundImageInset, kScrollTransitionBackgroundImageInset, weakSelf.view.frame.size.width - kScrollTransitionBackgroundImageInset*2, weakSelf.view.frame.size.height - kScrollTransitionBackgroundImageInset*2);
                        [weakSelf.view layoutSubviews];
                        
                        // Trigger next question
                        [weakSelf.manager next];
                    }];
                }];
            }
        }
    }
}

- (void) resizeContentSize
{
    if(self.scrollView.contentSize.height < self.scrollView.frame.size.height)
    {
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 60);
    }
}

#pragma mark - Interface Helper Methods
- (void) logToTextView:(NSString *)message
{
    [self.textViewLog addLine:message];
}

@end
