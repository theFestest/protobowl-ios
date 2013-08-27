
#import "GuessViewController.h"
#import "iOS7ProgressView.h"

#define kInitialTextViewWidthPhone 304
#define kInitialTextViewHeightPhone 198

#define kInitialTextViewWidthPad 524
#define kInitialTextViewHeightPad 496

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
    float width = 0;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        width = self.questionTextView.frame.size.width - 16;
    }
    else
    {
        width = self.questionTextView.frame.size.width - 300;
    }
    
    float height = self.questionTextView.frame.size.height;
    if(width <= 0 || height <= 0)
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            width = kInitialTextViewWidthPhone;
            height = kInitialTextViewHeightPhone;
        }
        else
        {
            width = kInitialTextViewWidthPad;
            height = kInitialTextViewHeightPad;
        }
    }
    
    CGSize constraintSize = CGSizeMake(width, 10000);
    for(int i = 36; i >= 4; i--)
    {
        UIFont *font = [UIFont systemFontOfSize:i];
        CGSize textSize = [self.questionDisplayText sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        if(textSize.height <= height - 30)
        {
            self.questionTextView.font = font;
            self.questionHeightConstraint.constant = textSize.height;
            break;
        }
    }
    
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
    guess = [guess stringByReplacingOccurrencesOfString:@"Prompt: " withString:@""];
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

- (void) connectionManager:(ProtobowlConnectionManager *)manager didJudgeGuess:(BOOL)correct withReceivedScoreValue:(int)scoreValue
{
    NSLog(@"%@", correct ? @"Correct" : @"Wrong");
    self.guessJudgedCallback(correct, scoreValue);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) connectionManagerDidReceivePrompt:(ProtobowlConnectionManager *)manager
{
    NSLog(@"Received prompt!");
    self.guessTextField.text = [NSString stringWithFormat:@"Prompt: %@", self.guessTextField.text];
}

- (void) connectionManagerDidEndBuzzTime:(ProtobowlConnectionManager *)manager
{
    self.submitGuessCallback(self.guessTextField.text);
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
