//
//  FUVisitor.m
//  Fuji
//
//  Created by David Hart.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "FUVisitor-Internal.h"
#import "FUSceneObject.h"


@implementation FUVisitor

#pragma mark - Class Methods

+ (SEL)visitSelectorForClass:(Class)sceneObjectClass
{
	if (![sceneObjectClass isSubclassOfClass:[FUSceneObject class]]) {
		return NULL;
	}
	
	static NSMutableDictionary* sSelectors;
	
	if (sSelectors == nil) {
		sSelectors = [NSMutableDictionary dictionary];
	}
	
	NSMutableDictionary* classSelectors = sSelectors[self];
	
	if (classSelectors == nil) {
		classSelectors = [NSMutableDictionary dictionary];
		sSelectors[(id<NSCopying>)self] = classSelectors;
	}
	
	NSString* selectorString = classSelectors[sceneObjectClass];
	SEL selector = NULL;
	
	if (selectorString == nil) {
		selectorString = [NSString stringWithFormat:@"visit%@:", NSStringFromClass(sceneObjectClass)];
		selector = NSSelectorFromString(selectorString);
		
		if (![self instancesRespondToSelector:selector]) {
			selector = [self visitSelectorForClass:[sceneObjectClass superclass]];
			selectorString = (selector != NULL) ? NSStringFromSelector(selector) : [NSString string];
		}
		
		classSelectors[(id<NSCopying>)sceneObjectClass] = selectorString;
	} else if ([selectorString length] != 0) {
		selector = NSSelectorFromString(selectorString);
	}
	
	return selector;
}

#pragma mark - Internal Methods

- (void)visitSceneObject:(FUSceneObject*)sceneObject
{
	SEL selector = [[self class] visitSelectorForClass:[sceneObject class]];
	
	if (selector != NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:selector withObject:sceneObject];
#pragma clang diagnostic pop
	}
}

@end
