//
//  CodeView.m
//  Hcode/CodeView
//
//  Created by Jeffrey Drake on 10-04-17.
//  Copyright (c) 2010 by Jeffrey Drake. All rights reserved.
//
//	Some portions adapted from NoodleKit and are
//  Copyright (c) 2008 Noodlesoft, LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "CodeView.h"

@interface NSString (Plus)


- (NSRange) rangeOfCharactersFromSet: (NSCharacterSet*) cs range: (NSRange) range;
@end

@implementation NSString (Plus)

- (NSRange) rangeOfCharactersFromSet: (NSCharacterSet*) cs range: (NSRange) range {
	NSRange r;
	
	r.location = NSNotFound;
	r.length = 0;
	
	for (int i = range.location; i < range.location + range.length; i++) {
		if ([cs characterIsMember: [self characterAtIndex: i]]) {
			r.location = range.location;
			continue;
		} else {
			r.length = i - range.location;
			break;
		}
	}
	return r;
}

@end



@interface CodeView (Private)
- (void)calculateLines;
@end

@implementation CodeView

- (id) init {
	self = [super init];
	
	NSLog(@"CodeView init");
	
	return self;
}

- (void) awakeFromNib
{
	NSLog(@"CodeView awake");
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(textDidChange:) 
												 name:NSTextStorageDidProcessEditingNotification 
											   object:[self textStorage]];
	
}

- (NSMutableArray *)lineIndices
{
	if (_lineIndices == nil)
	{
		[self calculateLines];
	}
	return _lineIndices;
}

- (void)invalidateLineIndices
{
	[_lineIndices release];
	_lineIndices = nil;
}

- (void)textDidChange:(NSNotification *)notification
{
	// Invalidate the line indices. They will be recalculated and recached on demand.
	[self invalidateLineIndices];
	
    [self setNeedsDisplay:YES];
}

- (void)calculateLines
{
	NSUInteger      index, numberOfLines, stringLength, lineEnd, contentEnd;
	NSString        *text;
	
	text = [self string];
	stringLength = [text length];
	[_lineIndices release];
	_lineIndices = [[NSMutableArray alloc] init];
	
	index = 0;
	numberOfLines = 0;
	
	do {
		[_lineIndices addObject:[NSNumber numberWithUnsignedInteger:index]];
		
		index = NSMaxRange([text lineRangeForRange:NSMakeRange(index, 0)]);
		numberOfLines++;
	} while (index < stringLength);
	
	// Check if text ends with a new line.
	[text getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([[_lineIndices lastObject] unsignedIntegerValue], 0)];
	if (contentEnd < lineEnd)
	{
		[_lineIndices addObject:[NSNumber numberWithUnsignedInteger:index]];
	}
}

- (NSUInteger) column {
	
	// Cursor index most top left
	NSArray *ranges = [self selectedRanges];
	NSUInteger cursor_index = [[ranges objectAtIndex: 0] rangeValue].location;
	
	NSString *doc = [[self textStorage] string];
	// Line we are on
	NSRange whole_line = [doc lineRangeForRange: NSMakeRange(cursor_index, 0)];
	
	return cursor_index - whole_line.location;
}

- (NSUInteger) line {
	// Always return the location of the top left most part of a selection
	NSRange range = [[[self selectedRanges] objectAtIndex: 0] rangeValue];
	
	return [self lineNumberForCharacterIndex: range.location];
}

- (NSUInteger) characterIndexForLine: (NSUInteger) line
{
	NSMutableArray *lines = [self lineIndices];
	
	NSNumber *n = [lines objectAtIndex: line];
	
	return [n unsignedIntValue];
}

- (NSUInteger)lineNumberForCharacterIndex:(NSUInteger)index {
	NSUInteger			left, right, mid, lineStart;
	NSMutableArray		*lines;
	
	lines = [self lineIndices];
	
	// Binary search
	left = 0;
	right = [lines count];
	
	while ((right - left) > 1) {
		mid = (right + left) / 2;
		lineStart = [[lines objectAtIndex:mid] unsignedIntegerValue];
		
		if (index < lineStart) {
			right = mid;
		} else if (index > lineStart) {
			left = mid;
		} else {
			return mid;
		}
	}
	return left;
}

- (NSArray*)lineNumbersForRange: (NSRange)range {
	NSUInteger start = [self lineNumberForCharacterIndex: range.location];
	NSUInteger end = [self lineNumberForCharacterIndex: range.location + range.length];

	// This code returns the line indices, not the line numbers
//	return [[self lineIndices] subarrayWithRange: NSMakeRange(start, end-start+1)];
	
	NSMutableArray *lineNos = [NSMutableArray arrayWithCapacity: end-start+1];
	
	for (NSUInteger i = start; i <= end; i++) {
		[lineNos addObject: [NSNumber numberWithUnsignedInteger: i]];
	}
	
	return lineNos;
}

