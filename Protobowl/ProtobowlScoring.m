//
//  ProtobowlScoring.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/21/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "ProtobowlScoring.h"

@interface ProtobowlScoring ()
@property (nonatomic, strong) NSMutableDictionary *positiveValues;
@property (nonatomic, strong) NSMutableDictionary *negativeValues;
@end

@implementation ProtobowlScoring

- (ProtobowlScoring *) initWithScoringDictionary:(NSDictionary *)scoring
{
    self = [super init];
    if(self)
    {
        self.positiveValues = [NSMutableDictionary dictionaryWithCapacity:scoring.count];
        self.negativeValues = [NSMutableDictionary dictionaryWithCapacity:scoring.count];
        
        for (NSString *type in scoring)
        {
            NSArray *values = scoring[type];
            self.positiveValues[type] = values[0];
            self.negativeValues[type] = values[1];
        }
    }
    return self;
}

- (int) positiveScoreValueOfType:(NSString *)type
{
    return [self.positiveValues[type] intValue];
}

- (int) negativeScoreValueOfType:(NSString *)type // This returns a negative number!
{
    return [self.negativeValues[type] intValue];
}



- (int) calculateScoreForUser:(NSDictionary *)userData
{
    NSDictionary *corrects = userData[@"corrects"];
    NSDictionary *wrongs = userData[@"wrongs"];
    
    int score = 0;
    for (NSString *type in corrects)
    {
        int answerCount = [corrects[type] intValue];
        score += answerCount * [self positiveScoreValueOfType:type];
    }
    
    for (NSString *type in wrongs)
    {
        int answerCount = [wrongs[type] intValue];
        score += answerCount * [self negativeScoreValueOfType:type];
    }
    
    return score;
}

- (int) calculateCorrectsForUser:(NSDictionary *)userData
{
    NSDictionary *corrects = userData[@"corrects"];
    
    int correctsCount = 0;
    for (NSString *type in corrects)
    {
        correctsCount += [corrects[type] intValue];
    }
    
    return correctsCount;
}

- (int) calculateNegsForUser:(NSDictionary *)userData
{
    NSDictionary *wrongs = userData[@"wrongs"];
    
    int negs = 0;
    for (NSString *type in wrongs)
    {
        int value = [self negativeScoreValueOfType:type];
        if(value != 0)
        {
            int answerCount = [wrongs[type] intValue];
            negs += answerCount;
        }
    }
    
    return negs;
}

@end
