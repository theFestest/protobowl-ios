
#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "ProtobowlQuestion.h"

@class ProtobowlConnectionManager;
@protocol ProtobowlConnectionDelegate <NSObject>

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

// Called when buzz input should be disabled or enabled
- (void) connectionManager:(ProtobowlConnectionManager *)manager didSetBuzzEnabled:(BOOL)isBuzzEnabled;

@end


@interface ProtobowlConnectionManager : NSObject <SocketIODelegate>

typedef void (^GuessCallback)(BOOL correct);

- (void) connect;
- (void) expireTime;
- (BOOL) buzz; // Returns if the user successfully buzzed
- (void) updateGuess:(NSString *)guess;
- (void) submitGuess:(NSString *)guess withCallback:(GuessCallback) callback;

- (void) pauseQuestion;
- (void) unpauseQuestion;

- (BOOL) next; // Returns whether or not the next command was actually executed
@property (nonatomic, weak) id<ProtobowlConnectionDelegate> delegate;

@end
