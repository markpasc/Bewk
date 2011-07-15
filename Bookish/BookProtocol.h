//
//  BookProtocol.h
//  Bookish
//
//  Created by Mark Paschal on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"


@interface BookProtocol : NSURLProtocol

+ (NSString *)bookProtocolScheme;
+ (NSString *)bookProtocolKey;
+ (void)registerBookProtocol;

@end

@interface NSURLRequest (BookProtocol)
- (Book*)bookProtocolBook;
@end

@interface NSMutableURLRequest (BookProtocol)
- (void)setBookProtocolBook:(Book *)book;
@end
