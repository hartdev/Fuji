//
//  FUVisitable.h
//  Fuji
//
//  Created by David Hart on 3/27/12.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FUVisitable : NSObject

- (void)acceptVisitor:(id)visitor;

@end