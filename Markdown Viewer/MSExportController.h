//
//  MSExportController.h
//  Markdown Viewer
//
//  Created by Michael Seeberger on 14.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSExportAccessoryViewController;

@interface MSExportController : NSObject

@property (strong, nonatomic) NSSavePanel *savePanel;
@property dispatch_once_t onceToken;

@property dispatch_once_t exportControllerSynchronizer;

@property (strong, nonatomic) MSExportAccessoryViewController *exportAccessoryController;

- (NSString *)exportType;

- (NSArray *)allowedExportTypes;
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger result))handler;

@end
