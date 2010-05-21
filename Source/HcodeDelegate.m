//
//  HcodeDelegate.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//

#import "HcodeDelegate.h"
#import "SynthesizeSingleton.h"

@implementation HcodeDelegate

@synthesize console, toggleConsoleMenu, runItem;

SYNTHESIZE_SINGLETON_FOR_CLASS(HcodeDelegate)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSBundle *this = [NSBundle mainBundle];
	
	NSString *path = [this pathForResource: @"Defaults" ofType: @"plist"];
	if (!path) {
		NSLog(@"Defaults plist not found.");
		return;
	}
	
	NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile: path];
	if (!defaultsDictionary) {
		NSLog(@"Couldn't load defaults dictionary");
		return;
	}

	[defaults registerDefaults: defaultsDictionary];	
	
	
	console = [[Console alloc] initWithWindowNibName: @"Console"];
	console.delegate = self;
	
	[console log: @"Hcode Initialized"];
	
/*	consoleWindow.delegate = self;
	

	
	[consoleWindow setExcludedFromWindowsMenu: YES];
	[self.console insertText: @"Console Shown\nNext!"];
*/	
//	NSAttributedString *str = [[NSAttributedString alloc] initWithHTML: [@"<hr>" dataUsingEncoding: NSUnicodeStringEncoding] 
//													documentAttributes: NULL];
	
//	[self.console insertText: str];
 
							   
							   

}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}


/*
- (BOOL)windowDidExpose:(id) sender
{
	if (sender == consoleWindow)
		toggleConsoleMenu.title = @"Hide Console";
	
	return YES;
}

- (BOOL) windowWillClose: (id) sender
{
	if (sender == consoleWindow)
		toggleConsoleMenu.title = @"Show Console";
	
	return YES;
}
*/
- (IBAction) clearConsole: (id) sender
{
	[console clear];
}
- (IBAction) toggleConsole: (NSMenuItem*) sender
{
	if ([[console window] isVisible] == NO)
	{	// Console should be invisible now
//		[console makeKeyAndOrderFront: self];
		[console showWindow: sender];

	} else {
//		[consoleWindow performClose: self];
		[console close];
	}
}

@end
