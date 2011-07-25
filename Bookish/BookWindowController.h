//
//  BookWindowController.h
//  Bookish
//
//  Created by Mark Paschal on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface BookWindowController : NSWindowController {
    IBOutlet WebView *webview;
}

@property (readonly) WebView *webview;

@end
