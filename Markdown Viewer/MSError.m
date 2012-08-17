//
//  MSError.m
//  Markdown Viewer
//
//  Created by Michael Seeberger on 16.08.12.
//  Copyright (c) 2012 Michael Seeberger. All rights reserved.
//

#import "MSError.h"

NSString * const kMSErrorDomain = @"MSErrorDomain";

NSError *MSErrorWithCode(MSErrorCode errorCode)
{
	NSString *defaultReason = [NSString stringWithFormat:@"Error %lu", (unsigned long)errorCode];
	NSString *defaultLocalizedReason = NSLocalizedString(defaultReason, @"Unkown error");
	
	NSString *defaultDescription = [NSString stringWithFormat:@"Error %lu", (unsigned long)errorCode];
	NSString *defaultLocalizedDescription = NSLocalizedString(defaultDescription, @"Unkown error");
	
	NSString *failureKey = [NSString stringWithFormat:@"reason%lu", (unsigned long)errorCode];
	NSString *reason = [[NSBundle mainBundle] localizedStringForKey:failureKey value:defaultLocalizedReason table:@"MSError"];
	
	NSString *descriptionKey = [NSString stringWithFormat:@"description%lu", (long unsigned)errorCode];
	NSString *description = [[NSBundle mainBundle] localizedStringForKey:descriptionKey value:defaultLocalizedDescription table:@"MSError"];
	
	NSDictionary *errorDict = @{ NSLocalizedFailureReasonErrorKey : reason, NSLocalizedDescriptionKey : description };
	
	return [NSError errorWithDomain:kMSErrorDomain code:errorCode userInfo:errorDict];
}
