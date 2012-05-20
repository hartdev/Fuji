//
//  FUTimingAction.h
//  Fuji
//
//  Created by David Hart
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "FUFiniteAction.h"
#import "FUTimingFunctions.h"


@interface FUTimingAction : FUFiniteAction

- (id)initWithAction:(FUFiniteAction*)action function:(FUTimingFunction)function;

@end


static OBJC_INLINE FUTimingAction* FUTiming(FUFiniteAction* action, FUTimingFunction function)
{
	return [[FUTimingAction alloc] initWithAction:action function:function];
}