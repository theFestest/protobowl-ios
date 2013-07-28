//
//  NSDate+FuzzyTime.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/27/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "NSDate+FuzzyTime.h"
#import "NSDate-Utilities.h"


@implementation NSDate(FuzzyTime)

+ (NSString *)fuzzyTimeSince:(NSDate *)date
{
    NSDate *today = [NSDate date];
    NSInteger minutes = [today minutesAfterDate:date];
    NSInteger hours = [today hoursAfterDate:date];
    NSInteger days = [today daysAfterDate:date];
    NSString *period;
    
    NSString *formatted = nil;
    if(days >= 365)
    {
        float years = round(days / 365) / 2.0f;
        period = (years > 1) ? @"years" : @"year";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", (int)years, period];
    }
    else if(days < 365 && days >= 30)
    {
        float months = round(days / 30) / 2.0f;
        period = (months > 1) ? @"months" : @"month";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", (int)months, period];
    }
    else if(days < 30 && days >= 2)
    {
        period = @"days";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", days, period];
    }
    else if(days == 1)
    {
        period = @"day";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", days, period];
    }
    else if(days < 1 && minutes > 60)
    {
        period = (hours > 1) ? @"hours" : @"hour";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", hours, period];
    }
    else
    {
        period = (minutes < 60 && minutes > 1) ? @"minutes" : @"minute";
        formatted = [NSString stringWithFormat:@"about %i %@ ago", minutes, period];
        if(minutes < 1)
        {
            formatted = @"a moment ago";
        }
    }
    return formatted;
}

@end
