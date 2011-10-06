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
- (void)setAppIconToCover;

@end


@implementation Book

@synthesize archive, opfPath, content, bookId, title, spine, manifest, contr, coverIcon;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (void)makeWindowControllers {
    NSString *nibname = [self windowNibName];
    if (!nibname)
        return;

    NSLog(@"MAKING WINDOW CONTROLLER(S?)");
    BookWindowController *derp = [[BookWindowController alloc] initWithWindowNibName:nibname];
    self.contr = derp;
    [derp release];

    contr.document = self;
    [self addWindowController:contr];
    NSLog(@"NEW CONTROLLER %@ WITH ME, A BOOK, %@, %@, FOR DOCUMENT", contr, self, title);

    NSWindow *window = [contr window];
    [window setDelegate:self];
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

    NSLog(@"~LOADED! WEB VIEW IS %@~", self.webview);

    // What's the first page in the book?
    currentItem = 0;
    [self updateWebView];

    [self setAppIconToCover];
}

- (void)setAppIconToCover {
    if (coverIcon) {
        [NSApp setApplicationIconImage:coverIcon];
        return;
    }

    NSXMLElement *derp = [self.manifest objectForKey:@"cover-image"];
    if (!derp) {
        NSLog(@"No cover-image xml element oops");
        return;
    }

    NSString *imagepath = [[derp attributeForName:@"href"] stringValue];
    NSLog(@"Cover image is %@", imagepath);
    NSData *imagedata = [self dataForResourcePath:imagepath contentType:nil];
    if (!imagedata) {
        NSLog(@"Couldn't load data for image %@", imagepath);
        return;
    }
    NSImage *rawCover = [[NSImage alloc] initWithData:imagedata];

    NSBitmapImageRep *bir = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil pixelsWide:512 pixelsHigh:512 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bir];

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];

    // TODO: and if the image is wider than tall?
    CGFloat scale = 512.0 / rawCover.size.height;
    CGFloat destWidth = rawCover.size.width * scale;
    NSRect destRect = NSMakeRect(256.0 - destWidth / 2.0, 0.0, destWidth, 512.0);
    [rawCover drawInRect:destRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

    [NSGraphicsContext restoreGraphicsState];

    self.coverIcon = [[NSImage alloc] initWithSize:NSMakeSize(512, 512)];
    [coverIcon addRepresentation:bir];

    [NSApp setApplicationIconImage:coverIcon];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    NSLog(@"~ OOPS WINDOW BECAME MAINZ ~");
    [self setAppIconToCover];
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp setApplicationIconImage:nil];
}

- (void)windowWillMiniaturize:(NSNotification *)notification {
    [NSApp setApplicationIconImage:nil];
}

- (WebView *)webview {
    return self.contr.webview;
}

