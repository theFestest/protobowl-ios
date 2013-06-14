
#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "ProtobowlQuestion.h"

@class ProtobowlConnectionManager;
@protocol ProtobowlConnectionDelegate <NSObject>

// Called when the connection manager has connected, and whether it succeeded or not
- (void) connectionManager:(ProtobowlConnectionManager *)manager didConnectWithSuccess:(BOOL)success;

// Called when the text of the chat lines has beenupdated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;


// Called when the timed display text of the question (not the actual question text) has been updated
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestionDisplayText:(NSString *)text;

// Called when the question has changed
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateQuestion:(ProtobowlQuestion *)question;

@end


@interface ProtobowlConnectionManager : NSObject <SocketIODelegate>

typedef void (^GuessCallback)(BOOL correct);

- (void) connect;
- (void) expireTime;
- (BOOL) buzz; // Returns if the user successfully buzzed
- (void) submitGuess:(NSString *)guess withCallback:(GuessCallback) callback;

@property (nonatomic, weak) id<ProtobowlConnectionDelegate> delegate;

@end
