//
//  MSDocument.h
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MSDocument : NSDocument

@property (strong) NSString *htmlString;

@property (weak) IBOutlet WebView *markdownView;

- (IBAction)export:(id)sender;

@end
