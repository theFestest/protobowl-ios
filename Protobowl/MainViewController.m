
#import "MainViewController.h"
#import "SocketIOJSONSerialization.h"
#import "GuessViewController.h"
#import "iOS7ProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Donald.h"
#import "PulloutView.h"
#import "BuzzLogCell.h"
#import "LinedTableViewController.h"
#import "SideMenuViewController.h"
#import "ChatViewController.h"
#import "MBProgressHUD.h"
#import <AudioToolbox/AudioToolbox.h>

/*#define LOG(s, ...) do { \
    NSString *string = [NSString stringWithFormat:s, ## __VA_ARGS__]; \
    NSLog(@"%@", string); \
    [self logToTextView:string]; \
} while(0)*/

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *questionContainerView;
@property (nonatomic) BOOL isUserScrolling;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTextHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pulloutPositionConstraint;
@property (weak, nonatomic) IBOutlet iOS7ProgressView *timeBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *buzzButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) float lastTransitionOffset;
@property (nonatomic) BOOL isAnimating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundHorizontalSpace;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic) BOOL isNextAnimationEnabled;

@property (weak, nonatomic) IBOutlet PulloutView *scorePulloutView;
@property (nonatomic) float pulloutStartX;
@property (nonatomic) float sideMenuStartX;

@property (nonatomic) BOOL isSideMenuOnScreen;
@property (strong, nonatomic) SideMenuViewController *sideMenu;

@property (weak, nonatomic) IBOutlet UILabel *myInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *myScoreLabel;

@property (weak, nonatomic) IBOutlet UITableView *buzzLogTableView;
@property (nonatomic, strong) LinedTableViewController *buzzLogController;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (strong, nonatomic) NSString *fullQuestionText;

@property (nonatomic) BOOL isModalVCOnscreen;

@property (nonatomic, strong) UIViewController *tutorialVC;

@property (nonatomic) BOOL recentlyConnectedToRoom;
@end

@implementation MainViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.answerLabel.text = @"";
    self.timeLabel.text = @"";
    
    self.manager = [[ProtobowlConnectionManager alloc] init];
    self.manager.roomDelegate = self;
    [self.manager connectToRoom:nil];
    
    
    // Setup and stylize question text view
    self.questionContainerView.frame = CGRectMake(0, 0, self.questionContainerView.frame.size.width, 200);
    [self.questionContainerView applySinkStyleWithInnerColor:[UIColor whiteColor] borderColor:[UIColor colorWithWhite:255/255.0 alpha:1.0] borderWidth:1.0 andCornerRadius:2.0];
    
    
    // Setup timer bar
    self.timeBar.progressColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    self.timeBar.trackColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    
    // Setup next question swipe gesture
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(animateToNextQuestion)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    swipe.delegate = self;
    [self.contentView addGestureRecognizer:swipe];
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        // Setup pullout pan and tap gesture
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.scorePulloutView addGestureRecognizer:pan];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self.scorePulloutView addGestureRecognizer:tap];
        
        
        // Setup side menu view and view controller offscreen
        self.sideMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
        self.sideMenu.mainViewController = self;
        [self addChildViewController:self.sideMenu];
        
        
        UIView *sideMenuView = self.sideMenu.view;
        sideMenuView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sideMenuView];
        
        NSNumber *width = @([[UIScreen mainScreen] bounds].size.width);
        PulloutView *pulloutMenu = self.scorePulloutView;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sideMenuView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sideMenuView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[sideMenuView(width)][pulloutMenu]" options:0 metrics:NSDictionaryOfVariableBindings(width) views:NSDictionaryOfVariableBindings(sideMenuView, pulloutMenu)]];
        
        [self.view layoutIfNeeded];
        
        self.sideMenuStartX = sideMenuView.frame.origin.x;
            
        self.isSideMenuOnScreen = NO;
    }
    else
    {
        self.sideMenu = (SideMenuViewController *)(((UINavigationController *)self.splitViewController.viewControllers[0]).topViewController);
        self.sideMenu.mainViewController = self;
    }
    
    self.isUserScrolling = NO;
    
    self.buzzLogController = [[LinedTableViewController alloc] initWithCellIdentifier:@"BuzzLogCell" inTableView:self.buzzLogTableView];
    self.buzzLogTableView.dataSource = self.buzzLogController;
    self.buzzLogTableView.delegate = self.buzzLogController;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.scorePulloutView.frame.origin.x < -50 || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        // Setup pullout view layers
        [self.scorePulloutView setupLayers];
        
        // Take screenshot of main UI for use in animation
        if(self.questionTextView.text.length == 0 && self.answerLabel.text.length == 0 && self.timeLabel.text.length == 0)
        {
            self.backgroundImageView.image = [self.contentView imageSnapshot];
        }
        
        self.pulloutStartX = self.scorePulloutView.frame.origin.x;
    }
}


