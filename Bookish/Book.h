//
//  Book.h
//  Bookish
//
//  Created by Mark Paschal on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <ZipKit/ZKDataArchive.h>
#import "BookWindowController.h"


@interface Book : NSDocument {
    ZKDataArchive *archive;
    NSXMLDocument *content;
    NSString *title;
    NSArray *spine;
    NSDictionary *manifest;
    NSUInteger currentItem;

    BookWindowController *contr;

    //IBOutlet WebView *webview;
}

- (NSData *)dataForResourcePath:(NSString *)path contentType:(NSString **)contentType;

- (void)nextPage:(NSMenuItem *)something;
- (void)previousPage:(NSMenuItem *)something;
- (void)nextChapter:(NSMenuItem *)something;
- (void)previousChapter:(NSMenuItem *)something;

@property (retain) ZKDataArchive *archive;
@property (retain) NSXMLDocument *content;
@property (retain) NSString *title;
@property (retain) NSArray *spine;
@property (retain) NSDictionary *manifest;
@property (retain) BookWindowController *contr;
@property (readonly) WebView *webview;

@end
