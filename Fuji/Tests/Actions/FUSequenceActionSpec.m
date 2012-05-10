//
//  FUSequenceActionSpec.m
//  Fuji
//
//  Created by David Hart
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#include "Prefix.pch"
#import "Fuji.h"
#import "FUFiniteAction-Internal.h"
#import "FUTestSupport.h"


static NSString* const FUArrayNilMessage = @"Expected array to not be nil";
static NSString* const FUFiniteActionSubclassMessage = @"Expected 'action=%@' to not be a subclass of FUFiniteAction";


SPEC_BEGIN(FUSequenceAction)

describe(@"A sequence action", ^{
	it(@"is a finite action", ^{
		expect([FUSequenceAction class]).to.beSubclassOf([FUFiniteAction class]);
	});
	
	context(@"initilized with a nil array", ^{
		it(@"throws an exception", ^{
			assertThrows([FUSequenceAction sequenceWithArray:nil], NSInvalidArgumentException, FUArrayNilMessage);
		});
	});
	
	context(@"initilized with an empty nil-terminated list", ^{
		it(@"does not throw", ^{
			assertNoThrow([FUSequenceAction sequenceWithActions:nil]);
		});
	});
	
	context(@"initializing with an array containing an object that is not a FUFiniteAction", ^{
		it(@"throws an exception", ^{
			id object = [NSString string];
			NSArray* array = [NSArray arrayWithObject:object];
			assertThrows([FUSequenceAction sequenceWithArray:array], NSInvalidArgumentException, FUFiniteActionSubclassMessage, object);
		});
	});
	
	context(@"initilizing with three actions", ^{
		__block FUFiniteAction* action1;
		__block FUFiniteAction* action2;
		__block FUFiniteAction* action3;
		__block NSMutableArray* actions;
		__block FUSequenceAction* sequence;
		
		beforeEach(^{
			action1 = mock([FUFiniteAction class]);
			[given([action1 isKindOfClass:[FUFiniteAction class]]) willReturnBool:YES];
			[given([action1 duration]) willReturnDouble:1.5];
			
			action2 = mock([FUFiniteAction class]);
			[given([action2 isKindOfClass:[FUFiniteAction class]]) willReturnBool:YES];
			[given([action2 duration]) willReturnDouble:2.0];
			
			action3 = mock([FUFiniteAction class]);
			[given([action3 isKindOfClass:[FUFiniteAction class]]) willReturnBool:YES];
			[given([action3 duration]) willReturnDouble:0.3];
			
			actions = [NSMutableArray arrayWithObjects:action1, action2, action3, nil];
			sequence = [FUSequenceAction sequenceWithArray:actions];
		});
		
		it(@"is not nil", ^{
			expect(sequence).toNot.beNil();
		});
		
		it(@"is not complete", ^{
			expect([sequence isComplete]).to.beFalsy();
		});
		
		it(@"has it's duration as the sum of the action's durations", ^{
			expect([sequence duration]).to.equal(3.8);
		});
		
		context(@"updating the sequence with 1 second", ^{
			beforeEach(^{
				[sequence updateWithDeltaTime:1];
			});
			
			it(@"is not complete", ^{
				expect([sequence isComplete]).to.beFalsy();
			});
			
			it(@"updates only the first action", ^{
				[verify(action1) updateWithDeltaTime:1];
				[[verifyCount(action2, never()) withMatcher:HC_anything()] updateWithDeltaTime:0];
				[[verifyCount(action3, never()) withMatcher:HC_anything()] updateWithDeltaTime:0];
			});
			
			context(@"updating the sequence with 2 seconds", ^{
				beforeEach(^{
					[given([action1 time]) willReturnDouble:1];
					[sequence updateWithDeltaTime:2];
				});
				
				it(@"is not complete", ^{
					expect([sequence isComplete]).to.beFalsy();
				});
				
				it(@"updates the first and second action", ^{
					[verify(action1) updateWithDeltaTime:2];
					[[verify(action2) withMatcher:HC_closeTo(1.5, DBL_EPSILON)] updateWithDeltaTime:1.5];
					[[verifyCount(action3, never()) withMatcher:HC_anything()] updateWithDeltaTime:0];
				});
				
				context(@"updating the sequence with 1 seconds", ^{
					beforeEach(^{
						[given([action1 isComplete]) willReturnBool:YES];
						[given([action2 time]) willReturnDouble:1.5];
						[sequence updateWithDeltaTime:1];
					});
					
					it(@"is complete", ^{
						expect([sequence isComplete]).to.beTruthy();
					});
					
					it(@"updates the first and second action", ^{
						[[verifyCount(action1, times(2)) withMatcher:HC_anything()] updateWithDeltaTime:0];
						[verify(action2) updateWithDeltaTime:1];
						[[verify(action3) withMatcher:HC_closeTo(0.5, DBL_EPSILON)] updateWithDeltaTime:0.5];
					});
				});
			});
		});
	});
	
	pending(@"test that adding actions to an NSMutableArray does not add extra actions to the sequence");
});

SPEC_END