- (void) enableUI
{
    self.buzzButton.enabled = YES;
    self.chatButton.enabled = YES;
    self.contentView.userInteractionEnabled = YES;
}

- (void) resetUI
{
    self.questionTextView.text = @"";
    self.answerLabel.text = @"";
    self.timeBar.progress = 0;
    self.myInfoLabel.text = @"";
    self.myScoreLabel.text = @"";
    self.title = @"";
    [self.buzzLogController clearLines];
}

- (void) disableUI
{
    self.buzzButton.enabled = NO;
    self.chatButton.enabled = NO;
    
    [self resetUI];
}

#pragma mark - Connection Manager Delegate Methods
- (void) connectionManager:(ProtobowlConnectionManager *)manager didStartConnectionToRoom:(NSString *)room
{
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progress.labelText = @"Connecting";
    [self disableUI];
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didJoinLobby:(NSString *)lobby withSuccess:(BOOL)success
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(success)
    {
        NSLog(@"Connected to server");
        [self.sideMenu setRoomName:lobby];
        [self animateSideMenuOutWithDuration:0.6];
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.title = [NSString stringWithFormat:@"Room - %@", lobby];
        }
        
        
        // Present tutorial
        if(!self.manager.hasViewedTutorial)
        {
            self.tutorialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialVC0"];
            [self addChildViewController:self.tutorialVC];
            [self.view addSubview:self.tutorialVC.view];
            self.tutorialVC.view.frame = CGRectMake(0, 0, self.tutorialVC.view.frame.size.width, self.tutorialVC.view.frame.size.height);
            self.tutorialVC.view.alpha = 0.0;
            [UIView animateWithDuration:0.5 animations:^{
                self.tutorialVC.view.alpha = 1.0;
            }];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialTapped:)];
            [self.tutorialVC.view addGestureRecognizer:tap];
            self.contentView.userInteractionEnabled = NO;
            
        }
        else
        {
            double delayInSeconds = 3.0;
            self.recentlyConnectedToRoom = YES;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if(self.recentlyConnectedToRoom)
                {
                    [self.manager next];
                }
            });
            
            [self enableUI];
        }
    }
    else
    {
        NSLog(@"Failed to connect to server");
        [self disableUI];
        self.questionTextView.text = @"Failed to connect!\nDo you have an internet connection?";
    }
}

