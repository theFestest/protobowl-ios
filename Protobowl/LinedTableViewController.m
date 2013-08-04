//
//  LinedTableViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 8/3/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "LinedTableViewController.h"
#import "BuzzLogCell.h"

@interface LinedTableViewController ()
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSString *cellID;
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation LinedTableViewController

#pragma mark - Helper Methods
- (NSMutableArray *) lines
{
    if(!_lines)
    {
        _lines = [NSMutableArray array];
    }
    
    return _lines;
}

- (void) reloadTable
{
    [self.tableView reloadData];
}

#pragma mark - LinedTableViewController Interface Methods
- (instancetype) initWithCellIdentifier:(NSString *)cellID inTableView:(UITableView *)tableView
{
    if(self = [super init])
    {
        self.cellID = cellID;
        self.tableView = tableView;
    }
    return self;
}

- (void) addLine:(NSString *)string
{
    [self.lines addObject:string];
    
    [self reloadTable];
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
    
    [self reloadTable];
}


- (void) clearLines
{
    [self.lines removeAllObjects];
    
    [self reloadTable];
}

- (int) lineCount
{
    return self.lines.count;
}


- (void) setLineArray:(NSArray *)array
{
    self.lines = [array mutableCopy];
    [self reloadTable];
}

#pragma mark - Table View Data Source Methods
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lines.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellID forIndexPath:indexPath];
    if([cell isKindOfClass:[BuzzLogCell class]])
    {
        [(BuzzLogCell *)cell setBuzzLineText:self.lines[indexPath.row]];
    }
    else
    {
        cell.textLabel.text = self.lines[indexPath.row];
    }
    
    return cell;
}



@end
