//
//  FUGameObjectSpec.m
//  Fuji
//
//  Created by Hart David on 24.02.12.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//

#include "Prefix.pch"
#import "FujiCore.h"
#import "FUGameObject-Internal.h"
#import "FUComponent-Internal.h"
#import "FUTestComponents.h"


SPEC_BEGIN(FUGameObjectSpec)

describe(@"A game object", ^{
	context(@"initialized with init", ^{
#ifdef DEBUG
		it(@"throws an exception", ^{
			STAssertThrows([FUGameObject new], nil);
		});
#else
		it(@"returns nil", ^{
			expect([FUGameObject new]).to.beNil();
		});
#endif
	});
	
	context(@"initialized with a nil scene", ^{
#ifdef DEBUG
		it(@"throws an exception", ^{
			STAssertThrows(((void)[[FUGameObject alloc] initWithScene:nil]), nil);
		});
#else
		it(@"returns nil", ^{
			expect([[FUGameObject alloc] initWithScene:nil]).to.beNil();
		});
#endif
	});
	
	context(@"initialized with a valid scene", ^{
		__block FUScene* scene = nil;
		__block FUGameObject* gameObject = nil;
		
		beforeEach(^{
			scene = mock([FUScene class]);
			gameObject = [[FUGameObject alloc] initWithScene:scene];
		});
		
		it(@"is not nil", ^{
			expect(gameObject).toNot.beNil();
		});
		
		it(@"has the scene property set", ^{
			expect([gameObject scene]).to.beIdenticalTo(scene);
		});
		
		context(@"adding a component with a NULL class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject addComponentWithClass:NULL], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject addComponentWithClass:NULL]).to.beNil();
			});
#endif
		});
		
		context(@"adding a component with a class that does not subclass FUComponent", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject addComponentWithClass:[NSString class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject addComponentWithClass:[NSString class]]).to.beNil();
			});
#endif
		});
		
		context(@"adding a component with the FUComponent class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject addComponentWithClass:[FUComponent class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject addComponentWithClass:[FUComponent class]]).to.beNil();
			});
#endif
		});
		
		context(@"adding a component that requires an object that is not a class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject addComponentWithClass:[FURequireObjectComponent class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject addComponentWithClass:[FURequireObjectComponent class]]).to.beNil();
			});
#endif
		});
		
		context(@"adding a component that requires a class that does not subclass FUComponent", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject addComponentWithClass:[FURequireNSStringComponent class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject addComponentWithClass:[FURequireNSStringComponent class]]).to.beNil();
			});
#endif
		});
		
		context(@"adding a component that requires a FUComponent", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject addComponentWithClass:[FURequireBaseComponent class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject addComponentWithClass:[FURequireBaseComponent class]]).to.beNil();
			});
#endif
		});
		
		context(@"getting a component with a NULL class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject componentWithClass:NULL], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject componentWithClass:NULL]).to.beNil();
			});
#endif
		});
		
		context(@"getting a component with the FUComponent class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject componentWithClass:[FUComponent class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject componentWithClass:[FUComponent class]]).to.beNil();
			});
#endif
		});
		
		context(@"getting a component with a subclass of FUComponent", ^{
			it(@"returns nil", ^{
				expect([gameObject componentWithClass:[FUTestComponent class]]).to.beNil();
			});
		});
		
		context(@"getting all components with a NULL class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject allComponentsWithClass:NULL], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject allComponentsWithClass:NULL]).to.beNil();
			});