- (void) tutorialTapped:(UIGestureRecognizer *)tap
{
    int lastTutorialIndex = [[self.tutorialVC.restorationIdentifier substringFromIndex:self.tutorialVC.restorationIdentifier.length-1] intValue];
    lastTutorialIndex++;

    
    @try {
        UIViewController *nextTutorial = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"TutorialVC%d", lastTutorialIndex]];
        
        [self.tutorialVC.view removeGestureRecognizer:tap];
        [self.tutorialVC.view removeFromSuperview];
        [self.tutorialVC removeFromParentViewController];
        
        self.tutorialVC = nextTutorial;
        
        [self addChildViewController:self.tutorialVC];
        [self.view addSubview:self.tutorialVC.view];
        self.tutorialVC.view.frame = CGRectMake(0, 0, self.tutorialVC.view.frame.size.width, self.tutorialVC.view.frame.size.height);
        self.tutorialVC.view.alpha = 1.0;
        
        [self.tutorialVC.view addGestureRecognizer:tap];
    }
    @catch (NSException *exception) {
        [UIView animateWithDuration:0.5 animations:^{
            self.tutorialVC.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.tutorialVC.view removeGestureRecognizer:tap];
            [self.tutorialVC.view removeFromSuperview];
            [self.tutorialVC removeFromParentViewController];
            self.tutorialVC = nil;
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.manager next];
            });
        }];
        self.manager.hasViewedTutorial = YES;
        [self enableUI];
    }
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;
{   
    /*[self.textViewLog setLineArray:lines];
    
    CGSize textViewLogSize = [self.textViewLog.text sizeWithFont:self.textViewLog.font constrainedToSize:CGSizeMake(self.textViewLog.frame.size.width, 10000)];
    self.textViewLogHeightConstraint.constant = textViewLogSize.height + 30;*/
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateLogLines:(NSArray *)lines
{
//    [self.textViewLog setLineArray:lines];
    [self.buzzLogController setLineArray:lines];
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question
{
    self.recentlyConnectedToRoom = NO;
    
    self.fullQuestionText = question.questionText;
    
    [self layoutQuestionLabelForText:question.questionText];
    
    self.isNextAnimationEnabled = NO;
    self.isAnimating = NO;

    // Set the category
    self.answerLabel.text = question.category;
}

 - (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(self.fullQuestionText)
    {
        [self layoutQuestionLabelForText:self.fullQuestionText];
    }
}

- (void) layoutQuestionLabelForText:(NSString *)text
{
    // Calculate best font size
    float maxHeight = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? 280 : 400;
    int size = 80;
    int minSize = 14;
    float newHeight = 0;
    UIFont *newFont = nil;
    while((newHeight = [text sizeWithFont:(newFont = [UIFont fontWithName:@"HelveticaNeue" size:size--]) constrainedToSize:CGSizeMake(self.questionTextView.frame.size.width - 8, 10000)].height + 30) >= maxHeight && (size > (minSize - 1)));
    
    newHeight = MIN(newHeight, maxHeight);
    
    
    NSLog(@"Height: %f", newHeight);
    
    self.questionTextView.font = newFont;
    self.questionContainerHeightConstraint.constant = newHeight;
    
    [self.contentView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self.contentView layoutIfNeeded];
    } completion:nil];

}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text
{
//    text = @"In one scene of this play, the protagonist visits Pope Adrian VI";
    self.questionTextView.text = text;

    
    CGSize constraintSize = CGSizeMake(self.questionTextView.frame.size.width, 10000);
    CGSize targetSize = [text sizeWithFont:self.questionTextView.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByTruncatingTail];
    targetSize.height += 18;
    self.questionTextHeightConstraint.constant = targetSize.height;
    
    if(!self.isModalVCOnscreen)
    {
        self.questionContainerView.contentSize = CGSizeMake(self.questionContainerView.frame.size.width, targetSize.height);
    }
    
    if(targetSize.height > self.questionContainerView.frame.size.height && !self.questionContainerView.dragging)
    {
        self.questionContainerView.contentOffset = CGPointMake(0, targetSize.height - self.questionContainerView.frame.size.height);
    }
    [self.questionContainerView setNeedsLayout];
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateTime:(float)remainingTime progress:(float)progress
{
    NSString *timeText = [NSString stringWithFormat:@"%.1f", remainingTime];
    self.timeLabel.text = timeText;
    
    self.timeBar.progressColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
    self.timeBar.trackColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    
//    printf("question timer\n");

    [self.timeBar setProgress:progress animated:NO];
}

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateGuessTime:(float)remainingTime progress:(float)progress
{
    NSString *timeText = [NSString stringWithFormat:@"%.1f", remainingTime];
    self.timeLabel.text = timeText;
    
    self.timeBar.progressColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
    self.timeBar.trackColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0];
    
//    printf("guess timer\n");
    
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

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users
{
    // Don't care about other people's scores, but use this opportunity to update our own score
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.myInfoLabel.text = [NSString stringWithFormat:@"%@: #%d", self.manager.myself.name, self.manager.myself.rank];
        self.myScoreLabel.text = [NSString stringWithFormat:@"%d", self.manager.myself.score];
    }
    else
    {
        self.myInfoLabel.text = [NSString stringWithFormat:@"#%d: %@", self.manager.myself.rank, self.manager.myself.name];
        self.myScoreLabel.text = [NSString stringWithFormat:@"%d points", self.manager.myself.score];
    }
    
    [self.scorePulloutView layoutIfNeeded];
}


