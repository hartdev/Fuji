//
//  FUScene.m
//  Fuji
//
//  Created by Hart David on 28.02.12.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//

#include "Prefix.pch"
#import "FUMacros.h"
#import "FUScene.h"
#import "FUScene-Internal.h"
#import "FUTransform.h"
#import "FUGraphicsSettings.h"
#import "FUEntity-Internal.h"
#import "FUEngine.h"
#import <objc/runtime.h>


static NSString* const FUEntityNilMessage = @"Expected 'entity' to not be nil";
static NSString* const FUEntityNonexistentMessage = @"Can not remove a 'entity=%@' that does not exist";


@interface FUScene ()

@property (nonatomic, WEAK) FUGraphicsSettings* graphics;
@property (nonatomic, strong) NSMutableSet* entities;

@end


@implementation FUScene

@synthesize director = _director;
@synthesize graphics = _graphics;
@synthesize entities = _entities;

#pragma mark - Class Methods

+ (NSDictionary*)componentProperties
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[FUGraphicsSettings class], @"graphics", nil];
}

#pragma mark - Initialization

- (id)init
{
	self = [super initWithScene:self];
	if (self == nil) return nil;
	
	[self removeComponent:[self transform]];
	[self addComponentWithClass:[FUGraphicsSettings class]];
	return self;
}

#pragma mark - Properties

- (NSMutableSet*)entities
{
	if (_entities == nil)
	{
		[self setEntities:[NSMutableSet set]];
	}
	
	return _entities;
}

#pragma mark - Public Methods

- (FUEntity*)createEntity
{
	FUEntity* entity = [[FUEntity alloc] initWithScene:self];
	[[self entities] addObject:entity];
	return entity;
}

- (void)removeEntity:(FUEntity*)entity
{
	FUAssert(entity != nil, FUEntityNilMessage);
	
	if (![[self entities] containsObject:entity])
	{
		FUThrow(FUEntityNonexistentMessage, entity);
	}
	
	[[self entities] removeObject:entity];
	[entity setScene:nil];
}

- (NSSet*)allEntities
{
	return [NSSet setWithSet:[self entities]];
}

#pragma mark - FUEngineVisiting Methods

- (void)updateWithEngine:(FUEngine*)engine
{
	[engine updateSceneEnter:self];
	
	for (FUComponent* component in [self components])
	{
		[component updateWithEngine:engine];
	}
	
	for (FUEntity* entity in [self entities])
	{
		[entity updateWithEngine:engine];
	}
	
	[engine updateSceneLeave:self];
}

- (void)drawWithEngine:(FUEngine*)engine
{
	[engine drawSceneEnter:self];
	
	for (FUComponent* component in [self components])
	{
		[component drawWithEngine:engine];
	}
	
	for (FUEntity* entity in [self entities])
	{
		[entity drawWithEngine:engine];
	}
	
	[engine drawSceneLeave:self];
}

#pragma mark - FUIntefaceOrientation Methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	for (FUEntity* entity in [self entities])
	{
		[entity willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	for (FUEntity* entity in [self entities])
	{
		[entity willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	for (FUEntity* entity in [self entities])
	{
		[entity didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	}
}

@end
