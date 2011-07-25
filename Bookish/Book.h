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


@interface Book : NSDocument {
    ZKDataArchive *archive;
    NSXMLDocument *content;
    NSString *title;
    NSArray *spine;
    NSDictionary *manifest;
    NSUInteger currentItem;

    IBOutlet WebView *webview;
}

- (NSData *)dataForResourcePath:(NSString *)path contentType:(NSString **)contentType;

@property (retain) ZKDataArchive *archive;
@property (retain) NSXMLDocument *content;
@property (retain) NSString *title;
@property (retain) NSArray *spine;
@property (retain) NSDictionary *manifest;

@end
