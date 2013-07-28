//
//  ProtobowlScoring.h
//  Protobowl
//
//  Created by Donald Pinckney on 7/21/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProtobowlScoring : NSObject

- (ProtobowlScoring *) initWithScoringDictionary:(NSDictionary *)scoring;
- (int) positiveScoreValueOfType:(NSString *)type;
- (int) negativeScoreValueOfType:(NSString *)type;

- (int) calculateScoreForUser:(NSDictionary *)userData;
- (int) calculateCorrectsForUser:(NSDictionary *)userData;
- (int) calculateNegsForUser:(NSDictionary *)userData;

@end
