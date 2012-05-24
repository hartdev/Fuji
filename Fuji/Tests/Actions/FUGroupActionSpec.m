//
//  FUGroupActionSpec.m
//  Fuji
//
//  Created by David Hart.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#include "Prefix.pch"
#import "Fuji.h"
#import "FUTestSupport.h"


static NSString* const FUArrayNilMessage = @"Expected array to not be nil";
static NSString* const FUActionProtocolMessage = @"Expected 'action=%@' to conform to the FUAction protocol";


SPEC_BEGIN(FUGroupAction)

describe(@"A group action", ^{
	it(@"is an action", ^{
		expect([[FUGroupAction class] conformsToProtocol:@protocol(FUAction)]).to.beTruthy();
	});
	
	context(@"initilized with a nil array", ^{
		it(@"throws an exception", ^{
			assertThrows([[FUGroupAction alloc] initWithActions:nil], NSInvalidArgumentException, FUArrayNilMessage);
		});
	});
	
	context(@"initilized with an empty array", ^{
		it(@"does not throw", ^{
			assertNoThrow([[FUGroupAction alloc] initWithActions:[NSArray array]]);
		});
	});
	
	context(@"initializing with an array containing an object that is not an FUAction", ^{
		it(@"throws an exception", ^{
			id object = [NSString string];
			NSArray* array = [NSArray arrayWithObject:object];
			assertThrows([[FUGroupAction alloc] initWithActions:array], NSInvalidArgumentException, FUActionProtocolMessage, object);
		});
	});
	
	context(@"initializing via the function with no actions", ^{
		it(@"returns a FUGroupAction", ^{
			expect(FUGroup()).to.beKindOf([FUGroupAction class]);
		});
	});
	
	context(@"initializing with three actions", ^{
		__block NSObject<FUAction>* action1;
		__block NSObject<FUAction>* action2;
		__block NSObject<FUAction>* action3;
		__block NSMutableArray* actions;
		__block FUGroupAction* group;
		
		beforeEach(^{
			action1 = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
			action2 = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
			action3 = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
			actions = [NSMutableArray arrayWithObjects:action1, action2, action3, nil];
			group = [[FUGroupAction alloc] initWithActions:actions];
		});
		
		context(@"initializing via the function with three actions", ^{
			it(@"returns a FUGroupAction", ^{
				expect(FUGroup(action1, action2, action3)).to.beKindOf([FUGroupAction class]);
			});
		});
		
		it(@"is not nil", ^{
			expect(group).toNot.beNil();
		});
		
		it(@"contains all three actions", ^{
			NSArray* actionsArray = [group actions];
			expect(actionsArray).to.haveCountOf(3);
			expect(actionsArray).to.contain(action1);
			expect(actionsArray).to.contain(action2);
			expect(actionsArray).to.contain(action3);
		});
		
		context(@"calling consumeDeltaTime: on the group with 0.0 seconds", ^{
			it(@"does not call consumeDeltaTime: on any actions", ^{
				[group consumeDeltaTime:0.0];
				[[verifyCount(action1, never()) withMatcher:HC_anything()] consumeDeltaTime:0.0];
				[[verifyCount(action2, never()) withMatcher:HC_anything()] consumeDeltaTime:0.0];
				[[verifyCount(action3, never()) withMatcher:HC_anything()] consumeDeltaTime:0.0];
			});
		});
		
		context(@"called consumeDeltaTime: with a positive time on the group", ^{
			__block NSTimeInterval timeLeft1;
			
			beforeEach(^{
				timeLeft1 = [group consumeDeltaTime:1.0];
			});
			
			it(@"returns no time left", ^{
				expect(timeLeft1).to.equal(0.0);
			});
			
			it(@"calls consumeDeltaTime: with the same time on all actions", ^{
				[verify(action1) consumeDeltaTime:1.0];
				[verify(action2) consumeDeltaTime:1.0];
				[verify(action3) consumeDeltaTime:1.0];
			});
			
			context(@"called consumeDeltaTime: on the group with one action returning some time left", ^{
				__block NSTimeInterval timeLeft2;
				
				beforeEach(^{
					[given([action3 consumeDeltaTime:2.0]) willReturnDouble:0.5];
					timeLeft2 = [group consumeDeltaTime:2.0];
				});
				
				it(@"returns no time left", ^{
					expect(timeLeft2).to.equal(0.0);
				});
				
				it(@"calls consumeDeltaTime: with the same time on all actions", ^{
					[verify(action1) consumeDeltaTime:2.0];
					[verify(action2) consumeDeltaTime:2.0];
					[verify(action3) consumeDeltaTime:2.0];
				});
				
				context(@"called consumeDeltaTime: on the group with all actions returning some time left", ^{
					__block NSTimeInterval timeLeft3;
					
					beforeEach(^{
						[given([action1 consumeDeltaTime:3.0]) willReturnDouble:0.8];
						[given([action2 consumeDeltaTime:3.0]) willReturnDouble:0.2];
						[given([action3 consumeDeltaTime:3.0]) willReturnDouble:0.5];
						timeLeft3 = [group consumeDeltaTime:3.0];
					});
					
					it(@"returns the smallest time left", ^{
						expect(timeLeft3).to.equal(0.2);
					});
					
					it(@"calls consumeDeltaTime: with the same time all actions", ^{
						[verify(action1) consumeDeltaTime:3.0];
						[verify(action2) consumeDeltaTime:3.0];
						[verify(action3) consumeDeltaTime:3.0];
					});
				});
				
				context(@"called consumeDeltaTime with a negative time on the group and with all actions returing some time left", ^{
					__block NSTimeInterval timeLeft5;
					
					beforeEach(^{
						[given([action1 consumeDeltaTime:-5.0]) willReturnDouble:-0.8];
						[given([action2 consumeDeltaTime:-5.0]) willReturnDouble:-1.2];
						[given([action3 consumeDeltaTime:-5.0]) willReturnDouble:-2.0];
						timeLeft5 = [group consumeDeltaTime:-5.0];
					});
					
					it(@"returns -0.8 seconds left", ^{
						expect(timeLeft5).to.equal(-0.8);
					});
					
					it(@"calls consumeDeltaTime: with the same time on all actions", ^{
						[verify(action3) consumeDeltaTime:-5.0];
						[verify(action2) consumeDeltaTime:-5.0];
						[verify(action1) consumeDeltaTime:-5.0];
					});
				});
				
				context(@"called consumeDeltaTime on a copy of the group", ^{
					__block FUGroupAction* groupCopy;
					__block NSObject<FUAction>* action1Copy;
					__block NSObject<FUAction>* action2Copy;
					__block NSObject<FUAction>* action3Copy;
					
					beforeEach(^{
						action1Copy = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
						[given([action1 copy]) willReturn:action1Copy];
						
						action2Copy = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
						[given([action2 copy]) willReturn:action2Copy];
						
						action3Copy = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
						[given([action3 copy]) willReturn:action3Copy];
						
						groupCopy = [group copy];
						[groupCopy consumeDeltaTime:4.0];
					});
					
					it(@"is not nil", ^{
						expect(groupCopy).toNot.beNil();
					});
					
					it(@"is not the same instance", ^{
						expect(groupCopy).toNot.beIdenticalTo(group);
					});
					
					it(@"contains all three copied actions", ^{
						NSArray* actionsArray = [groupCopy actions];
						expect(actionsArray).to.haveCountOf(3);
						expect(actionsArray).to.contain(action1Copy);
						expect(actionsArray).to.contain(action2Copy);
						expect(actionsArray).to.contain(action3Copy);
					});
					
					it(@"does not call consumeDeltaTime: on the original actions", ^{
						[[verifyCount(action1, times(2)) withMatcher:HC_anything()] consumeDeltaTime:0.0];
						[[verifyCount(action2, times(2)) withMatcher:HC_anything()] consumeDeltaTime:0.0];
						[[verifyCount(action3, times(2)) withMatcher:HC_anything()] consumeDeltaTime:0.0];
					});
					
					it(@"calls consumeDeltaTime: with the same time on the copied actions", ^{
						[verify(action1Copy) consumeDeltaTime:4.0];
						[verify(action2Copy) consumeDeltaTime:4.0];
						[verify(action3Copy) consumeDeltaTime:4.0];
					});
				});
			});
		});
		
		context(@"added an action to the actions array", ^{
			__block NSObject<FUAction>* extraAction;
			
			beforeEach(^{
				extraAction = mockObjectAndProtocol([NSObject class], @protocol(FUAction));
				[actions addObject:extraAction];
			});
			
			it(@"does not contain the extra action", ^{
				expect([group actions]).toNot.contain(extraAction);
			});
			
			context(@"calling consumeDeltaTime: on the group", ^{
				it(@"does not call consumeDeltaTime: on the extra action", ^{
					[group consumeDeltaTime:10.0];
					[[verifyCount(extraAction, never()) withMatcher:HC_anything()] consumeDeltaTime:0.0];
				});
			});
		});
	});
});

SPEC_END