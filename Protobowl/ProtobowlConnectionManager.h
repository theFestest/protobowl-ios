
#import <Foundation/Foundation.h>
#import "SocketIO.h"

@class ProtobowlConnectionManager;
@protocol ProtobowlConnectionDelegate <NSObject>

- (void) connectionManager:(ProtobowlConnectionManager *)manager didConnectWithSuccess:(BOOL)success;
- (void) connectionManager:(ProtobowlConnectionManager *)manager didUpdateChatLines:(NSArray *)lines;

@end


@interface ProtobowlConnectionManager : NSObject <SocketIODelegate>

- (void) connect;

@property (nonatomic, weak) id<ProtobowlConnectionDelegate> delegate;

@end