#endif
		});
		
		context(@"getting all components with the FUComponent class", ^{
#ifdef DEBUG
			it(@"throws an exception", ^{
				STAssertThrows([gameObject allComponentsWithClass:[FUComponent class]], nil);
			});
#else
			it(@"returns nil", ^{
				expect([gameObject allComponentsWithClass:[FUComponent class]]).to.beNil();
			});
#endif
		});
		
		context(@"getting all components with a subclass of FUComponent", ^{
			it(@"returns an empty set", ^{
				expect([gameObject allComponentsWithClass:[FUTestComponent class]]).to.beEmpty();
			});
		});

		context(@"added a component that is unique", ^{
			__block FUTestComponent* component1 = nil;
			__block FUTestComponent* returnedComponent1 = nil;
			
			beforeEach(^{
				component1 = [FUTestComponent testComponent];
				[FUTestComponent setAllocReturnValue:component1];
				returnedComponent1 = (FUTestComponent*)[gameObject addComponentWithClass:[FUTestComponent class]];
			});
			
			it(@"initializes a new component", ^{
				expect([component1 wasInitCalled]).to.beTruthy();
				expect([component1 wasAwakeCalled]).to.beTruthy();
			});
			
			it(@"returns the created component", ^{
				expect(returnedComponent1).to.beIdenticalTo(component1);
			});
			
			context(@"getting a component with the same class", ^{
				it(@"returns the component", ^{
					expect([gameObject componentWithClass:[FUTestComponent class]]).to.beIdenticalTo(component1);
				});
			});
			
			context(@"getting a component with a subclass of that class", ^{
				it(@"returns nil", ^{
					expect([gameObject componentWithClass:[FUCommonComponent class]]).to.beNil();
				});
			});
			
			context(@"getting a component with a different class", ^{
				it(@"returns nil", ^{
					expect([gameObject componentWithClass:[FURequireBaseComponent class]]).to.beNil();
				});
			});
			
			context(@"getting all the components with the same class", ^{
				it(@"returns a set with the component", ^{
					NSSet* components = [gameObject allComponentsWithClass:[FUTestComponent class]];
					expect(components).to.haveCountOf(1);
					expect(components).to.contain(component1);
				});
			});
			
			context(@"getting all the components with a subclass of that class", ^{
				it(@"returns an empty set", ^{
					expect([gameObject allComponentsWithClass:[FUCommonComponent class]]).to.beEmpty();
				});
			});
			
			context(@"getting all the components with a different class", ^{
				it(@"returns an empty set", ^{
					expect([gameObject allComponentsWithClass:[FURequireBaseComponent class]]).to.beEmpty();
				});
			});
			
			context(@"adding a second component with the same unique class", ^{
#ifdef DEBUG
				it(@"throws on exception", ^{
					STAssertThrows([gameObject addComponentWithClass:[FUTestComponent class]], nil);
				});
#else
				it(@"returns nil", ^{
					FUComponent* component = [gameObject addComponentWithClass:[FUTestComponent class]];
					expect(component).to.beNil();
				});
#endif
			});
			
			context(@"added a second component with a non-unique subclass", ^{
				__block FUCommonComponent* component2 = nil;
				__block FUCommonComponent* returnedComponent2 = nil;
				
				beforeEach(^{
					component2 = [FUCommonComponent testComponent];
					[FUCommonComponent setAllocReturnValue:component2];
					returnedComponent2 = (FUCommonComponent*)[gameObject addComponentWithClass:[FUCommonComponent class]];
				});
				
				it(@"initializes a new component", ^{
					expect([component2 wasInitCalled]).to.beTruthy();
					expect([component2 wasAwakeCalled]).to.beTruthy();
				});
				
				it(@"returns the created component", ^{
					expect(returnedComponent2).to.beIdenticalTo(component2);
				});
				
				context(@"getting a component with the first class", ^{
					it(@"returns any of the components", ^{
						FUComponent* searchedComponent = [gameObject componentWithClass:[FUTestComponent class]];
						expect((searchedComponent == component1) || (searchedComponent == component2)).to.beTruthy();
					});
				});
				
				context(@"getting a component with the second class", ^{
					it(@"returns the second component", ^{
						expect([gameObject componentWithClass:[FUCommonComponent class]]).to.beIdenticalTo(component2);
					});
				});
				
				context(@"getting a component with a different class", ^{
					it(@"returns nil", ^{
						expect([gameObject componentWithClass:[FURequireBaseComponent class]]).to.beNil();
					});
				});
				
				context(@"getting all the components with the first class", ^{
					it(@"returns a set with both components", ^{
						NSSet* components = [gameObject allComponentsWithClass:[FUTestComponent class]];
						expect(components).to.haveCountOf(2);
						expect(components).to.contain(component1);
						expect(components).to.contain(component2);
					});
				});
				
				context(@"getting all the components with the second class", ^{
					it(@"returns a set with the second component", ^{
						NSSet* components = [gameObject allComponentsWithClass:[FUCommonComponent class]];
						expect(components).to.haveCountOf(1);
						expect(components).to.contain(component2);
					});
				});
				
				context(@"getting all the components with a different class", ^{
					it(@"returns an empty set", ^{
						expect([gameObject allComponentsWithClass:[FURequireBaseComponent class]]).to.beEmpty();
					});
				});
				
				context(@"added a third component with the second non-unique class", ^{
					__block FUCommonComponent* component3 = nil;
					__block FUCommonComponent* returnedComponent3 = nil;
					
					beforeEach(^{
						component3 = [FUCommonComponent testComponent];
						[FUCommonComponent setAllocReturnValue:component3];
						returnedComponent3 = (FUCommonComponent*)[gameObject addComponentWithClass:[FUCommonComponent class]];
					});
					
					it(@"initializes a new component", ^{
						expect([component3 wasInitCalled]).to.beTruthy();
						expect([component3 wasAwakeCalled]).to.beTruthy();
					});
					
					it(@"returns the created component", ^{
						expect(returnedComponent3).to.beIdenticalTo(component3);
					});
					
					context(@"getting a component with the first class", ^{
						it(@"returns any of the components", ^{
							FUComponent* searchedComponent = [gameObject componentWithClass:[FUTestComponent class]];
							expect((searchedComponent == component1) || (searchedComponent == component2) || (searchedComponent == component3)).to.beTruthy();
						});
					});
					
					context(@"getting a component with the second class", ^{
						it(@"returns any of the last two components", ^{
							FUComponent* searchedComponent = [gameObject componentWithClass:[FUCommonComponent class]];
							expect((searchedComponent == component2) || (searchedComponent == component3)).to.beTruthy();
						});
					});
					
					context(@"getting a component with a different class", ^{
						it(@"returns nil", ^{
							expect([gameObject componentWithClass:[FURequireBaseComponent class]]).to.beNil();
						});
					});
					
					context(@"getting all the components with the first class", ^{
						it(@"returns a set with all components", ^{
							NSSet* components = [gameObject allComponentsWithClass:[FUTestComponent class]];
							expect(components).to.haveCountOf(3);
							expect(components).to.contain(component1);
							expect(components).to.contain(component2);
							expect(components).to.contain(component3);
						});
					});
					
					context(@"getting all the components with the second class", ^{
						it(@"returns a set with the last two components", ^{
							NSSet* components = [gameObject allComponentsWithClass:[FUCommonComponent class]];
							expect(components).to.haveCountOf(2);
							expect(components).to.contain(component2);
							expect(components).to.contain(component3);
						});
					});
					
					context(@"getting all the components with a different class", ^{
						it(@"returns an empty set", ^{
							expect([gameObject allComponentsWithClass:[FURequireBaseComponent class]]).to.beEmpty();
						});
					});
				});
			});
		});
	});
});

SPEC_END
