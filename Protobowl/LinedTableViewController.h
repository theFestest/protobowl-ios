//
//  LinedTableViewController.h
//  Protobowl
//
//  Created by Donald Pinckney on 8/3/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinedTableViewController : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype) initWithCellIdentifier:(NSString *)cellID inTableView:(UITableView *)tableView;

- (void) addLine:(NSString *)string;
- (int) lineCount;
- (NSString *) textOfLine:(int)line;
- (void) setText:(NSString *)text ofLine:(int)line;
- (void) clearLines;

- (void) setLineArray:(NSArray *)array;

@end
