//
//  BookWindow.m
//  Bookish
//
//  Created by Mark Paschal on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookWindow.h"

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

@end
