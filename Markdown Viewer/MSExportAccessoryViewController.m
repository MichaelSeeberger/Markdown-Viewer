//
//  MSExportAccessoryViewController.m
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import "MSExportAccessoryViewController.h"

@interface MSExportAccessoryViewController ()

@end

@implementation MSExportAccessoryViewController

- (NSUInteger)selectedType
{
	return [(NSPopUpButton *)[self view] selectedTag];
}

@end
