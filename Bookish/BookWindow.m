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
#import <objc/objc-class.h>
#import "JRSwizzle.h"


@implementation BookWindow

BOOL SWIZZLED = NO;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    // This makes us a floaty utility window, but it isn't quite what we want.
    //aStyle = NSBorderlessWindowMask;
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];

    if (self) {
        // Initialize more?

        if (!SWIZZLED) {
            SWIZZLED = YES;
            [self swizzleThemeFrameDrawRects];
        }
    }
    return self;
}

- (void)swizzleThemeFrameDrawRects {
    id themeFrameClass = [[self.contentView superview] class];

    Method m = class_getInstanceMethod([self class], @selector(drawRect_frame:));
    class_addMethod(themeFrameClass, @selector(drawRect_titlebar:), method_getImplementation(m), method_getTypeEncoding(m));

    Method origMethod = class_getInstanceMethod(themeFrameClass, @selector(drawRect:));
    Method newMethod = class_getInstanceMethod(themeFrameClass, @selector(drawRect_titlebar:));
    method_exchangeImplementations(origMethod, newMethod);
}

- (void)drawRect_frame:(NSRect)rect {
    NSLog(@"AWW YEAH DRAWIN");
    //[self drawRect_titlebar:rect];
    [[self superview] drawRect:rect];
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
        if ([event keyCode] == 125) {
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
    else if ([event type] == NSMouseMoved || [event type] == NSMouseExited || [event type] == NSMouseEntered) {
        [super sendEvent:event];
    }
    else {
        //NSLog(@"bubbling event %@ to superwindow", event);
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
