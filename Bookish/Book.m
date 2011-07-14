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

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"~READ FROM DATA~");

    archive = [ZKDataArchive archiveWithArchiveData:(NSMutableData*)data];
    if (!archive) {
        NSLog(@"Could not open archive for data");
        return NO;
    }

    // Check the META-INF/container.xml for where the OPF document is.
    ZKCDHeader *header = nil;
    for (ZKCDHeader *entry in archive.centralDirectory) {
        if ([entry.filename isEqualToString:@"META-INF/container.xml"]) {
            header = entry;
            break;
        }
    }
    if (!header) {
        NSLog(@"Could not find META-INF/container.xml file");
        return NO;
    }

    NSDictionary *contentAttr = nil;
    NSError *error = nil;
    content = [[NSXMLDocument alloc] initWithData:[archive inflateFile:header attributes:&contentAttr] options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing META-INF/container.xml");
        outError = &error;
        return NO;
    }

    NSArray *result = [[content rootElement] objectsForXQuery:@"./rootfiles/rootfile[@media-type=\"application/oebps-package+xml\"]/@full-path" error:&error];
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
    for (ZKCDHeader *entry in archive.centralDirectory) {
        if ([entry.filename isEqualToString:[result objectAtIndex:0]]) {
            header = entry;
            break;
        }
    }
    if (!header) {
        NSLog(@"Didn't find the referenced OPF document in the archive");
        return NO;
    }

    return YES;
}

@end
