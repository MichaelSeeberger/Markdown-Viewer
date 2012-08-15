//
//  MSDocument.m
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import "MSDocument.h"
#import <ORCDiscount/ORCDiscount.h>

@implementation MSDocument

@synthesize htmlString=_htmlString;
@synthesize markdownView=_markdownView;
@synthesize fileCoordinator=_fileCoordinator;

+ (NSArray *)writableTypes
{
	return @[ @"HTML", @"RTF", @"PDF" ];
}

- (NSString *)windowNibName
{
	return @"MSDocument";
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSWindow *)documentWindow
{
	NSWindowController *windowController = [[self windowControllers] objectAtIndex:0];
	return [windowController window];
}

- (IBAction)export:(id)sender
{
	[self saveDocumentTo:sender];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:@"HTML"])
		return [[self htmlString] dataUsingEncoding:NSUTF8StringEncoding];
	/*else if ([typeName isEqualToString:@"RTF"]) {
		NSAttributedString *str = [[NSAttributedString alloc] initWithHTML:[[self htmlString] dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:NULL];
	}*/
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented for file type %@", NSStringFromSelector(_cmd), typeName] userInfo:nil];
	@throw exception;
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	NSString *rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (!rawString) {
		if (outError) {
			NSString *description = NSLocalizedStringFromTable(@"Could not load the file.", @"MSError", @"Description when string can not be initialized with the files data.");
			NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : description };
			*outError = [NSError errorWithDomain:@"MarkdownViewer" code:1 userInfo:errorDict];
			return NO;
		}
	}
	
	NSString *htmlString = [ORCDiscount markdown2HTML:rawString];
	htmlString = [NSString stringWithFormat:@"<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><style>%@</style></head><body>%@</body></html>", [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"] encoding:NSUTF8StringEncoding error:outError], htmlString];
	if (!htmlString) {
		if (outError) {
			NSString *description = NSLocalizedStringFromTable(@"The file doesn't appear to be markdown.", @"MSError", @"Description when string can not be converted from markdown to HTML.");
			NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : description };
			*outError = [NSError errorWithDomain:@"MarkdownViewer" code:1 userInfo:errorDict];
			return NO;
		}
	}
	
	[self setHtmlString:htmlString];
	NSURL *baseURL = [[NSBundle mainBundle] resourceURL];
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self markdownView] mainFrame] loadHTMLString:[self htmlString] baseURL:baseURL];
	});
	
	return YES;
}

- (void)printDocument:(id)sender
{
	[[self markdownView] print:sender];
	/*NSPrintInfo *printInfo = [self printInfo];
	WebView *printView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, [printInfo paperSize].width-[printInfo leftMargin]-[printInfo rightMargin], 500)];
	[[printView mainFrame] loadHTMLString:[self htmlString] baseURL:[[NSBundle mainBundle] resourceURL]];
	[printView print:sender];*/
}

- (void)presentedItemDidChange
{
	[self revertToContentsOfURL:[self fileURL] ofType:@"Markdown" error:NULL];
}

@end
