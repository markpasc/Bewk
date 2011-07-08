//
//  Book.h
//  Bookish
//
//  Created by Mark Paschal on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZipEntry.h"

@class WebView;

@interface Book : NSDocument {
    ZipEntry *rootEntry;
    IBOutlet WebView *webview;
}

@end
