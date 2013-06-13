//
//  LinedTextView.h
//  Protobowl
//
//  Created by Donald Pinckney on 6/7/13.
//  Copyright (c) 2013 Donald Pinckney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinedTextView : UITextView
- (void) addLine:(NSString *)string;
- (int) lineCount;
- (NSString *) textOfLine:(int)line;
- (void) setText:(NSString *)text ofLine:(int)line;
- (void) clearLines;

- (void) setLineArray:(NSArray *)array;

@end
