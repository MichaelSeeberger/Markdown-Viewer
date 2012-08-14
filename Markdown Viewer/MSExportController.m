//
//  MSExportController.m
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import "MSExportController.h"
#import "MSExportAccessoryViewController.h"

@implementation MSExportController

@synthesize savePanel=_savePanel;
@synthesize onceToken=_onceToken;
@synthesize exportAccessoryController=_exportAccessoryController;
@synthesize exportControllerSynchronizer=_exportControllerSynchronizer;

- (void)setUpSavePanel
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[self allowedExportTypes]];
	[savePanel setAllowsOtherFileTypes:NO];
	[savePanel setPrompt:@"Export"];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAccessoryView:[[self exportAccessoryController] view]];
	
	[self setSavePanel:savePanel];
}

- (MSExportAccessoryViewController *)exportAccessoryController
{
	dispatch_once(&_exportControllerSynchronizer, ^{
		MSExportAccessoryViewController *ctrl = [[MSExportAccessoryViewController alloc] initWithNibName:@"MSExportAccessoryView" bundle:[NSBundle mainBundle]];
		[self setExportAccessoryController:ctrl];
	});
	
	return _exportAccessoryController;
}

- (NSSavePanel *)savePanel
{
	dispatch_once(&_onceToken, ^{
		[self setUpSavePanel];
	});
	
	return _savePanel;
}

- (NSArray *)allowedExportTypes
{
	return @[ @"HTML", @"PDF", @"RTF" ];
}

- (NSString *)exportType
{
	return [[self allowedExportTypes] objectAtIndex:[[self exportAccessoryController] selectedType]];
}

- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger result))handler
{
	[[self savePanel] beginSheetModalForWindow:window completionHandler:handler];
}

@end
