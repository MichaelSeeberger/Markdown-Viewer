//
//  MSError.h
//  Markdown Viewer
//
//  Created by Michael Seeberger on 16.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum MSErrorCode {
	MSExportError = 10,
	MSFunctionalityNotImplementedError = 1000,
	MSInternalError = 1001
};
typedef enum MSErrorCode MSErrorCode;

NSError *MSErrorWithCode(MSErrorCode errorCode);
