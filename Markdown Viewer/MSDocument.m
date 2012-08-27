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
#import <Quartz/Quartz.h>

@interface MSDocument ()

- (NSView <WebDocumentView> *)documentView;

@end

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

- (BOOL)isDocumentEdited
{
	return NO;
}

- (BOOL)hasUnautosavedChanges
{
	return NO;
}

+ (BOOL)autosavesInPlace
{
    return NO;
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
	if (outError)
		*outError = MSErrorWithCode(MSExportError);
	
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

- (BOOL)letTheUserDecideIfSheWantsASloppyPDF
{
	NSString *info = NSLocalizedString(@"I have not yet been able to get a good result for exporting PDFs. If you don't care about seeing nice pages and stuff, go ahead. However, I recommend to create a PDF version of this file via the print panel. For that, choose \"Print\" in the \"File\" menu. This will display the print panel and you can see a button titled PDF at the bottom corner.", @"Alternative");
	NSString *description = NSLocalizedString(@"About that...", @"PDF exporting problem");
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert setInformativeText:info];
	[alert setMessageText:description];
	[alert addButtonWithTitle:NSLocalizedString(@"Use the print panel", @"Use the print panel")];
	[alert addButtonWithTitle:NSLocalizedString(@"Continue anyway", @"Continue anyway")];
	
	return [alert runModal] != NSAlertFirstButtonReturn;
}

- (NSData *)exportToPDF:(NSError *__autoreleasing*)error
{
	if (![self letTheUserDecideIfSheWantsASloppyPDF]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self printDocument:nil];
		});
		return nil;
	}
	
	NSView<WebDocumentView> *documentView = [self documentView];
	
	NSMutableData *outData = [NSMutableData data];
	
	NSPrintOperation *printOperation = [NSPrintOperation PDFOperationWithView:documentView insideRect:[documentView bounds] toData:outData printInfo:[self printInfo]];
	if ([printOperation runOperation])
		return outData;
	
	if (error)
		*error = MSErrorWithCode(MSExportError);
	
	return outData;
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
	[[NSPrintOperation printOperationWithView:[self documentView] printInfo:[self printInfo]] runOperation];
}

- (void)presentedItemDidChange
{
	[self revertToContentsOfURL:[self fileURL] ofType:@"Markdown" error:NULL];
}

- (NSView <WebDocumentView> *)documentView
{
	return [[[[self markdownView] mainFrame] frameView] documentView];
}

@end
