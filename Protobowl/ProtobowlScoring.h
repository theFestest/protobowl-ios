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
- (int) positiveScoreOfType:(NSString *)type;
- (int) negativeScoreOfType:(NSString *)type;

@end
