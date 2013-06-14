
#import "GuessViewController.h"

#define kInitialTextViewWidth 304
#define kInitialTextViewHeight 198

@interface GuessViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UITextField *guessTextField;
@end

@implementation GuessViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.questionTextView.text = self.questionDisplayText;
    [self resizeFont];
    [self.guessTextField becomeFirstResponder];
    self.guessTextField.delegate = self;
}


- (void)resizeFont
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
}



- (void) setQuestionDisplayText:(NSString *)text
{
    _questionDisplayText = text;
    self.questionTextView.text = text;
    
    [self resizeFont];

    
}

- (void) submitGuess:(NSString *) guess
{
    [self.manager submitGuess:guess withCallback:^(BOOL correct) {
        NSLog(@"%@", correct ? @"Correct" : @"Incorrect");
    }];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self submitGuess:textField.text];
    return YES;
}


@end
