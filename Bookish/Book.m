//
//  Book.m
//  Bookish
//
//  Created by Mark Paschal on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Book.h"
#import <WebKit/WebKit.h>

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

#define MIN_DIRECTORY_END_OFFSET    20
#define MAX_DIRECTORY_END_OFFSET    66000
#define DIRECTORY_END_TAG           0x06054b50

- (BOOL)unzipFromData:(NSData *)data error:(NSError **)outError {
    BOOL retval = NO;
    const uint8_t *bytes = [data bytes];
    NSUInteger i, length = [data length], directoryEntriesEnd = 0;
    unsigned numberOfDirectoryEntries = 0;
    unsigned potentialTag, directoryEntriesStart = 0, directoryIndex;
    NSString *path;
    ZipEntry *entry;
    
    if (!data) {
        return NO;
    }

    for (i = MIN_DIRECTORY_END_OFFSET; directoryEntriesEnd == 0 && i < MAX_DIRECTORY_END_OFFSET && i < length; i++) {
        potentialTag = NSSwapLittleIntToHost(*(uint32_t *)(bytes + length - i));
        if (potentialTag == DIRECTORY_END_TAG) {
            directoryEntriesEnd = length - i;
            numberOfDirectoryEntries = NSSwapLittleShortToHost(*(uint16_t *)(bytes + directoryEntriesEnd + 8));
            directoryEntriesStart = NSSwapLittleIntToHost(*(uint32_t *)(bytes + directoryEntriesEnd + 16));
        }
    }
    for (i = 0, directoryIndex = directoryEntriesStart; i < numberOfDirectoryEntries; i++) {
        unsigned compression, namelen, extralen, commentlen;
        unsigned crcval, csize, usize, headeridx;
        
        compression = NSSwapLittleShortToHost(*(uint16_t *)(bytes + directoryIndex + 10));
        crcval = NSSwapLittleIntToHost(*(uint32_t *)(bytes + directoryIndex + 16));
        csize = NSSwapLittleIntToHost(*(uint32_t *)(bytes + directoryIndex + 20));
        usize = NSSwapLittleIntToHost(*(uint32_t *)(bytes + directoryIndex + 24));
        namelen = NSSwapLittleShortToHost(*(uint16_t *)(bytes + directoryIndex + 28));
        extralen = NSSwapLittleShortToHost(*(uint16_t *)(bytes + directoryIndex + 30));
        commentlen = NSSwapLittleShortToHost(*(uint16_t *)(bytes + directoryIndex + 32));
        headeridx = NSSwapLittleIntToHost(*(uint32_t *)(bytes + directoryIndex + 42));
        path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:(const char *)(bytes + directoryIndex + 46) length:namelen];
        
        if (path) {
            entry = [[ZipEntry alloc] initWithPath:path headerOffset:headeridx CRC:crcval compressedSize:csize uncompressedSize:usize compressionType:compression];
            [entry addToRootEntry:rootEntry];
            retval = YES;
        } else {
            break;
        }
        directoryIndex += 46 + namelen + extralen + commentlen;
    }

    if (!retval && outError) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:nil];
    }

    return retval;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"~READ FROM DATA~");
    if (![self unzipFromData:data error:outError]) {
        return NO;
    }

    return YES;
}
    
@end