- (void) connectionManager:(ProtobowlConnectionManager *)manager didClaimBuzz:(BOOL)isClaimed
{
    if(isClaimed)
    {
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"Personal.Sound On Buzz"] boolValue])
        {
            SystemSoundID ding;
            NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"ding" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &ding);
            AudioServicesPlaySystemSound(ding);
        }
        
        [self presentGuessViewController];
    }
}

- (void) connectionManagerUserSeemsLonely:(ProtobowlConnectionManager *)manager
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feeling Lonely?" message:@"Open the left menu to change to a different room, join a public room, or invite friends!" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)buzzPressed:(id)sender
{
    [self.manager buzz];
}

- (IBAction)chatPressed:(id)sender
{
    self.modalPresentationStyle = UIModalPresentationFullScreen; // This line seems to prevent a crash bug when playing in the main lobby.  No idea why it was happening and why this fixes it  WTF!?!?!?

    ChatViewController *chatVC = [[ChatViewController alloc] init];
    chatVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    chatVC.updateChatTextCallback = ^(NSString *chat, BOOL first) {
        [self.manager chat:chat isDone:NO];
    };
    chatVC.submitChatTextCallback = ^(NSString *chat) {
        [self.manager chat:chat isDone:YES];
    };
    chatVC.doneChatCallback = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    self.manager.chatDelegate = chatVC;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatVC];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:nav animated:YES completion:nil];
}


- (void) presentGuessViewController
{
    self.modalPresentationStyle = UIModalPresentationFullScreen; // This line seems to prevent a crash bug when playing in the main lobby.  No idea why it was happening and why this fixes it  WTF!?!?!?
    
    GuessViewController *guessVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuessViewController"];
    guessVC.questionDisplayText = self.questionTextView.text;
    __weak MainViewController *weakSelf = self;
    guessVC.updateGuessTextCallback = ^(NSString *guessText) {
        [weakSelf.manager updateGuess:guessText];
    };
    guessVC.submitGuessCallback = ^(NSString *guess) {
        [weakSelf.manager submitGuess:guess];
    };
    guessVC.guessJudgedCallback = ^(BOOL correct, int scoreValue) {
        [weakSelf animateReceivedPoints:scoreValue];
    };
    guessVC.invalidBuzzCallback = ^{
        [weakSelf.manager unpauseQuestion];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    self.manager.guessDelegate = guessVC;
    
    [self presentViewController:guessVC animated:YES completion:nil];
}

- (void) presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    NSLog(@"Presenting");
    self.isModalVCOnscreen = YES;
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    NSLog(@"Dismissing");
    [super dismissViewControllerAnimated:flag completion:^{
        if(completion)
        {
            completion();
        }
        if(self)
        {
            self.isModalVCOnscreen = NO;
        }
    }];
}


