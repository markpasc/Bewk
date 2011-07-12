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



@class WebView;

@interface Book : NSDocument {
    ZKDataArchive *archive;
    NSXMLDocument *content;
    IBOutlet WebView *webview;
}

@end
