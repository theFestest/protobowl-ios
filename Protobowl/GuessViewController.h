//
//  GuessViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 6/14/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProtobowlConnectionManager.h"

@interface GuessViewController : UIViewController <ProtobowlGuessDelegate>

typedef void (^UpdateGuessTextCallback)(NSString *guess);
typedef void (^SubmitGuessCallback)(NSString *guess);
typedef void (^GuessJudgedCallback)(BOOL correct, int value);
typedef void (^InvalidBuzzCallback)();


@property (nonatomic, strong) NSString *questionDisplayText;
@property (nonatomic, strong) UpdateGuessTextCallback updateGuessTextCallback;
@property (nonatomic, strong) SubmitGuessCallback submitGuessCallback;
@property (nonatomic, strong) GuessJudgedCallback guessJudgedCallback;
@property (nonatomic, strong) InvalidBuzzCallback invalidBuzzCallback;
@end
