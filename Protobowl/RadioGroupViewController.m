//
//  RadioGroupViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/31/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "RadioGroupViewController.h"

@interface RadioGroupViewController ()
@property (nonatomic, strong) NSIndexPath *lastSelected;
@end

@implementation RadioGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.lastSelected = [NSIndexPath indexPathForRow:self.selection inSection:0];
    self.navigationBar.topItem.title = self.title;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadioGroupCell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    cell.textLabel.text = self.options[indexPath.row];
    
    if(indexPath.row == self.selection)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.lastSelected && [self.lastSelected isEqual:indexPath])
    {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    self.selection = indexPath.row;
    self.radioChangedCallback(self.selection);
    
    if(self.lastSelected)
    {
        [tableView reloadRowsAtIndexPaths:@[indexPath, self.lastSelected] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    self.lastSelected = indexPath;
}


- (IBAction) doneButtonPressed
{
    self.radioDoneCallback();
}


@end
