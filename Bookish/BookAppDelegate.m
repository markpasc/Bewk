//
//  BookAppDelegate.m
//  Bookish
//
//  Created by Mark Paschal on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookAppDelegate.h"
#import "BookProtocol.h"


@interface BookAppDelegate ()

- (void)configureWebPreferences;

@end


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
    [self configureWebPreferences];
}

- (void)configureWebPreferences {
    WebPreferences *prefs = [[WebPreferences alloc] initWithIdentifier:[BookProtocol bookProtocolKey]];
    [prefs setPlugInsEnabled:NO];
    [prefs setJavaEnabled:NO];
    [prefs setJavaScriptEnabled:YES];
    [prefs setJavaScriptCanOpenWindowsAutomatically:NO];
    [prefs setUserStyleSheetEnabled:YES];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"book.css" ofType:nil inDirectory:@"css"];
    NSLog(@"CONFIGULATED user style path: %@", path);
    [prefs setUserStyleSheetLocation:[NSURL fileURLWithPath:path]];

    [prefs setAutosaves:NO];
    NSLog(@"PREFITATED webprefs \"%@\"", [prefs identifier]);

    [prefs release];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

@end
