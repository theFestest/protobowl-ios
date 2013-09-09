
#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "ProtobowlQuestion.h"
#import "ProtobowlUser.h"

@class ProtobowlConnectionManager;
@protocol ProtobowlRoomDelegate <NSObject>

- (void) connectionManagerDidStartConnection:(ProtobowlConnectionManager *)manager;

// Called when the connection manager has connected, and whether it succeeded or not
- (void) connectionManager:(ProtobowlConnectionManager *)manager didJoinLobby:(NSString *)lobby withSuccess:(BOOL)success;

// Called when the text of the chat lines has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;

// Called when the text of the buzz lines has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateLogLines:(NSArray *)lines;

// Called when the timed display text of the question (not the actual question text) has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text;

// Called when the question has changed
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question;

// Called to update the remaining time for the question, and the progress for the progress bar
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateTime:(float)remainingTime progress:(float)progress;
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateGuessTime:(float)remainingTime progress:(float)progress;

- (void) connectionManager:(ProtobowlConnectionManager *)manager didEndQuestion:(ProtobowlQuestion *)question;

// Called when buzz input should be disabled or enabled
- (void) connectionManager:(ProtobowlConnectionManager *)manager didSetBuzzEnabled:(BOOL)isBuzzEnabled;

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users; // Users is an array of ProtobowlUser objects

- (void) connectionManager:(ProtobowlConnectionManager *)manager didClaimBuzz:(BOOL)isClaimed; // Called when the server tells us that the client successfully buzzed, or that he / she was beat to the buzzer


@end


@protocol ProtobowlGuessDelegate <NSObject>

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateGuessTime:(float)remainingTime progress:(float)progress;

- (void) connectionManager:(ProtobowlConnectionManager *)manager didJudgeGuess:(BOOL)correct withReceivedScoreValue:(int)scoreValue;
- (void) connectionManagerDidReceivePrompt:(ProtobowlConnectionManager *)manager;

- (void) connectionManagerDidEndBuzzTime:(ProtobowlConnectionManager *)manager;

@end


@protocol ProtobowlLeaderboardDelegate <NSObject>

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateUsers:(NSArray *)users inRoom:(NSString *)roomName; // Users is an array of ProtobowlUser objects

@end

@protocol ProtobowlSettingsDelegate <NSObject>

- (void) connectionManagerDidChangeRoomSetting:(ProtobowlConnectionManager *)manager;

@end


@protocol ProtobowlChatDelegate <NSObject>

- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines inRoom:(NSString *)roomName;

@end



@interface ProtobowlConnectionManager : NSObject <SocketIODelegate>

- (void) connectToRoom:(NSString *)room; // pass nil for room to join most recent room

- (void) expireQuestionTime:(NSTimer *)timer;
- (BOOL) buzz; // Returns if the user successfully buzzed
- (void) updateGuess:(NSString *)guess;
- (void) submitGuess:(NSString *)guess;

- (void) chat:(NSString *)chatText isDone:(BOOL)done;

- (void) pauseQuestion;
- (void) unpauseQuestion;

- (BOOL) next; // Returns whether or not the next command was actually executed

- (void) changeMyName:(NSString *)name;
- (void) resetScore;

- (void) outputUsersToLeaderboardDelegate;

- (void) saveReconnectData;
- (void) reconnectIfNeeded;

- (void) fetchPublicRoomDataWithCallback:(void (^)(NSArray *rooms))callback;

+ (void) saveServerListToDisk;


// Room settings and info
@property (nonatomic, strong) NSString *currentDifficulty;
@property (nonatomic, strong) NSString *currentCategory;
@property (nonatomic, readonly) NSString *currentRoomName;
@property (nonatomic) BOOL showBonusQuestions;
@property (nonatomic) BOOL allowSkip;
@property (nonatomic) BOOL allowMultipleBuzzes;
@property (nonatomic, strong) ProtobowlUser *myself;

@property (nonatomic) BOOL hasViewedTutorial;


// Delegates
@property (nonatomic, weak) id<ProtobowlRoomDelegate> roomDelegate;
@property (nonatomic, weak) id<ProtobowlLeaderboardDelegate> leaderboardDelegate;
@property (nonatomic, weak) id<ProtobowlGuessDelegate> guessDelegate;
@property (nonatomic, weak) id<ProtobowlSettingsDelegate> settingsDelegate;
@property (nonatomic, weak) id<ProtobowlChatDelegate> chatDelegate;




@end
