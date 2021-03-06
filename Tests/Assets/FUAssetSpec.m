//
//  FUAsset.m
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
#import "FUAsset-Internal.h"
#import "FUTestSupport.h"


static NSString* const FUAccessMatchingMessage = @"Call to 'endContentAccess' on 'asset=%@' did not match a previous call to 'beginContentAccess'";
static NSString* const FUAccessMessage = @"Accessing 'asset=%@' without a prior call to 'beginContentAccess'";


SPEC_BEGIN(FUAsset)

describe(@"An asset", ^{
	it(@"conforms to the NSDiscardableContent protocol", ^{
		expect([[FUAsset class] conformsToProtocol:@protocol(NSDiscardableContent)]).to.beTruthy();
	});
	
	context(@"initialized an asset", ^{
		__block FUAsset* asset;
		
		beforeEach(^{
			asset = [FUAsset new];
		});
		
		it(@"is not discarded", ^{
			expect([asset isContentDiscarded]).to.beFalsy();
		});
		
		it(@"is accessible", ^{
			expect([asset beginContentAccess]).to.beTruthy();
		});
		
		context(@"accessing content", ^{
			it(@"does not throw", ^{
				[asset verifyAccessibility];
			});
		});
		
		context(@"attempting to discard content", ^{
			it(@"is not possible", ^{
				[asset discardContentIfPossible];
				expect([asset isContentDiscarded]).to.beFalsy();
			});
		});
		
		context(@"ended content access", ^{
			beforeEach(^{
				[asset endContentAccess];
			});
			
			it(@"is not discarded", ^{
				expect([asset isContentDiscarded]).to.beFalsy();
			});
			
			it(@"is accessible", ^{
				expect([asset beginContentAccess]).to.beTruthy();
			});
			
			context(@"ending content access", ^{
				it(@"throws an exception", ^{
					assertThrows([asset endContentAccess], NSInternalInconsistencyException,FUAccessMatchingMessage, asset);
				});
			});
			
			context(@"accessing content", ^{
				it(@"throws an exception", ^{
					assertThrows([asset verifyAccessibility], NSInternalInconsistencyException, FUAccessMessage, asset);
				});
			});
			
			context(@"attempting to discard content", ^{
				beforeEach(^{
					[asset discardContentIfPossible];
				});
				
				it(@"is discarded", ^{
					expect([asset isContentDiscarded]).to.beTruthy();
				});
				
				it(@"is not accessible", ^{
					expect([asset beginContentAccess]).to.beFalsy();
				});
				
				context(@"accessing content", ^{
					it(@"throws an exception", ^{
						assertThrows([asset verifyAccessibility], NSInternalInconsistencyException, FUAccessMessage, asset);
					});
				});
				
				context(@"ending content access", ^{
					it(@"throws an exception", ^{
						assertThrows([asset endContentAccess], NSInternalInconsistencyException, FUAccessMatchingMessage, asset);
					});
				});
			});
		});
		
		context(@"began content access", ^{
			beforeEach(^{
				[asset beginContentAccess];
			});
			
			it(@"is not discarded", ^{
				expect([asset isContentDiscarded]).to.beFalsy();
			});
			
			it(@"is accessible", ^{
				expect([asset beginContentAccess]).to.beTruthy();
			});
			
			context(@"accessing content", ^{
				it(@"does not throw", ^{
					[asset verifyAccessibility];
				});
			});
			
			context(@"ended content access", ^{
				beforeEach(^{
					[asset endContentAccess];
				});
				
				it(@"is not discarded", ^{
					expect([asset isContentDiscarded]).to.beFalsy();
				});
				
				it(@"is accessible", ^{
					expect([asset beginContentAccess]).to.beTruthy();
				});
				
				context(@"accessing content", ^{
					it(@"does not throw", ^{
						[asset verifyAccessibility];
					});
				});
				
				context(@"attempting to discard content", ^{
					it(@"is not possible", ^{
						[asset discardContentIfPossible];
						expect([asset isContentDiscarded]).to.beFalsy();
					});
				});
				
				context(@"ended content access", ^{
					beforeEach(^{
						[asset endContentAccess];
					});
					
					it(@"is not discarded", ^{
						expect([asset isContentDiscarded]).to.beFalsy();
					});
					
					it(@"is accessible", ^{
						expect([asset beginContentAccess]).to.beTruthy();
					});
					
					context(@"ending content access", ^{
						it(@"throws an exception", ^{
							assertThrows([asset endContentAccess], NSInternalInconsistencyException, FUAccessMatchingMessage, asset);
						});
					});
					
					context(@"accessing content", ^{
						it(@"throws an exception", ^{
							assertThrows([asset verifyAccessibility], NSInternalInconsistencyException, FUAccessMessage, asset);
						});
					});
					
					context(@"attempting to discard content", ^{
						beforeEach(^{
							[asset discardContentIfPossible];
						});
						
						it(@"is discarded", ^{
							expect([asset isContentDiscarded]).to.beTruthy();
						});
						
						it(@"is not accessible", ^{
							expect([asset beginContentAccess]).to.beFalsy();
						});
						
						context(@"accessing content", ^{
							it(@"throws an exception", ^{
								assertThrows([asset verifyAccessibility], NSInternalInconsistencyException, FUAccessMessage, asset);
							});
						});
						
						context(@"ending content access", ^{
							it(@"throws an exception", ^{
								assertThrows([asset endContentAccess], NSInternalInconsistencyException, FUAccessMatchingMessage, asset);
							});
						});
					});
				});
			});
		});
	});
});

SPEC_END
