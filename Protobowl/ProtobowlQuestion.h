//
//  ProtobowlQuestion.h
//  Protobowl
//
//  Created by Donald Pinckney on 6/13/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProtobowlQuestion : NSObject

@property (nonatomic, strong) NSString *qid;
@property (nonatomic, strong) NSString *answerText;
@property (nonatomic, strong) NSString *questionText;
@property (nonatomic, strong) NSString *tournament;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *difficulty;

@property (nonatomic, strong) NSArray *questionTextAsWordArray;
@property (nonatomic) float rate;
@property (nonatomic, strong) NSArray *timing;
@property (nonatomic, strong) NSMutableString *questionDisplayText;
@property (nonatomic) int questionDisplayWordIndex;

@property (nonatomic) int beginTime;
@property (nonatomic) int endTime;
@property (nonatomic) int questionDuration; // In milliseconds

@end
