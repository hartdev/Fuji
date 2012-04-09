//
//  FUTransform.m
//  Fuji
//
//  Created by David Hart on 01.03.12.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//

#include "Prefix.pch"
#import "FUTransform.h"
#import "FUMath.h"
#import "FUComponent-Internal.h"
#import "FUEngine+Graphics.h"


@interface FUTransform ()

@property (nonatomic) GLKMatrix4 matrix;
@property (nonatomic) BOOL matrixNeedsUpdate;

@end


@implementation FUTransform

@synthesize position = _position;
@synthesize depth = _depth;
@synthesize rotation = _rotation;
@synthesize scale = _scale;
@synthesize matrix = _matrix;
@synthesize matrixNeedsUpdate = _matrixNeedsUpdate;

#pragma mark - Initialization

- (id)init
{
	if ((self = [super init]))
	{
		[self setScale:GLKVector2One];
	}
	
	return self;
}

#pragma mark - Properties

- (void)setPosition:(GLKVector2)position
{
	_position = position;
	[self setMatrixNeedsUpdate:YES];
}

- (float)positionX
{
	return [self position].x;
}

- (void)setPositionX:(float)positionX
{
	GLKVector2 position = [self position];
	position.x = positionX;
	[self setPosition:position];
}

- (float)positionY
{
	return [self position].y;
}

- (void)setPositionY:(float)positionY
{
	GLKVector2 position = [self position];
	position.y = positionY;
	[self setPosition:position];
}

- (void)setDepth:(float)depth
{
	_depth = depth;
	[self setMatrixNeedsUpdate:YES];
}

- (void)setRotation:(float)rotation
{
	_rotation = rotation;
	[self setMatrixNeedsUpdate:YES];
}

- (void)setScale:(GLKVector2)scale
{
	_scale = scale;
	[self setMatrixNeedsUpdate:YES];
}

- (float)scaleX
{
	return [self scale].x;
}

- (void)setScaleX:(float)scaleX
{
	GLKVector2 scale = [self scale];
	scale.x = scaleX;
	[self setScale:scale];
}

- (float)scaleY
{
	return [self scale].y;
}

- (void)setScaleY:(float)scaleY
{
	GLKVector2 scale = [self scale];
	scale.y = scaleY;
	[self setScale:scale];
}

- (GLKMatrix4)matrix
{
	if ([self matrixNeedsUpdate])
	{
		GLKVector2 position = [self position];
		_matrix = GLKMatrix4MakeTranslation(position.x, position.y, [self depth]);
		
		float rotation = [self rotation];
		
		if (rotation != 0)
		{
			_matrix = GLKMatrix4Rotate(_matrix, rotation, 0, 0, 1);
		}
		
		GLKVector2 scale = [self scale];
		
		if (!GLKVector2AllEqualToScalar(scale, 1))
		{
			_matrix = GLKMatrix4Scale(_matrix, scale.x, scale.y, 1);
		}
		
		[self setMatrixNeedsUpdate:NO];
	}
	
	return _matrix;
}

#pragma mark - FUEngineVisiting Methods

- (void)updateWithEngine:(FUEngine*)engine
{
	[engine updateTransform:self];
}

- (void)drawWithEngine:(FUEngine*)engine
{
	[engine drawTransform:self];
}

@end
