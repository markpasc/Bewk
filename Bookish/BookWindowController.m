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

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSLog(@"Can a book open a URL %@?", [request URL]);
    if ([BookProtocol canInitWithRequest:request]) {
        [listener use];
        return;
    }

    // Is it a click? We can open a click.
    WebNavigationType navType = [[actionInformation objectForKey:WebActionNavigationTypeKey] intValue];
    if (navType != WebNavigationTypeFormSubmitted && navType != WebNavigationTypeFormResubmitted) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    }

    [listener ignore];
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
    NSLog(@"O HAI webview will send request");
    if (![BookProtocol canInitWithRequest:request]) {
        NSLog(@"Oops, request %@ is not a book protocol request", request);
        return request;
    }
    
    NSMutableURLRequest *bookRequest = [[request mutableCopy] autorelease];
    [bookRequest setBookProtocolBook:self.document];
    NSLog(@"Yay, set a new book request %@ with bookself %@, %@, saved in it wewt", bookRequest, self.document, ((Book*)self.document).title);
    return bookRequest;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSLog(@"ENABULATE SCRIPTITATING");
    WebScriptObject *script = [sender windowScriptObject];
    [script setValue:self.document forKey:@"bewkbook"];
    [script evaluateWebScript:@"document.addEventListener('keypress', function (e) {"
     @"if (e.metaKey || e.ctrlKey || e.shiftKey) { window.bewkbook.log(\"some meta key is down\"); return true; }"
     @"window.bewkbook.log(e.keyCode);"
     @"if (e.keyCode != 32) { window.bewkbook.log(\"some key besides space was hit\"); return true; }"
     @"var scrollMaxY = document.documentElement.scrollHeight - document.documentElement.clientHeight;"
     @"window.bewkbook.log(\"Window scrollY: \" + window.scrollY + \" max scrollY: \" + scrollMaxY);"
     @"if (window.scrollY < scrollMaxY) { window.bewkbook.log(\"not at the end of the page\"); return true; }"
     @"window.bewkbook.nextChapter(); return false;"
     @"});"];
}

@end
