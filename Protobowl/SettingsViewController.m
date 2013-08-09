//
//  SideMenuViewController.m
//  Protobowl
//
//  Created by Donald Pinckney on 7/20/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIView+Donald.h"
#import "UIColor+MoreConstructors.h"
#import "SwitchCell.h"
#import "RadioCell.h"
#import "ActionCell.h"
#import "NSDictionary+MutableDeepCopy.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#define kLeaderboardCellHeight 44
#define kLeaderboardDetailCellHeight 180


NSString *SettingsCellTypeBool = @"SettingsCellTypeBool";
NSString *SettingsCellTypeRadio = @"SettingsCellTypeRadio";
NSString *SettingsCellTypeAction = @"SettingsCellTypeAction";

@interface SettingsCellDescriptor : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic) NSString *type;
@end

@implementation SettingsCellDescriptor
@end


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic) int groupCount;
@property (nonatomic, strong) NSMutableDictionary *rootDict;
@end

@implementation SettingsViewController
@synthesize sideMenuViewController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.sideMenuViewController reloadTableView];
    
    self.settingsTableView.clipsToBounds = NO;
}

- (float) expandedHeight
{
    return 480;
}


- (void) setupWithPlistPath:(NSString *)path
{
    self.filePath = path;
    
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
    self.rootDict = [rootDict mutableDeepCopy];
    
    [self.settingsTableView reloadData];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *groupKey = self.rootDict[@"GroupOrder"][section];
    NSDictionary *groupDict = self.rootDict[groupKey];
    NSArray *rowOrder = groupDict[@"RowOrder"];
    
    return rowOrder.count;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *groupOrder = self.rootDict[@"GroupOrder"];
    return groupOrder.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *groupKey = self.rootDict[@"GroupOrder"][section];
    return groupKey;
}

