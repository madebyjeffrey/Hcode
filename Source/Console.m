//
//  Console.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-05-13.
//  Copyright 2010 Jeffrey Drake. All rights reserved.
//

#import "Console.h"

@implementation Console

@synthesize consoleView, delegate;

//SYNTHESIZE_SINGLETON_FOR_CLASS(Console);

/*
- (void)windowDidLoad
{
}*/

- (IBAction)showWindow:(id)sender
{
	[super showWindow: sender];
	[[delegate toggleConsoleMenu] setTitle: @"Hide Console"];
}


- (void) windowWillClose: (NSNotification*) notification
{
	NSLog(@"Close");
	
	[[delegate toggleConsoleMenu] setTitle:@"Show Console"];
}

- (void) clear
{
	[[[consoleView textStorage] mutableString] setString: @""];
}

- (void) log: (id) text
{
	[consoleView insertText: text];
}
@end
