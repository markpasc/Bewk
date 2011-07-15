//
//  Book.m
//  Bookish
//
//  Created by Mark Paschal on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Book.h"
#import <ZipKit/ZKCDHeader.h>
#import "BookProtocol.h"


@interface Book ()

- (void)updateWebView;
- (ZKCDHeader *)entryForFilename:(NSString *)filename;

@end


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

    NSLog(@"~LOADED! WEB VIEW IS %@~", webview);

    // What's the first page in the book?
    currentItem = 0;
    [self updateWebView];
}

- (void)updateWebView {
    NSXMLElement *first = [spine objectAtIndex:currentItem];
    if (!first) return;
    NSXMLNode *node = [first attributeForName:@"href"];
    if (!node) return;

    NSString *bookUrl = [NSString stringWithFormat:@"bookishbook:///%@",[node stringValue]];
    NSLog(@"Loading up URL %@ in webview!", bookUrl);
    [webview setMainFrameURL:bookUrl];
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

- (NSData *)dataForResourcePath:(NSString *)path contentType:(NSString **)contentType {
    NSString *filename = [NSString stringWithFormat:@"OEBPS/%@",path];

    ZKCDHeader *header = [self entryForFilename:filename];
    if (!header) {
        return nil;
    }

    // What's the content type?
    for (id item in [manifest objectEnumerator]) {
        NSXMLElement *manifestItem = (NSXMLElement *)item;
        NSXMLNode *idNode = [manifestItem attributeForName:@"href"];
        if ([[idNode stringValue] isEqualToString:path]) {
            *contentType = [[manifestItem attributeForName:@"media-type"] stringValue];
        }
    }

    NSDictionary *contentAttr;
    NSData *data = [[archive inflateFile:header attributes:&contentAttr] autorelease];
    return data;
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
        *outError = error;
        return NO;
    }

    NSArray *result = [[container rootElement] objectsForXQuery:@"./rootfiles/rootfile[@media-type=\"application/oebps-package+xml\"]/@full-path" error:&error];
    if (!result) {
        NSLog(@"Couldn't query for OPF filename");
        *outError = error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for OPF filename okay but didn't find any");
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
        *outError = error;
        return NO;
    }

    NSString *query = @"./metadata/*[local-name()=\"title\"]/text()";
    result = [[content rootElement] objectsForXQuery:query error:&error];
    if (!result) {
        NSLog(@"Couldn't query dc:title in OPF");
        *outError = error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for dc:title okay but didn't find one");
        return NO;
    }

    title = [[result objectAtIndex:0] stringValue];

    result = [[content rootElement] nodesForXPath:@"./manifest/item" error:&error];
    if (!result) {
        NSLog(@"Couldn't query for manifest items in OPF");
        *outError = error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for manifest items but didn't find any: %@", result);
        return NO;
    }

    NSMutableDictionary *manifestItems = [[NSMutableDictionary alloc] init];
    for (id item in result) {
        NSXMLElement *manifestItem = (NSXMLElement *)item;
        NSXMLNode *idNode = [manifestItem attributeForName:@"id"];
        [manifestItems setObject:manifestItem forKey:[idNode stringValue]];
    }
    manifest = [NSDictionary dictionaryWithDictionary:manifestItems];

    result = [[content rootElement] objectsForXQuery:@"./spine/itemref" error:&error];
    if (!result) {
        NSLog(@"Couldn't query for spine items in OPF");
        *outError = error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for spine items but didn't find any!");
        return NO;
    }

    NSMutableArray *metaspine = [[NSMutableArray alloc] initWithCapacity:[result count]];
    for (id item in result) {
        NSXMLElement *spineItem = (NSXMLElement *)item;
        NSXMLNode *idNode = [spineItem attributeForName:@"idref"];
        NSXMLElement *manifestItem = [manifestItems objectForKey:[idNode stringValue]];
        if (!manifestItem) {
            NSLog(@"OOPS spine referred to item %@ that isn't in manifest anymore?", [idNode stringValue]);
            continue;
        }
        [metaspine addObject:manifestItem];
    }
    spine = [NSArray arrayWithArray:metaspine];

    return YES;
}

-(NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    NSLog(@"O HAI webview will send request");
    if (![BookProtocol canInitWithRequest:request]) {
        NSLog(@"Oops, request %@ is not a book protocol request", request);
        return request;
    }

    NSMutableURLRequest *bookRequest = [[request mutableCopy] autorelease];
    [bookRequest setBookProtocolBook:self];
    NSLog(@"Yay, set a new book request %@ with bookself saved in it wewt", bookRequest);
    return bookRequest;
}

@end
