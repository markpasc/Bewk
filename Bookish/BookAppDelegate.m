//
//  BookAppDelegate.m
//  Bookish
//
//  Created by Mark Paschal on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookAppDelegate.h"
#import "BookProtocol.h"


@implementation BookAppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [BookProtocol registerBookProtocol];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

@end