- (void) animateReceivedPoints:(int)points
{
    UIColor *textColor = points > 0 ? [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0] : [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
    NSString *text = points > 0 ? [NSString stringWithFormat:@"+%d", points] : (points == 0 ? [NSString stringWithFormat:@"-%d", points] : [NSString stringWithFormat:@"%d", points]);
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:60.0];
    CGSize maxSize = [text sizeWithFont:font];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, maxSize.width, maxSize.height)];
    label.font = font;
    label.center = self.questionContainerView.center;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.text = text;
    
    UIImage *render = [label imageSnapshot];
    UIImageView *animImage = [[UIImageView alloc] initWithImage:render];
    
    CGRect afterGrowthFrame = label.frame;
    
    CGRect startGrowthFrame = afterGrowthFrame;
    startGrowthFrame.origin.x += afterGrowthFrame.size.width / 2.0;
    startGrowthFrame.origin.y += afterGrowthFrame.size.height / 2.0;
    startGrowthFrame.size = CGSizeMake(0, 0);
    
    CGRect afterMoveFrame = afterGrowthFrame;
    afterMoveFrame.size = CGSizeMake(afterMoveFrame.size.width * 0.2, afterMoveFrame.size.height * 0.2);
    
    UIView *fromView = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? self.scorePulloutView : self.contentView;
    afterMoveFrame.origin = [self.view convertPoint: self.myScoreLabel.frame.origin fromView:fromView];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        afterMoveFrame.origin.x += self.myScoreLabel.frame.size.width / 2;
        afterMoveFrame.origin.y += self.myScoreLabel.frame.size.height / 2;
    }
    
    animImage.frame = startGrowthFrame;
    
    [self.view addSubview:animImage];
    
    
    [UIView animateWithDuration:0.2 delay:0.25 options:0 animations:^{
        animImage.frame = afterGrowthFrame;
        animImage.transform = CGAffineTransformMakeRotation(-M_PI / 8.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            animImage.frame = afterMoveFrame;
            animImage.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [animImage removeFromSuperview];
        }];
    }];
    
}

#define kScrollTransitionInteractionThreshold 50
#define kScrollTransitionCompletionThreshold 60
#define kScrollTransitionBackgroundImageInset 30
- (void) animateToNextQuestion
{
    if(self.isAnimating || !self.isNextAnimationEnabled || self.isSideMenuOnScreen) return;

    __weak MainViewController *weakSelf = self;
    self.isAnimating = YES;

    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect animatedFrame = weakSelf.contentView.frame;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            animatedFrame.origin.y = -1200;
        }
        else
        {
            animatedFrame.origin.y = -600;
        }
        weakSelf.contentView.frame = animatedFrame;
    } completion:^(BOOL finished) {
        weakSelf.questionTextView.text = @"";
        weakSelf.answerLabel.text = @"";
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            weakSelf.backgroundImageView.frame = CGRectMake(0, weakSelf.topLayoutGuide.length, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height - weakSelf.topLayoutGuide.length);
        } completion:^(BOOL finished) {
            weakSelf.contentView.frame = CGRectMake(0, weakSelf.topLayoutGuide.length, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
            weakSelf.questionContainerHeightConstraint.constant = 280; // 200
            weakSelf.buzzButton.enabled = YES;
            weakSelf.buzzButton.userInteractionEnabled = NO;
            weakSelf.timeBar.progress = 0;
            weakSelf.backgroundImageView.frame = CGRectMake(kScrollTransitionBackgroundImageInset, kScrollTransitionBackgroundImageInset, weakSelf.view.frame.size.width - kScrollTransitionBackgroundImageInset*2, weakSelf.view.frame.size.height - kScrollTransitionBackgroundImageInset*2);
            [weakSelf.view layoutIfNeeded];
            
            // Trigger next question
            [weakSelf.manager next];
        }];
    }];
}