- (void)updateWebView {
    NSXMLElement *first = [spine objectAtIndex:currentItem];
    if (!first) return;
    NSXMLNode *node = [first attributeForName:@"href"];
    if (!node) return;

    NSString *bookUrl = [NSString stringWithFormat:@"%@://book/%@/%@",[BookProtocol bookProtocolScheme],bookId,[node stringValue]];
    NSLog(@"Loading up URL %@ in webview!", bookUrl);
    [self.webview setMainFrameURL:bookUrl];
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
    NSString *filename = [opfPath length] ? [NSString stringWithFormat:@"%@/%@",opfPath,path] : path;
    NSLog(@"Did somebody ask for a %@?", filename);

    ZKCDHeader *header = [self entryForFilename:filename];
    if (!header) {
        return nil;
    }

    // What's the content type?
    if (contentType) {
        for (id item in [manifest objectEnumerator]) {
            NSXMLElement *manifestItem = (NSXMLElement *)item;
            NSXMLNode *idNode = [manifestItem attributeForName:@"href"];
            if ([[idNode stringValue] isEqualToString:path]) {
                *contentType = [[manifestItem attributeForName:@"media-type"] stringValue];
            }
        }
    }

    NSDictionary *contentAttr;
    NSData *data = [archive inflateFile:header attributes:&contentAttr];
    return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"~READ FROM DATA~");

    self.archive = [ZKDataArchive archiveWithArchiveData:(NSMutableData*)data];
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
    NSData *containerdoc = [archive inflateFile:header attributes:&contentAttr];
    NSError *error = nil;
    NSXMLDocument *container = [[NSXMLDocument alloc] initWithData:containerdoc options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing META-INF/container.xml");
        [container release];
        if (outError) *outError = error;
        return NO;
    }

    NSArray *result = [[container rootElement] objectsForXQuery:@"./rootfiles/rootfile[@media-type=\"application/oebps-package+xml\"]/@full-path" error:&error];
    [container release];
    if (!result) {
        NSLog(@"Couldn't query for OPF filename");
        if (outError) *outError = error;
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

    self.opfPath = [opfFilename stringByDeletingLastPathComponent];
    self.content = [[NSXMLDocument alloc] initWithData:[archive inflateFile:header attributes:&contentAttr] options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing the OPF document");
        if (outError) *outError = error;
        return NO;
    }

    NSLog(@"Looking for where to find the book's unique identifier");
    result = [[content rootElement] objectsForXQuery:@"./@unique-identifier" error:&error];
    if (!result) {
        NSLog(@"Couldn't query unique-identifier field");
        if (outError) *outError = error;
        return NO;
    }
    if (![result count]) {
        NSLog(@"Couldn't find any unique-identifier attribute");
        return NO;
    }
    NSString *bookIdField = [[result objectAtIndex:0] stringValue];

    NSLog(@"Looking for element with id=%@ for book's unique identifier", bookIdField);
    NSString *query = [NSString stringWithFormat:@"./metadata//*[@id=\"%@\"]/text()",bookIdField];
    result = [[content rootElement] objectsForXQuery:query error:&error];
    if (!result) {
        NSLog(@"Couldn't query the unique identifier with id %@", bookIdField);
        if (outError) *outError = error;
        return NO;
    }
    if (![result count]) {
        NSLog(@"Couldn't find any metadata element with id attribute of %@", bookIdField);
        return NO;
    }
    self.bookId = [[result objectAtIndex:0] stringValue];

    NSLog(@"Looking for title of book %@", bookId);
    query = @"./metadata//*[local-name()=\"title\"]/text()";
    result = [[content rootElement] objectsForXQuery:query error:&error];
    if (!result) {
        NSLog(@"Couldn't query dc:title in OPF");
        if (outError) *outError = error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for dc:title okay but didn't find one");
        return NO;
    }

    self.title = [[result objectAtIndex:0] stringValue];
    NSLog(@"Found book title \"%@\"", self.title);

    result = [[content rootElement] nodesForXPath:@"./manifest/item" error:&error];
    if (!result) {
        NSLog(@"Couldn't query for manifest items in OPF");
        if (outError) *outError = error;
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
    self.manifest = [NSDictionary dictionaryWithDictionary:manifestItems];
    NSLog(@"Build manifest for %@", self.title);

    result = [[content rootElement] objectsForXQuery:@"./spine/itemref" error:&error];
    if (!result) {
        NSLog(@"Couldn't query for spine items in OPF");
        [manifestItems release];
        if (outError) *outError = error;
        return NO;
    }
    if ([result count] < 1) {
        NSLog(@"Queried for spine items but didn't find any!");
        [manifestItems release];
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
    [manifestItems release];

    self.spine = [NSArray arrayWithArray:metaspine];
    [metaspine release];

    NSLog(@"Builtified spine too, all done loading %@", self.title);
    return YES;
}

- (void)nextPage:(NSMenuItem *)menuItem {
    NSLog(@"~~ NEXT PAGE ~~");
}

- (void)previousPage:(NSMenuItem *)menuItem {
    NSLog(@"~~ PREVIOUS PAGE ~~");
}

- (void)nextChapter:(NSMenuItem *)menuItem {
    NSLog(@"~~ NEXT CHAPTER ~~");

    if (currentItem >= [spine count] - 1) {
        return;
    }
    currentItem += 1;

    [self updateWebView];
}

- (void)previousChapter:(NSMenuItem *)menuItem {
    NSLog(@"~~ PREVIOUS CHAPTER ~~");

    if (currentItem <= 0) {
        return;
    }
    currentItem -= 1;

    [self updateWebView];
}

+ (NSString*)webScriptNameForSelector:(SEL)selector {
    if (selector == @selector(nextChapter:))
        return @"nextChapter";
    if (selector == @selector(logJSMessage:))
        return @"log";
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
    if (selector == @selector(nextChapter:))
        return NO;
    if (selector == @selector(logJSMessage:))
        return NO;
    return YES;
}

- (void)logJSMessage:(NSString *)message {
    NSLog(@"js: %@", message);
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL act = [menuItem action];
    if (act == @selector(nextPage:)) {
        return YES;
    }
    if (act == @selector(previousPage:)) {
        return YES;
    }
    if (act == @selector(nextChapter:) && currentItem < [spine count]) {
        return YES;
    }
    if (act == @selector(previousChapter:) && currentItem > 0) {
        return YES;
    }
    return NO;
}

@end
