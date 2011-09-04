//
//  BookWindowController.m
//  Bookish
//
//  Created by Mark Paschal on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookWindowController.h"
#import "BookProtocol.h"


@implementation BookWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (WebView *)webview {
    return webview;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.document windowControllerDidLoadNib:self];

    NSLog(@"OHAI OHAI HOAHI webview has prefs \"%@\" (user style sheet %@: %@)", [[webview preferences] identifier], [[webview preferences] userStyleSheetEnabled] ? @"ENABLED" : @"UNNOTDISENABLED", [[[webview preferences] userStyleSheetLocation] absoluteString]);

    [self showWindow:nil];
}

- (void)swipeWithEvent:(NSEvent *)event {
    CGFloat x = [event deltaX];
    CGFloat y = [event deltaY];
    if (x > 0 || y > 0) {
        NSLog(@"swipe to page FORWARD");
    }
    else if (x < 0 || y < 0) {
        NSLog(@"swipe to page BACK");
    }
    else {
        NSLog(@"Thought we swiped but we didn't");
    }

    // derp?
    //[self setNeedsDisplay:YES];
}

-(NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    NSLog(@"O HAI webview will send request");
    if (![BookProtocol canInitWithRequest:request]) {
        NSLog(@"Oops, request %@ is not a book protocol request", request);
        return request;
    }
    
    NSMutableURLRequest *bookRequest = [[request mutableCopy] autorelease];
    [bookRequest setBookProtocolBook:self.document];
    NSLog(@"Yay, set a new book request %@ with bookself saved in it wewt", bookRequest);
    return bookRequest;
}

@end