- (void) insertTab: (id) sender {
	NSUInteger n = (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey: @"spacesPerTab"];
	n = MIN(n, 9);
	
	NSUInteger column = [self column];
	NSUInteger insert = n - column % n;
	unichar str[5];
	
	[@"           " getCharacters: str range: NSMakeRange(0, n)];
	
	[self insertText: [NSString stringWithCharacters: str length: insert]]; 
}

- (void) insertNewline: (id) sender {
	BOOL autoIndent = [[NSUserDefaults standardUserDefaults] boolForKey: @"autoIndent"];
	
	NSArray *ranges = [self selectedRanges];
	
	// Note, behaviour matches xcode as best observed.
	
	// Obtain the left most location selected
	NSUInteger cursor_index = [[ranges objectAtIndex: 0] rangeValue].location;
	
	// Make faux range to get the text for the line it is on
	NSRange single_range = NSMakeRange(cursor_index, 0);
	NSString *doc = [[self textStorage] string];
	NSRange whole_line = [doc lineRangeForRange: single_range];
	NSString *line = [doc substringWithRange: whole_line];
	
	// Find out how many spaces are preceeding the text on that line
	int i = 0;
	for (i = 0; i < whole_line.length; i++)
	{
		if ([line characterAtIndex: i] != ' ')
			break;
	}
	
	// Our indent is that many spaces
	NSString *indent = [line substringWithRange: NSMakeRange(0, i)];
	
	if (autoIndent)
		indent = [@"\n" stringByAppendingFormat: indent, nil];
	else indent = @"\n";
	
	// Replace the first selection with a new line followed by the indent spacing.	
	if ([self shouldChangeTextInRange: [[ranges objectAtIndex: 0] rangeValue] 
						 replacementString: indent]) {
		[self replaceCharactersInRange: [[ranges objectAtIndex: 0] rangeValue]
								 withString: indent];
		[self didChangeText];
	}
}

- (void) shiftLeft:(id)sender {
	NSArray *lineRange = [self lineNumbersForRange: [[[self selectedRanges] objectAtIndex: 0] rangeValue]];
	NSString *doc = [[self textStorage] string];

	for (id i in lineRange) {
		// Index of the first column
		NSUInteger firstColumn = [[[self lineIndices] objectAtIndex: [i unsignedIntegerValue]] unsignedIntegerValue];
		// Range of the line
		NSRange line = [doc lineRangeForRange: NSMakeRange(firstColumn, 0)];
		// Range of the first non-whitespace character
		NSRange whitespaceAtBeginning = [doc rangeOfCharactersFromSet: [NSCharacterSet whitespaceCharacterSet]
																range: line];
		
//		NSLog(@"Space at beginning from %u to %u", whitespaceAtBeginning.location, 
//			  whitespaceAtBeginning.location + whitespaceAtBeginning.length);
		NSLog(@"Whitespace at beginning: %u", whitespaceAtBeginning.length);
		
		// Remove min(length, 4) whitespace from beginning of line
		
		NSRange range = NSMakeRange(firstColumn, MIN(whitespaceAtBeginning.length, 4));
		
		NSString *str = [NSString stringWithFormat: @"%*s", range.length, ""];
		
		NSLog(@"Removing %u characters [%@] from beginning of line.", range.length, str);
		
		//NSLog(@"_%*s_", 5, "");
		//NSLog(@"Inserting '    ' on line %u", [i unsignedIntegerValue]);
		
		if ([self shouldChangeTextInRange: range 
						replacementString: @""]) {
			[self replaceCharactersInRange: range
								withString: @""];
			[self didChangeText];
		}
	}
}

- (void) shiftRight: (id)sender {
	NSRange initialRange = [[[self selectedRanges] objectAtIndex: 0] rangeValue];
	NSArray *lineRange = [self lineNumbersForRange: initialRange];
	
	initialRange.location += 4;
	initialRange.length -= 4;
	
	NSLog(@"Shift right, line range: %@", lineRange);
	// Line indicies will update as we insert the text (SLOW??)
	for (id i in lineRange) {
		// Index of first column
		NSUInteger index = [[[self lineIndices] objectAtIndex: [i unsignedIntegerValue]] unsignedIntegerValue];
		
		NSRange range = NSMakeRange(index, 0);
		NSLog(@"Inserting '    ' on line %u", [i unsignedIntegerValue]);		
		if ([self shouldChangeTextInRange: range 
						replacementString: @"    "]) {
			[self replaceCharactersInRange: range
								withString: @"    "];
			[self didChangeText];
			initialRange.length += 4;
		}
	}
	// Adjust selection
	[self setSelectedRanges: [NSArray arrayWithObject: [NSValue valueWithRange: initialRange]]];
}


@end
