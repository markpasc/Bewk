//
//  BookWindowController.m
//  Bookish
//
//  Created by Mark Paschal on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookWindowController.h"
#import "BookProtocol.h"


NSString *bookControlJavascript = nil;


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

    NSLog(@"OHAI OHAI HOAHI webview has prefs \"%@\" (user style sheet %@: %@)",
          [[webview preferences] identifier],
          [[webview preferences] userStyleSheetEnabled] ? @"ENABLED" : @"UNNOTDISENABLED",
          [[[webview preferences] userStyleSheetLocation] absoluteString]);

    [self showWindow:nil];
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
    [script setValue:self.document forKey:@"bewk"];

    if (!bookControlJavascript) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"bookControl.js" ofType:nil inDirectory:@"web"];
        bookControlJavascript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        [bookControlJavascript retain];
    }
    [script evaluateWebScript:bookControlJavascript];
}

@end
