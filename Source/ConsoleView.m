//
//  Console.m
//  Hcode
//
//  Created by Jeffrey Drake on 10-05-11.
//  Copyright 2010 Jeffrey Drake. All rights reserved.
//
//  Credits:
//		Autoscrolling: Satoshi Matsumoto http://software.itags.org/bsd/58915/

#import "ConsoleView.h"


@implementation ConsoleView

- (void)insertText:(id)aString {
	NSTextStorage *store = [self textStorage];
//	NSCharacterSet *controlSet = [NSCharacterSet controlCharacterSet];
	
	if ([aString isKindOfClass: [NSString class]] == YES)
	{
		NSFont *fixed = [NSFont fontWithName: @"Menlo-Regular" size: 12];
		NSMutableAttributedString *addition = [[NSMutableAttributedString alloc] initWithString: aString];

		NSRange len = NSMakeRange(0, [addition length]);
		
		[addition addAttribute: NSFontAttributeName value: fixed range: len];
		
		[store appendAttributedString: addition];
	} else {
		[store appendAttributedString: aString];
	}
//	[addition appendAttributedString: [NSAttributedString ]
//	for (unichar c in aString) {
//	}
	
	// Autoscrolling
	NSUInteger length = [store length];
	
	NSRange end = {length-1, 1};
	
	[self scrollRangeToVisible: end];
}


@end
