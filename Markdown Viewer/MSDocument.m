//
//  MSDocument.m
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import "MSDocument.h"
#import "MSExportController.h"
#import <ORCDiscount/ORCDiscount.h>

@implementation MSDocument

@synthesize htmlString=_htmlString;
@synthesize markdownView;

+ (NSArray *)writableTypes
{
	return @[ @"HTML", @"RTF", @"PDF" ];
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"MSDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
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
	
	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented for file type %@", NSStringFromSelector(_cmd), typeName] userInfo:nil];
	@throw exception;
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	// Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
	// You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
	// If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
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
	htmlString = [NSString stringWithFormat:@"<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><link rel=\"stylesheet\" href=\"style.css\"></head><body>%@</body></html>", htmlString];
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
	NSPrintInfo *printInfo = [self printInfo];
	WebView *printView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, [printInfo paperSize].width-[printInfo leftMargin]-[printInfo rightMargin], 500)];
	[[printView mainFrame] loadHTMLString:[self htmlString] baseURL:[[NSBundle mainBundle] resourceURL]];
	[[self markdownView] print:sender];
}

@end
