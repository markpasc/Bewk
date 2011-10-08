//
//  BookWindow.m
//  Bookish
//
//  Created by Mark Paschal on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookWindow.h"
#import <WebKit/WebKit.h>
#import "Book.h"


@implementation BookWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    // This makes us a floaty utility window, but it isn't quite what we want.
    //aStyle = NSBorderlessWindowMask;
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];

    if (self) {
        // Initialize more?
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    // If we were a borderless window, this wouldn't be so, so set it anyway.
    return YES;
}

- (BOOL)canBecomeMainWindow {
    // If we were a borderless window, this wouldn't be so (I guess?), so set it anyway.
    return YES;
}

- (void)scrollPageUp:(id)sender {
    NSLog(@"OHAI SCROLL THE PAGE UPS");
    Book *book = (Book*)[self delegate];
    WebView *web = [book webview];
    WebScriptObject *scr = [web windowScriptObject];
    [scr callWebScriptMethod:@"previousChapterIfAtStart" withArguments:nil];
}

- (void)scrollPageDown:(id)sender {
    NSLog(@"OHAI SCROLL THE PAGE DOWNS");
    Book *book = (Book*)[self delegate];
    WebView *web = [book webview];
    WebScriptObject *scr = [web windowScriptObject];
    [scr callWebScriptMethod:@"nextChapterIfAtEnd" withArguments:nil];
}

- (void)sendEvent:(NSEvent *)event {
    // We probably don't get swipes since the gesture is decomposed and handled by the webview as type NSScrollWheel already.
    if ([event type] == NSKeyDown) {
        NSLog(@"~~ KEY DOWN %@ ~~", event);

        NSString *method = nil;
        if ([event keyCode] == 49 || [event keyCode] == 125) {
            method = @"nextChapterIfAtEnd";
        }
        else if ([event keyCode] == 126) {
            method = @"previousChapterIfAtStart";
        }
        else {
            NSLog(@"Unhandled keyCode %hu", [event keyCode]);
            [[self firstResponder] keyDown:event];
            return;
        }

        Book *book = (Book*)[self delegate];
        WebView *web = [book webview];
        WebScriptObject *scr = [web windowScriptObject];
        if ([scr callWebScriptMethod:method withArguments:nil])
            [[self firstResponder] keyDown:event];
    }
    else if ([event type] == NSEventTypeSwipe) {
        [self swipeWithEvent:event];
    }
    else {
        NSLog(@"bubbling event %@ to superwindow", event);
        [super sendEvent:event];
    }
}

- (void)swipeWithEvent:(NSEvent *)event {
    NSLog(@"YOINK there was a swipe %@", event);
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

@end
