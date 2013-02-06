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


@interface Book : NSDocument <NSWindowDelegate> {
    NSUInteger currentItem;
    BookWindowController *contr;

    //IBOutlet WebView *webview;
}

- (NSData *)dataForResourcePath:(NSString *)path contentType:(NSString **)contentType;

- (IBAction)nextChapter:(NSMenuItem *)menuitem;
- (IBAction)previousChapter:(NSMenuItem *)menuitem;
- (IBAction)setTypeface:(NSMenuItem *)menuitem;

@property (retain) ZKDataArchive *archive;
@property (retain) NSString *opfPath;
@property (retain) NSXMLDocument *content;
@property (retain) NSString *bookId;
@property (retain) NSString *coverImageId;
@property (retain) NSString *title;
@property (retain) NSArray *spine;
@property (retain) NSDictionary *manifest;
@property (retain) BookWindowController *contr;
@property (retain) NSImage *coverIcon;
@property (readonly) WebView *webview;

@end