- (void) handlePan:(UIPanGestureRecognizer *)pan
{
    if(pan.view == self.scorePulloutView)
    {
        if(pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled)
        {
            float dx = self.scorePulloutView.frame.origin.x - self.pulloutStartX;
            if(dx > 180) // User has pulled enough, finish transition
            {
                [self animateSideMenuInWithDuration:0];
            }
            else // Cancel transition
            {
                [self animateSideMenuOutWithDuration:0];
            }
        }
        else
        {
            float dx = [pan translationInView:self.scorePulloutView].x;
            
            // Update pullout frame
            CGRect frame = self.scorePulloutView.frame;
            frame.origin.x += dx;
            self.scorePulloutView.frame = frame;
            
            // Update side menu frame
            frame = self.sideMenu.view.frame;
            frame.origin.x += dx;
            self.sideMenu.view.frame = frame;
        }
        [pan setTranslation:CGPointZero inView:self.scorePulloutView];
    }
    else // Handle callback from pan in Side Menu
    {
        float dx = self.sideMenu.view.frame.origin.x;
        if(pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled)
        {
            if(dx < -120) // User has pulled enough, finish transition
            {
                [self animateSideMenuOutWithDuration:0];
            }
            else // Cancel transition
            {
                [self animateSideMenuInWithDuration:0];
            }
        }
        else if(pan.state == UIGestureRecognizerStateBegan)
        {
            [self.sideMenu setFullyOnscreen:NO];
        }
        else
        {
            float dx = [pan translationInView:self.sideMenu.view].x;
            
            CGRect frame = self.sideMenu.view.frame;
            frame.origin.x += dx;
            if(frame.origin.x < 0)
            {
                // Update side menu frame
                self.sideMenu.view.frame = frame;
                
                // Update pullout frame
                frame = self.scorePulloutView.frame;
                frame.origin.x += dx * 1.5;
                self.scorePulloutView.frame = frame;
            }
        }
        
        [pan setTranslation:CGPointZero inView:self.sideMenu.view];
    }
}

- (void) tap:(UITapGestureRecognizer *)tap
{
    [self animateSideMenuInWithDuration:0.6];
}

- (void) animateSideMenuInWithDuration:(float) duration
{
    if(duration == 0) duration = 0.2;
    
    self.isSideMenuOnScreen = YES;
    
    float endX = [UIScreen mainScreen].bounds.size.width;
    self.pulloutPositionConstraint.constant = 120; // Tricks iOS into thinking it needs to update the constraints
    [self.view setNeedsUpdateConstraints];
    self.pulloutPositionConstraint.constant = endX;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL complete){
        [self.sideMenu setFullyOnscreen:YES];
    }];
}

- (void) animateSideMenuOutWithDuration:(float) duration
{
    if(duration == 0) duration = 0.2;
    
    [self.sideMenu setFullyOnscreen:NO];
    
    self.pulloutPositionConstraint.constant = 120; // Tricks iOS into thinking it needs to update the constraints
    [self.view setNeedsUpdateConstraints];
    self.pulloutPositionConstraint.constant = -180;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL complete){
        self.isSideMenuOnScreen = NO;
    }];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isUserScrolling = YES;
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isUserScrolling = NO;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if((gestureRecognizer.view == self.questionContainerView || otherGestureRecognizer.view == self.questionContainerView || gestureRecognizer.view == self.buzzLogTableView || otherGestureRecognizer.view == self.buzzLogTableView) && (gestureRecognizer.view != self.buzzLogTableView && otherGestureRecognizer.view != self.buzzLogTableView))
    {
        if(gestureRecognizer.view == self.tutorialVC.view || otherGestureRecognizer.view == self.tutorialVC.view)
        {
            return NO;
        }
        
        return YES;
    }
    return NO;
}


#pragma mark - Split View Controller Delegate Method Implementations
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Menu";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


- (id<UILayoutSupport>) topLayoutGuide
{
    @try {
        return [super topLayoutGuide];
    }
    @catch (NSException *exception) {
        return nil;
    }
    
}

@end
