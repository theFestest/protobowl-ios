

#import "DPLabel.h"

@implementation DPLabel

- (NSRange) findRangeOfOpeningBoldInString:(NSString *)string fromExclusiveStartPos:(int)pos
{
    if(pos == NSNotFound)
    {
        pos = -1;
    }
    return [string rangeOfString:@"<b>" options:0 range:NSMakeRange(pos+1, string.length - pos - 1)];
}

- (NSRange) findRangeOfClosingBoldInString:(NSString *)string fromExclusiveStartPos:(int)pos
{
    if(pos == NSNotFound)
    {
        pos = -1;
    }
    return [string rangeOfString:@"</b>" options:0 range:NSMakeRange(pos + 1, string.length - pos - 1)];
}

- (NSRange) findRangeOfOpeningItalicsInString:(NSString *)string fromExclusiveStartPos:(int)pos
{
    if(pos == NSNotFound)
    {
        pos = -1;
    }
    return [string rangeOfString:@"<i>" options:0 range:NSMakeRange(pos+1, string.length - pos - 1)];
}

- (NSRange) findRangeOfClosingItalicsInString:(NSString *)string fromExclusiveStartPos:(int)pos
{
    if(pos == NSNotFound)
    {
        pos = -1;
    }
    return [string rangeOfString:@"</i>" options:0 range:NSMakeRange(pos + 1, string.length - pos - 1)];
}



- (void) setText:(NSString *)text
{
    NSString *filteredString = [text stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
    filteredString = [filteredString stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
    
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:filteredString];
    
    BOOL isBoldOpen = NO;
    NSRange searchPos = NSMakeRange(NSNotFound, text.length);
    NSRange openBoldStartPos;
    int offset = -3;
    while(true)
    {
        if(isBoldOpen)
        {
            searchPos = [self findRangeOfClosingBoldInString:text fromExclusiveStartPos:searchPos.location];
            
            if(searchPos.location == NSNotFound)
            {
                break;
            }
            NSRange boldRange = NSMakeRange(openBoldStartPos.location-offset, searchPos.location - openBoldStartPos.location-3);
            [richText addAttribute:NSFontAttributeName value:self.boldFont range:boldRange];
            isBoldOpen = NO;
            offset += 4;
            
        }
        else
        {
            searchPos = [self findRangeOfOpeningBoldInString:text fromExclusiveStartPos:searchPos.location];
            if(searchPos.location == NSNotFound)
            {
                break;
            }
            openBoldStartPos = searchPos;
            isBoldOpen = YES;
            offset += 3;
        }
    }
    
    [super setAttributedText:richText];
    
}


@end