#define kValuePathKey @"ValuePathKey"
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *groupKey = self.rootDict[@"GroupOrder"][indexPath.section];
    NSDictionary *groupDict = self.rootDict[groupKey];
    NSArray *rowOrder = groupDict[@"RowOrder"];
    NSString *rowKey = rowOrder[indexPath.row];
    NSDictionary *row = groupDict[rowKey];
    
    NSString *rowType = row[@"SettingsCellType"];
    UITableViewCell *cell = nil;
    NSString *rowKeyPath = [NSString stringWithFormat:@"%@.%@", groupKey, rowKey];
    if([rowType isEqualToString:SettingsCellTypeBool])
    {
        NSNumber *objVal = [[NSUserDefaults standardUserDefaults] objectForKey:rowKeyPath];
        BOOL value;
        if([rowKeyPath isEqualToString:@"Room.Show Bonus Questions"])
        {
            value = self.sideMenuViewController.mainViewController.manager.showBonusQuestions;
        }
        else if([rowKeyPath isEqualToString:@"Room.Allow Multiple Buzzes"])
        {
            value = self.sideMenuViewController.mainViewController.manager.allowMultipleBuzzes;
        }
        else if([rowKeyPath isEqualToString:@"Room.Allow Question Skipping"])
        {
            value = self.sideMenuViewController.mainViewController.manager.allowSkip;
        }
        else if(objVal)
        {
            value = [objVal boolValue];
        }
        else
        {
            value = [row[@"value"] boolValue];
        }
        cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        ((SwitchCell *)cell).titleLabel.text = rowKey;
//        ((SwitchCell *)cell).switchControl.on = value;
        [((SwitchCell *)cell).switchControl setOn:value animated:YES];
        
        [((SwitchCell *)cell).switchControl addTarget:self action:@selector(cellSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        objc_setAssociatedObject(((SwitchCell *)cell).switchControl, kValuePathKey, rowKeyPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else if([rowType isEqualToString:SettingsCellTypeRadio])
    {
        NSArray *options = row[@"options"];
        NSNumber *objVal = [[NSUserDefaults standardUserDefaults] objectForKey:rowKeyPath];
        int value;
        if([rowKeyPath isEqualToString:@"Room.Difficulty"])
        {
            NSString *difficulty = self.sideMenuViewController.mainViewController.manager.currentDifficulty;
            value = [options indexOfObject:difficulty];
        }
        else if([rowKeyPath isEqualToString:@"Room.Categories"])
        {
            NSString *category = self.sideMenuViewController.mainViewController.manager.currentCategory;
            value = [options indexOfObject:category];
        }
        else if(objVal)
        {
            value = [objVal intValue];
            if(value >= options.count)
            {
                value = [row[@"value"] intValue];
            }
        }
        else
        {
            value = [row[@"value"] intValue];
        }
        
        NSString *selectionString = nil;
        if(value != NSNotFound)
        {
            selectionString = options[value];
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"RadioCell" forIndexPath:indexPath];
        ((RadioCell *)cell).titleLabel.text = rowKey;
        ((RadioCell *)cell).selection = value;
        ((RadioCell *)cell).keyPath = rowKeyPath;
        ((RadioCell *)cell).options = options;
        ((RadioCell *)cell).subtitleLabel.text = selectionString;
        ((RadioCell *)cell).radioChangedCallback = ^(int selection){
            [self cellRadioChanged:selection selectionString:options[selection] key:rowKeyPath];
        };
        ((RadioCell *)cell).referenceViewController = self.sideMenuViewController;
    }
    else if([rowType isEqualToString:SettingsCellTypeAction])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
        ((ActionCell *)cell).titleLabel.text = rowKey;
        ((ActionCell *)cell).callback = ^(ActionCell *actionCell){
            [self cellActionTriggered:rowKeyPath cell:actionCell];
        };
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (void) cellSwitchChanged:(UISwitch *)sw
{
    NSString *rowKeyPath = objc_getAssociatedObject(sw, kValuePathKey);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:sw.isOn] forKey:rowKeyPath];
    [defaults synchronize];
    
    if([rowKeyPath isEqualToString:@"Room.Show Bonus Questions"])
    {
        self.sideMenuViewController.mainViewController.manager.showBonusQuestions = sw.isOn;
    }
    else if([rowKeyPath isEqualToString:@"Room.Allow Multiple Buzzes"])
    {
        self.sideMenuViewController.mainViewController.manager.allowMultipleBuzzes = sw.isOn;
    }
    else if([rowKeyPath isEqualToString:@"Room.Allow Question Skipping"])
    {
        self.sideMenuViewController.mainViewController.manager.allowSkip = sw.isOn;
    }
    NSLog(@"Switch path: %@", rowKeyPath);
}

- (void) cellRadioChanged:(int)selection selectionString:(NSString *)selectionString key:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:selection] forKey:key];
    [defaults synchronize];
    NSLog(@"Radio path: %@", key);
    
    [self.settingsTableView reloadData];
    
    
    if([key isEqualToString:@"Room.Difficulty"])
    {
        self.sideMenuViewController.mainViewController.manager.currentDifficulty = selectionString;
    }
    else if([key isEqualToString:@"Room.Categories"])
    {
        self.sideMenuViewController.mainViewController.manager.currentCategory = selectionString;
    }
}

- (void) cellActionTriggered:(NSString *)key cell:(ActionCell *)cell
{
    NSLog(@"Action path: %@", key);
    if([key isEqualToString:@"Personal.Reset Score"])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Reset score to 0 points" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Score" otherButtonTitles:nil];
        [actionSheet showFromRect:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) inView:cell animated:YES];
    }
}

- (void) resetScore
{
    NSLog(@"Resetting score!!!");
    [self.sideMenuViewController.mainViewController.manager resetScore];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self resetScore];
    }
}


- (void) connectionManagerDidChangeRoomSetting:(ProtobowlConnectionManager *)manager
{
    [self.settingsTableView reloadData];
}

@end