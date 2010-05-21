//
//  HcodeDelegate.h
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Console.h"

@interface HcodeDelegate : NSObject <NSWindowDelegate, ConsoleDelegate> {
	IBOutlet Console *console;
	IBOutlet NSMenuItem *toggleConsoleMenu;
	IBOutlet NSMenuItem *runItem;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;
+ (HcodeDelegate*) sharedHcodeDelegate;

@property (retain) Console *console;
@property (retain) NSMenuItem *toggleConsoleMenu;
@property (retain) NSMenuItem *runItem;


- (IBAction) clearConsole: (id) sender;
- (IBAction) toggleConsole: (NSMenuItem*) sender;
@end
