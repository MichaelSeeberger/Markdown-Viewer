#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import <ORCDiscount/ORCDiscount.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	if (QLPreviewRequestIsCancelled(preview))
		return noErr;
	
	@autoreleasepool {
		NSLog(@"Hallo?");
		
		NSMutableDictionary *opts = [NSMutableDictionary dictionaryWithCapacity:2];
		[opts setObject:@"UTF-8" forKey:(NSString *)CFBridgingRelease(kQLPreviewPropertyTextEncodingNameKey)];
		[opts setObject:@"text/html" forKey:(__bridge NSString *)kQLPreviewPropertyMIMETypeKey];
		
		NSError *error = nil;
		NSString *htmlString = [NSString stringWithContentsOfURL:(__bridge NSURL *)(url) encoding:NSUTF8StringEncoding error:&error];
		NSString *markdownString = [ORCDiscount markdown2HTML:htmlString];
		CFDataRef data = (__bridge CFDataRef)([markdownString dataUsingEncoding:NSUTF8StringEncoding]);
		QLPreviewRequestSetDataRepresentation(preview, data, kUTTypeHTML, (__bridge CFDictionaryRef)opts);
	}
	
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
