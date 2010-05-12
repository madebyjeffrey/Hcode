//
//  HcodeDelegate.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-04-16.
//  Copyright 2010 N/A. All rights reserved.
//

#import "HcodeDelegate.h"


@implementation HcodeDelegate

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
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

@end
