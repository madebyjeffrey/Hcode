//
//  Console.h
//  Hcode
//
//  Created by Jeffrey Drake on 10-05-13.
//  Copyright 2010 Jeffrey Drake. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConsoleView.h"
#import "SynthesizeSingleton.h"

@protocol ConsoleDelegate

@property (retain) NSMenuItem *toggleConsoleMenu;

@end



@interface Console : NSWindowController {
	//IBOutlet ConsoleView *consoleView;
    //id <ConsoleDelegate> delegate;
}
@property (strong) IBOutlet ConsoleView *consoleView;
@property (unsafe_unretained) id <ConsoleDelegate> delegate;

- (void) clear;
- (void) log: (id) text;

//+ (Console*) sharedConsole;
@end
