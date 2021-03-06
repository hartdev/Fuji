//
//  UIDevice+FUAdditions-Internal.h
//  Fuji
//
//  Created by David Hart
//  Copyright 2011 hart[dev]. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIDevice (FUAdditions)

@property (nonatomic, copy, readonly) NSString* platformSuffix;

+ (NSSet*)platformSuffixes;

@end
