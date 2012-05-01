//
//  FUEntity-Internal.h
//  Fuji
//
//  Created by David Hart
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import "FUEntity.h"


@interface FUEntity ()

@property (nonatomic, strong) NSMutableArray* components;

+ (NSDictionary*)componentProperties;
+ (NSDictionary*)allComponentProperties;

@end