
#import "GuessViewController.h"
#import "iOS7ProgressView.h"

#define kInitialTextViewWidth 304
#define kInitialTextViewHeight 198

@interface GuessViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *questionTextView;
@property (weak, nonatomic) IBOutlet UITextField *guessTextField;
@property (weak, nonatomic) IBOutlet iOS7ProgressView *timeBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionHeightConstraint;
@end

@implementation GuessViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.questionTextView.text = self.questionDisplayText;
    [self resizeFont];
    [self.guessTextField becomeFirstResponder];
    self.guessTextField.delegate = self;
    
    
    self.timeBar.progressColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
    self.timeBar.trackColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
}


- (void) resizeFont
{
    float width = self.questionTextView.frame.size.width - 16;
    float height = self.questionTextView.frame.size.height;
    if(width <= 0 || height <= 0)
    {
        width = kInitialTextViewWidth;
        height = kInitialTextViewHeight;
    }
    
    for(int i = 24; i >= 4; i--)
    {
        UIFont *font = [UIFont systemFontOfSize:i];
        CGSize textSize = [self.questionDisplayText sizeWithFont:font constrainedToSize:CGSizeMake(width, 10000)];
        if(textSize.height <= height - 30)
        {
            self.questionTextView.font = font;
            break;
        }
    }
    
    CGSize constraintSize = CGSizeMake(width, 10000);
    CGSize targetSize = [self.questionTextView.text sizeWithFont:self.questionTextView.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    self.questionHeightConstraint.constant = targetSize.height;
    [self.view setNeedsLayout];
}

- (void) setQuestionDisplayText:(NSString *)text
{
    _questionDisplayText = text;
    self.questionTextView.text = text;
    
    [self resizeFont];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self submitGuess:textField.text];
    return YES;
}


- (void) submitGuess:(NSString *) guess
{
    self.submitGuessCallback(guess);
}

- (IBAction)guessChanged:(id)sender
{
    self.updateGuessTextCallback(self.guessTextField.text);
}


// Connection manager guess delegate callbacks
- (void) connectionManager:(ProtobowlConnectionManager *)manager didClaimBuzz:(BOOL)isClaimed
{
    if(!isClaimed)
    {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.invalidBuzzCallback();
        });
    }
    NSLog(@"Buzz claimed");
    // Start buzz timer
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateGuessTime:(float)remainingTime progress:(float)progress
{
    //NSLog(@"Time left:%g, progress:%g", remainingTime, progress);
    [self.timeBar setProgress:progress animated:NO];
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didJudgeGuess:(BOOL)correct
{
    NSLog(@"%@", correct ? @"Correct" : @"Wrong");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) connectionManagerDidEndBuzzTime:(ProtobowlConnectionManager *)manager
{
    self.submitGuessCallback(self.guessTextField.text);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) dealloc
{
    
}

@end
