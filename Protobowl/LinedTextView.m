
#import "LinedTextView.h"

@interface LinedTextView ()
@property (nonatomic, strong) NSMutableArray *lines;
@end

@implementation LinedTextView

- (NSMutableArray *) lines
{
    if(!_lines)
    {
        _lines = [NSMutableArray array];
    }
    
    return _lines;
}

- (void) addLine:(NSString *)string
{
    [self.lines addObject:string];
    
    [self regenTextField];
}

- (NSString *) textOfLine:(int)line
{
    if(line < 0 || line >= self.lines.count) return nil;
    
    return self.lines[line];
}

- (void) setText:(NSString *)text ofLine:(int)line
{
    if(line < 0 || line >= self.lines.count) return;
    
    self.lines[line] = text;
    
    [self regenTextField];
}

- (void) regenTextField
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    for (int i = self.lines.count-1; i >= 0; i--)
    {
        NSString *line = self.lines[i];
        [text appendFormat:@"%@\n\n", line];
    }
    
    self.text = [text copy];
}

- (void) clearLines
{
    [self.lines removeAllObjects];
    
    [self regenTextField];
}

- (int) lineCount
{
    return self.lines.count;
}


- (void) setLineArray:(NSArray *)array
{
    self.lines = [array mutableCopy];
    [self regenTextField];
}

- (CGSize) intrinsicContentSize
{
    CGSize calcSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 10000)];
    return CGSizeMake(self.frame.size.width, calcSize.height);
}

@end
