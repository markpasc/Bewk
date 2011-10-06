//
//  BookAppDelegate.m
//  Bookish
//
//  Created by Mark Paschal on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookAppDelegate.h"
#import "BookProtocol.h"


NSString * const MPTypefaceKey = @"Typeface";
NSString * const MPTypeSizeKey = @"TypeSize";

NSString * const MPTypefaceGeorgia = @"Georgia";
NSString * const MPTypefaceHelvetica = @"Helvetica";
NSString * const MPTypeSizeBed = @"Bed";
NSString * const MPTypeSizeKnee = @"Knee";
NSString * const MPTypeSizeBreakfast = @"Breakfast";


@interface BookAppDelegate ()

- (void)configureWebPreferences;
- (void)configureTypefacePreference:(WebPreferences *)prefs fromDefaults:(NSUserDefaults *)defaults;
- (void)configureTypeSizePreference:(WebPreferences *)prefs fromDefaults:(NSUserDefaults *)defaults;

@end


@implementation BookAppDelegate

+ (void)initialize {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:MPTypefaceGeorgia forKey:MPTypefaceKey];
    [defaults setObject:MPTypeSizeBed forKey:MPTypeSizeKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self configureTypefacePreference:prefs fromDefaults:defaults];
    [self configureTypeSizePreference:prefs fromDefaults:defaults];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"book.css" ofType:nil inDirectory:@"web"];
    NSLog(@"CONFIGULATED user style path: %@", path);
    [prefs setUserStyleSheetLocation:[NSURL fileURLWithPath:path]];

    [prefs setAutosaves:NO];
    NSLog(@"PREFITATED webprefs \"%@\"", [prefs identifier]);

    [prefs release];
}

- (void)configureTypefacePreference:(WebPreferences *)prefs fromDefaults:(NSUserDefaults *)defaults {
    NSString *typeface = [defaults objectForKey:MPTypefaceKey];
    NSLog(@"CONFIGURATING with standard typeface %@", typeface);
    if (typeface)
        [prefs setStandardFontFamily:typeface];

    NSMenu *formatMenu = [[[NSApp mainMenu] itemWithTag:2] submenu];
    [[formatMenu itemWithTag:1] setState:[typeface isEqualToString:MPTypefaceGeorgia] ? NSOnState : NSOffState];
    [[formatMenu itemWithTag:2] setState:[typeface isEqualToString:MPTypefaceHelvetica] ? NSOnState : NSOffState];
}

- (void)configureTypeSizePreference:(WebPreferences *)prefs fromDefaults:(NSUserDefaults *)defaults {
    NSString *typeSize = [defaults objectForKey:MPTypeSizeKey];
    NSLog(@"CONFIGURATING with type size %@", typeSize);
    if (!typeSize)
        typeSize = MPTypeSizeBed;

    NSMenu *formatMenu = [[[NSApp mainMenu] itemWithTag:2] submenu];
    for (int tag = 3; tag <= 5; tag++) {
        [[formatMenu itemWithTag:3] setState:NSOffState];
    }

    if ([typeSize isEqualToString:MPTypeSizeBreakfast]) {
        [prefs setDefaultFontSize:24];
        [prefs setDefaultFixedFontSize:24];
        [[formatMenu itemWithTag:5] setState:NSOnState];
    }
    else if ([typeSize isEqualToString:MPTypeSizeKnee]) {
        [prefs setDefaultFontSize:20];
        [prefs setDefaultFixedFontSize:20];
        [[formatMenu itemWithTag:4] setState:NSOnState];
    }
    else if ([typeSize intValue] > 0) {
        int realTypeSize = [typeSize intValue];
        [prefs setDefaultFontSize:realTypeSize];
        [prefs setDefaultFixedFontSize:realTypeSize];
    }
    else {
        [prefs setDefaultFontSize:16];
        [prefs setDefaultFixedFontSize:16];
        [[formatMenu itemWithTag:3] setState:NSOnState];
    }
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

@end
