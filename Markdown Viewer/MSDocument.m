//
//  MSDocument.m
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import "MSDocument.h"
#import "MSError.h"
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
		return [self exportToHTML:outError];
	else if ([typeName isEqualToString:@"PDF"])
		return [self exportToPDF:outError];
	else if ([typeName isEqualToString:@"RTF"])
		return [self exportToRTF:outError];
	
	NSLog(@"I do not know how to export to %@", typeName);
	NSException *exception = [NSException exceptionWithName:@"UnkownDataType" reason:[NSString stringWithFormat:@"%@ is unimplemented for file type %@", NSStringFromSelector(_cmd), typeName] userInfo:nil];
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

- (NSData *)exportToHTML:(NSError *__autoreleasing*)error
{
	return [[self htmlString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)exportToPDF:(NSError *__autoreleasing*)error
{
	if (error)
		*error = MSErrorWithCode(MSFunctionalityNotImplementedError);
	
	return NULL;
}

- (NSData *)exportToRTF:(NSError *__autoreleasing*)error
{
	NSAttributedString *str = [[NSAttributedString alloc] initWithHTML:[self exportToHTML:error] baseURL:nil documentAttributes:NULL];
	if (!str)
		return nil;
	
	return [str RTFFromRange:NSMakeRange(0, [str length]) documentAttributes:NULL];
}

- (void)printDocument:(id)sender
{
	[[[[[self markdownView] mainFrame] frameView] documentView] print:sender];
}

- (void)presentedItemDidChange
{
	[self revertToContentsOfURL:[self fileURL] ofType:@"Markdown" error:NULL];
}

@end
