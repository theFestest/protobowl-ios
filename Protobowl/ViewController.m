
#import "ViewController.h"
#import "SocketIOJSONSerialization.h"
#import "LinedTextView.h"
#import "GuessViewController.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "iOS7ProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+ImageSnapshot.h"
#import "PulloutView.h"

/*#define LOG(s, ...) do { \
    NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
    NSLog(@"%@", string); \
    [self logToTextView:string]; \
} while(0)*/

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet LinedTextView *textViewLog;
@property (nonatomic, strong) ProtobowlConnectionManager *manager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionHeightConstraint;
@property (weak, nonatomic) IBOutlet iOS7ProgressView *timeBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *buzzButton;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet PulloutView *scoreSlideView;

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
    
    self.answerLabel.text = @"";
    self.timeLabel.text = @"";
    
    self.manager = [[ProtobowlConnectionManager alloc] init];
    self.manager.roomDelegate = self;
    
    [self.manager connect];
        
    self.questionTextView.frame = CGRectMake(0, 0, self.questionTextView.frame.size.width, 200);
    self.questionTextView.layer.borderWidth = 1.0;
    self.questionTextView.layer.borderColor = [[UIColor colorWithWhite:227/255.0 alpha:1.0] CGColor];
    self.questionTextView.layer.cornerRadius = 10.0;
    
    
    // Setup attributed string with bell glyph on buzz button
    NSString *bell = [NSString fontAwesomeIconStringForEnum:FAIconBell];
    NSString *buzzText = [NSString stringWithFormat:@"   %@ Buzz", bell];
    NSMutableAttributedString *attributedBuzzText = [[NSMutableAttributedString alloc] initWithString:buzzText];
    
    UIFont *buzzFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    
    [attributedBuzzText setAttributes:@{NSFontAttributeName : buzzFont,
                                        NSForegroundColorAttributeName : [UIColor whiteColor]} range:NSMakeRange(0, buzzText.length)];
    [attributedBuzzText setAttributes:@{NSFontAttributeName: [UIFont iconicFontOfSize:20],
                                        NSForegroundColorAttributeName : [UIColor whiteColor]} range:[buzzText rangeOfString:bell]];
    
    [self.buzzButton setAttributedTitle:attributedBuzzText forState:UIControlStateNormal];
    
    
    self.timeBar.progressColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    self.timeBar.trackColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(animateToNextQuestion)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipe];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scoreSlideView setupLayers];
    
    if(self.questionTextView.text.length == 0 && self.answerLabel.text.length == 0 && self.timeLabel.text.length == 0)
    {
        self.backgroundImageView.image = [self.contentView imageSnapshot];
    }
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
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question
{
    // Calculate best font size
    float maxHeight = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 280 : 400;
    int size = 80;
    float newHeight = 0;
    UIFont *newFont = nil;
    while((newHeight = [question.questionText sizeWithFont:(newFont = [UIFont fontWithName:@"HelveticaNeue" size:size--]) constrainedToSize:CGSizeMake(self.questionTextView.frame.size.width - 8, 10000)].height + 30) >= maxHeight);
    
    
    NSLog(@"Size: %f", newFont.pointSize);
    
    self.questionTextView.font = newFont;
    self.questionHeightConstraint.constant = newHeight;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.contentView layoutSubviews];
    } completion:nil];
    self.isNextAnimationEnabled = NO;
    self.isAnimating = NO;

    
    // Set the category
    self.answerLabel.text = question.category;
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
    self.buzzButton.userInteractionEnabled = isBuzzEnabled;
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didEndQuestion:(ProtobowlQuestion *)question
{
    self.isNextAnimationEnabled = YES;
    
    NSString *answerWithRemovedComments = question.answerText;
    int leftBracketIndex = [answerWithRemovedComments rangeOfString:@"["].location;
    if(leftBracketIndex != NSNotFound)
    {
        answerWithRemovedComments = [answerWithRemovedComments substringToIndex:leftBracketIndex];
    }
    
    int leftParenIndex = [answerWithRemovedComments rangeOfString:@"("].location;
    if(leftParenIndex != NSNotFound)
    {
        answerWithRemovedComments = [answerWithRemovedComments substringToIndex:leftParenIndex];
    }
    
    answerWithRemovedComments = [answerWithRemovedComments stringByReplacingOccurrencesOfString:@"{" withString:@""];
    answerWithRemovedComments = [answerWithRemovedComments stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    answerWithRemovedComments = [answerWithRemovedComments stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];


    self.answerLabel.text = answerWithRemovedComments;
}


- (IBAction)buzzPressed:(id)sender
{
    [self.manager buzz];
    
    [self presentGuessViewController];
}

- (void) presentGuessViewController
{
    GuessViewController *guessVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuessViewController"];
    guessVC.questionDisplayText = self.questionTextView.text;
    __weak ViewController *weakSelf = self;
    guessVC.updateGuessTextCallback = ^(NSString *guessText) {
        [weakSelf.manager updateGuess:guessText];
    };
    guessVC.submitGuessCallback = ^(NSString *guess) {
        [weakSelf.manager submitGuess:guess];
    };
    guessVC.invalidBuzzCallback = ^{
        [weakSelf.manager unpauseQuestion];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    self.manager.guessDelegate = guessVC;
    
    [self presentViewController:guessVC animated:YES completion:nil];
}

#define kScrollTransitionInteractionThreshold 50
#define kScrollTransitionCompletionThreshold 60
#define kScrollTransitionBackgroundImageInset 30
- (void) animateToNextQuestion
{
    if(self.isAnimating || !self.isNextAnimationEnabled) return;

    __weak ViewController *weakSelf = self;
    self.isAnimating = YES;

    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect animatedFrame = weakSelf.contentView.frame;
        animatedFrame.origin.y = -600;
        weakSelf.contentView.frame = animatedFrame;
    } completion:^(BOOL finished) {
        weakSelf.questionTextView.text = @"";
        weakSelf.answerLabel.text = @"";
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            weakSelf.backgroundImageView.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        } completion:^(BOOL finished) {
            weakSelf.contentView.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
            weakSelf.questionHeightConstraint.constant = 200;
            weakSelf.buzzButton.enabled = YES;
            weakSelf.buzzButton.userInteractionEnabled = NO;
            weakSelf.timeBar.progress = 0;
            weakSelf.backgroundImageView.frame = CGRectMake(kScrollTransitionBackgroundImageInset, kScrollTransitionBackgroundImageInset, weakSelf.view.frame.size.width - kScrollTransitionBackgroundImageInset*2, weakSelf.view.frame.size.height - kScrollTransitionBackgroundImageInset*2);
            [weakSelf.view layoutSubviews];
            
            // Trigger next question
            [weakSelf.manager next];
        }];
    }];
}




#pragma mark - Interface Helper Methods
- (void) logToTextView:(NSString *)message
{
    [self.textViewLog addLine:message];
}

@end
