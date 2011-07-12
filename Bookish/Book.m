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
        return NO;
    }

    // TODO: Check out the META-INF/container.xml?

    // Load the OEBPS/content.opf.
    ZKCDHeader *contentHeader = nil;
    for (ZKCDHeader *entry in archive.centralDirectory) {
        if ([entry.filename isEqualToString:@"OEBPS/content.opf"]) {
            contentHeader = entry;
            break;
        }
    }
    if (!contentHeader) {
        return NO;
    }

    NSDictionary *contentAttr = nil;
    NSError *error = nil;
    content = [[NSXMLDocument alloc] initWithData:[archive inflateFile:contentHeader attributes:&contentAttr] options:0 error:&error];
    if (error) {
        return NO;
    }

    return YES;
}

@end
