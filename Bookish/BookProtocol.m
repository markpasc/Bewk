//
//  BookProtocol.m
//  Bookish
//
//  Created by Mark Paschal on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookProtocol.h"

@implementation BookProtocol

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSString *)bookProtocolScheme {
    return @"bookishbook";
}

+ (NSString *)bookProtocolKey {
    return @"bookishbook";
}

+ (void)registerBookProtocol {
	static BOOL inited = NO;
	if (inited) return;

    [NSURLProtocol registerClass:[BookProtocol class]];
    inited = YES;
    NSLog(@"Registered book protocol!");
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"Can book protocol load request %@?", request);
    NSString *scheme = [[request URL] scheme];
    return [scheme caseInsensitiveCompare:[self bookProtocolScheme]] == NSOrderedSame;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSLog(@"Starting to load!");
    NSURLRequest *request = [self request];
    Book *book = [request bookProtocolBook];
    NSLog(@"Gonna load content from book %@", book);

    NSString *path = [[[request URL] path] substringFromIndex:1];
    NSLog(@"Looks like we want stuff from \"%@\"", path);
    NSString *contentType = nil;
    NSData *data = [book dataForResourcePath:path contentType:&contentType];
    NSLog(@"That file had %ld bytes of %@ data! Building response...", [data length], contentType);

    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:contentType expectedContentLength:[data length] textEncodingName:nil];

    id<NSURLProtocolClient> client = [self client];
    NSLog(@"Telling client they received a response");
	[client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    NSLog(@"Telling client the data they got");
	[client URLProtocol:self didLoadData:data];
    NSLog(@"Telling client that's it, done loading");
	[client URLProtocolDidFinishLoading:self];

	[response release];
}

- (void)stopLoading {
    // derp
}

@end


@implementation NSURLRequest (BookProtocol)

- (Book*)bookProtocolBook {
    return [NSURLProtocol propertyForKey:[BookProtocol bookProtocolKey] inRequest:self];
}

@end

@implementation NSMutableURLRequest (BookProtocol)

- (void)setBookProtocolBook:(Book *)book {
	[NSURLProtocol setProperty:book
                        forKey:[BookProtocol bookProtocolKey] inRequest:self];
}

@end