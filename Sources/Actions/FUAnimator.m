//
//  FUAnimator.m
//  Fuji
//
//  Created by David Hart.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "FUAnimator.h"
#import "FUAction.h"
#import "FUViewController-Internal.h"
#import "FUSupport.h"


static NSString* const FUActionNilMessage = @"Expected 'action' to not be nil";


@interface FUAnimator ()

@property (nonatomic, strong) NSMutableArray* actions;

@end


@implementation FUAnimator

#pragma mark - Initialization

- (id)copyWithZone:(NSZone*)zone
{
	FUAnimator* copy = [[[self class] allocWithZone:zone] init];
	[copy setActions:[[NSMutableArray alloc] initWithArray:[self actions] copyItems:YES]];
	return copy;
}

#pragma mark - Properties

- (NSMutableArray*)actions
{
	if (_actions == nil) {
		[self setActions:[NSMutableArray array]];
	}
	
	return _actions;
}

#pragma mark - Public Methods

- (void)runAction:(id<FUAction>)action
{
	FUCheck(action != nil, FUActionNilMessage);
	[[self actions] addObject:action];
}

#pragma mark - FUUpdatableComponent Methods

- (void)update
{
	NSTimeInterval deltaTime = [[self director] timeSinceLastUpdate];
	
	if (deltaTime == 0.0) {
		return;
	}
	
	__block NSMutableIndexSet* completeIndices;
	
	[[self actions] enumerateObjectsUsingBlock:^(id<FUAction> action, NSUInteger index, BOOL* stop) {
		NSTimeInterval timeLeft = [action consumeDeltaTime:deltaTime];
		
		if (timeLeft > 0.0) {
			if (completeIndices == nil) {
				completeIndices = [NSMutableIndexSet indexSet];
			}
			
			[completeIndices addIndex:index];
		}
	}];
	
	if (completeIndices != nil) {
		[[self actions] removeObjectsAtIndexes:completeIndices];
	}
}

@end
