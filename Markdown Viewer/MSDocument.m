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

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	NSData *data = nil;
	if ([typeName isEqualToString:@"HTML"])
		data = [self exportToHTML:outError];
	else if ([typeName isEqualToString:@"PDF"]) {
		return [self exportToPDFAtURL:url error:outError];
	} else if ([typeName isEqualToString:@"RTF"])
		data = [self exportToRTF:outError];
	
	if (data)
		[data writeToURL:url atomically:YES];
	
	return data != nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	NSString *rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (!rawString) {
		if (outError)
			*outError = MSErrorWithCode(MSFileCouldNotBeLoadedError);
		
		return NO;
	}
	
	NSString *htmlString = [ORCDiscount HTMLPage:[ORCDiscount markdown2HTML:rawString] withCSSFromURL:[ORCDiscount cssURL]];
	
	if (!htmlString) {
		if (outError)
			*outError = MSErrorWithCode(MSFileIsNotMarkdownFormatError);
		
		return NO;
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

- (BOOL)exportToPDFAtURL:(NSURL *)url error:(NSError *__autoreleasing*)error
{
	NSPrintInfo *defaultPrintInfo = [self printInfo];
	NSMutableDictionary *printInfoDict = [NSMutableDictionary dictionaryWithDictionary:[defaultPrintInfo dictionary]];
	[printInfoDict setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
	[printInfoDict setObject:url forKey:NSPrintJobSavingURL];
	[printInfoDict setObject:NSPrintSaveJob forKey:NSPrintJobDisposition];
	
	NSPrintInfo *printInfo = [[NSPrintInfo alloc] initWithDictionary:printInfoDict];
	NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:[self documentView] printInfo:printInfo];
	[printOperation setShowsPrintPanel:NO];
	
	return [printOperation runOperation];
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
