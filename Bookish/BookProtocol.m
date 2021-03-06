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
    return @"bewkbook";
}

+ (NSString *)bookProtocolKey {
    return @"bewkbook";
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

    NSString *contentType = nil;
    NSString *path = [[[request URL] path] substringFromIndex:2 + [[book bookId] length]];
    NSLog(@"With URL path \"%@\" and book ID \"%@\", looks like we want book stuff from \"%@\"", [[request URL] path], [book bookId], path);
    NSData *data = [book dataForResourcePath:path contentType:&contentType];

    id<NSURLProtocolClient> client = [self client];
    if (!data) {
        NSDictionary *userinfo = [NSDictionary dictionaryWithObject:[request URL] forKey:NSURLErrorKey];
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:404 userInfo:userinfo];
        [client URLProtocol:self didFailWithError:error];
        NSLog(@"Telling client that's it, done loading");
        [client URLProtocolDidFinishLoading:self];
        return;
    }

    NSLog(@"That file had %ld bytes of %@ data! Building response...", [data length], contentType);
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:contentType expectedContentLength:[data length] textEncodingName:nil];
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
    NSLog(@"~YAY set book protocol book for request %@ to %@!~", self, book);
}

@end
