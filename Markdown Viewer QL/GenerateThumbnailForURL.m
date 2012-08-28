#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import <ORCDiscount/ORCDiscount.h>
#import <WebKit/WebKit.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    @autoreleasepool {
		NSError *error = nil;
		NSString *htmlString = [NSString stringWithContentsOfURL:(__bridge NSURL *)(url) encoding:NSUTF8StringEncoding error:&error];
		NSString *htmlPage = [ORCDiscount HTMLPage:[ORCDiscount markdown2HTML:htmlString] withCSSFromURL:[ORCDiscount cssURL]];
		
		NSSize size = [[NSPrintInfo sharedPrintInfo] paperSize];
		if (maxSize.height > maxSize.width) {
			size.width = maxSize.height * size.width / size.height;
			size.height = maxSize.height;
		} else {
			size.height = size.height * maxSize.width / size.width;
			size.width = maxSize.width;
		}
		
		NSImage *image = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			NSMutableDictionary *optDict = [NSMutableDictionary dictionary];
			[optDict setObject:[NSColor colorWithDeviceWhite:248.0/255.0 alpha:1.0] forKey:NSBackgroundColorDocumentAttribute];
			[optDict setObject:[NSValue valueWithSize:[[NSPrintInfo sharedPrintInfo] paperSize]] forKey:NSPaperSizeDocumentAttribute];
			
			NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:[htmlPage dataUsingEncoding:NSUTF8StringEncoding] baseURL:nil documentAttributes:NULL];
			[string drawWithRect:NSMakeRect(0.0, 0.0, size.width, size.height) options:NSLineBreakByCharWrapping];
			return YES;
		}];
		
		NSMutableDictionary *opts = [NSMutableDictionary dictionary];
		NSData *data = [image TIFFRepresentation];
		QLThumbnailRequestSetImageWithData(thumbnail, (__bridge CFDataRef)data, (__bridge CFDictionaryRef)opts);
	}
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
