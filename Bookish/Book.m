//
//  Book.m
//  Bookish
//
//  Created by Mark Paschal on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Book.h"
#import <ZipKit/ZKCDHeader.h>



@implementation Book

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Book";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];

    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    NSLog(@"~LOADED! WEB VIEW IS %@~", webview);
    [[webview mainFrame] loadHTMLString:@"hi" baseURL:[NSURL URLWithString:@"http://www.example.com/"]];
}

- (NSString *)displayName {
    return title ? title : @"Untitled";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (ZKCDHeader *)entryForFilename:(NSString *)filename {
    for (ZKCDHeader *entry in archive.centralDirectory) {
        if ([entry.filename isEqualToString:filename]) {
            return entry;
        }
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"~READ FROM DATA~");

    archive = [ZKDataArchive archiveWithArchiveData:(NSMutableData*)data];
    if (!archive) {
        NSLog(@"Could not open archive for data");
        return NO;
    }

    // Check the META-INF/container.xml for where the OPF document is.
    ZKCDHeader *header = [self entryForFilename:@"META-INF/container.xml"];
    if (!header) {
        NSLog(@"Could not find META-INF/container.xml file");
        return NO;
    }

    NSDictionary *contentAttr = nil;
    NSError *error = nil;
    NSXMLDocument *container = [[NSXMLDocument alloc] initWithData:[archive inflateFile:header attributes:&contentAttr] options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing META-INF/container.xml");
        outError = &error;
        return NO;
    }

    NSArray *result = [[container rootElement] objectsForXQuery:@"./rootfiles/rootfile[@media-type=\"application/oebps-package+xml\"]/@full-path" error:&error];
    if (!result) {
        NSLog(@"Error finding OPF file");
        outError = &error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for OPF files okay but didn't find any");
        return NO;
    }

    // Load the OPF document.
    NSString *opfFilename = [[result objectAtIndex:0] stringValue];
    NSLog(@"Looking for OPF file %@", opfFilename);
    header = [self entryForFilename:opfFilename];
    if (!header) {
        NSLog(@"Didn't find the referenced OPF document in the archive");
        return NO;
    }

    content = [[NSXMLDocument alloc] initWithData:[archive inflateFile:header attributes:&contentAttr] options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing the OPF document");
        outError = &error;
        return NO;
    }

    NSString *query = @"./metadata/*[local-name()=\"title\"]/text()";
    result = [[content rootElement] objectsForXQuery:query error:&error];
    if (!result) {
        NSLog(@"Couldn't find dc:title in OPF");
        outError = &error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for dc:title okay but didn't find one");
        return NO;
    }

    title = [[result objectAtIndex:0] stringValue];

    // Check the OPF document for where the TOC is.

    return YES;
}

@end
