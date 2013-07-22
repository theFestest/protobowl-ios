
#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "ProtobowlQuestion.h"

@class ProtobowlConnectionManager;
@protocol ProtobowlRoomDelegate <NSObject>

// Called when the connection manager has connected, and whether it succeeded or not
- (void) connectionManager:(ProtobowlConnectionManager *)manager didConnectWithSuccess:(BOOL)success;

// Called when the text of the chat lines has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;

// Called when the text of the buzz lines has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateBuzzLines:(NSArray *)lines;

// Called when the timed display text of the question (not the actual question text) has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text;

// Called when the question has changed
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question;

// Called to update the remaining time for the question, and the progress for the progress bar
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateTime:(float)remainingTime progress:(float)progress;

- (void) connectionManager:(ProtobowlConnectionManager *)manager didEndQuestion:(ProtobowlQuestion *)question;

// Called when buzz input should be disabled or enabled
- (void) connectionManager:(ProtobowlConnectionManager *)manager didSetBuzzEnabled:(BOOL)isBuzzEnabled;

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users; // Users is an array of ProtobowlUser objects

@end


@protocol ProtobowlGuessDelegate <NSObject>

- (void) connectionManager:(ProtobowlConnectionManager *)manager didClaimBuzz:(BOOL)isClaimed; // Called when the server tells us that the client successfully buzzed, or that he / she was beat to the buzzer

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateGuessTime:(float)remainingTime progress:(float)progress;

- (void) connectionManager:(ProtobowlConnectionManager *)manager didJudgeGuess:(BOOL)correct;

- (void) connectionManagerDidEndBuzzTime:(ProtobowlConnectionManager *)manager;

@end


@protocol ProtobowlLeaderboardDelegate <NSObject>

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users; // Users is an array of ProtobowlUser objects

@end


@interface ProtobowlConnectionManager : NSObject <SocketIODelegate>

- (void) connect;
- (void) expireQuestionTime:(NSTimer *)timer;
- (BOOL) buzz; // Returns if the user successfully buzzed
- (void) updateGuess:(NSString *)guess;
- (void) submitGuess:(NSString *)guess;;

- (void) pauseQuestion;
- (void) unpauseQuestion;

- (BOOL) next; // Returns whether or not the next command was actually executed

@property (nonatomic, weak) id<ProtobowlRoomDelegate> roomDelegate;
@property (nonatomic, weak) id<ProtobowlLeaderboardDelegate> leaderboardDelegate;
@property (nonatomic, weak) id<ProtobowlGuessDelegate> guessDelegate;

@property (nonatomic, strong) NSString *myName;
@property (nonatomic) int myScore;
@property (nonatomic) int myRank;

@end
