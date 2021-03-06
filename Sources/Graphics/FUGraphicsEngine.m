//
//  FUGraphicsEngine.m
//  Fuji
//
//  Created by David Hart.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import "FUGraphicsEngine.h"
#import "FUColor.h"
#import "FUVisitor.h"
#import "FUViewController.h"
#import "FUScene.h"
#import "FUGraphicsSettings.h"
#import "FUTexture-Internal.h"
#import "FUSpriteBuffer-Internal.h"
#import "FUAssert.h"

#import "FUSpriteBatch-Internal.h"
#import "FUSpriteRenderer.h"
#import "FUTransform.h"


@interface FUGraphicsRegistrationVisitor : FUVisitor
@property (nonatomic, WEAK) FUGraphicsEngine* graphicsEngine;
@end

@interface FUGraphicsUnregistrationVisitor : FUVisitor
@property (nonatomic, WEAK) FUGraphicsEngine* graphicsEngine;
@end

@interface FUDrawBatch : NSObject
@property (nonatomic, strong) FUTexture* texture;
@property (nonatomic, strong) NSMutableArray* renderers;
@end


@interface FUGraphicsEngine ()

@property (nonatomic, strong) FUVisitor* registrationVisitor;
@property (nonatomic, strong) FUVisitor* unregistrationVisitor;
@property (nonatomic, strong) GLKBaseEffect* effect;
@property (nonatomic, strong) FUGraphicsSettings* settings;
@property (nonatomic, strong) FUSpriteBuffer* spriteBuffer;

@end


@implementation FUGraphicsEngine

#pragma mark - Initialization

- (id)init
{
	if (self = [super init]) {
		glEnable(GL_CULL_FACE);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDepthFunc(GL_LEQUAL);
		glClearDepthf(1.0f);
	}
	
	return self;
}

#pragma mark - Properties

- (FUVisitor*)registrationVisitor
{
	if (_registrationVisitor == nil) {
		FUGraphicsRegistrationVisitor* visitor = [FUGraphicsRegistrationVisitor new];
		[self setRegistrationVisitor:visitor];
		
		[visitor setGraphicsEngine:self];
	}
	
	return _registrationVisitor;
}

- (FUVisitor*)unregistrationVisitor
{
	if (_unregistrationVisitor == nil) {
		FUGraphicsUnregistrationVisitor* visitor = [FUGraphicsUnregistrationVisitor new];
		[self setUnregistrationVisitor:visitor];
		
		[visitor setGraphicsEngine:self];
	}
	
	return _unregistrationVisitor;
}

- (GLKBaseEffect*)effect
{
	if (_effect == nil) {
		GLKBaseEffect* effect = [GLKBaseEffect new];
		[self setEffect:effect];
		
		GLKEffectPropertyTexture* textureProperty = [[self effect] texture2d0];
		[textureProperty setEnvMode:GLKTextureEnvModeModulate];
		[textureProperty setTarget:GLKTextureTarget2D];
		
		[self updateProjection];
	}
 
	return _effect;
}

- (FUSpriteBuffer*)spriteBuffer
{
	if (_spriteBuffer == nil) {
		FUSpriteBuffer* spriteBuffer = [[FUSpriteBuffer alloc] initWithAssetStore:[[self director] assetStore]];
		[self setSpriteBuffer:spriteBuffer];
	}
	
	return _spriteBuffer;
}

#pragma mark - FUEngine Methods

- (void)unregisterAll
{
	[self setSettings:nil];
	[[self spriteBuffer] removeAllSprites];
}

#pragma mark - Drawing

- (void)update
{
	NSTimeInterval speed = [[self director] timeSinceFirstResume] * 5;
	
	[[[self spriteBuffer] spriteBatches] enumerateKeysAndObjectsUsingBlock:^(id key, FUSpriteBatch* batch, BOOL* stop) {
		[[batch	sprites] enumerateObjectsUsingBlock:^(FUSpriteRenderer* renderer, NSUInteger idx, BOOL* stop) {
			FUTransform* transform = [[renderer entity] transform];
			float scale = cosf(idx + (float)speed) * 0.25f + 1.0f;
			[transform setScale:GLKVector2Make(scale, scale)];
			
			float rotation = (float)(0.1 * (idx + speed) * M_PI);
			[transform setRotation:rotation];
		}];
	}];
}

- (void)draw
{
	[[self effect] prepareToDraw];
	
	[self clearScreen];
	[[self spriteBuffer] drawWithEffect:[self effect]];
}

#pragma mark - FUInterfaceRotation Methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateProjection];
}

#pragma mark - Private Methods

- (void)updateProjection
{
	CGSize viewSize = [[[self director] view] bounds].size;
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, viewSize.width, viewSize.height, 0, 0, FLT_MAX);
	
	GLKBaseEffect* effect = [self effect];
	[[effect transform] setProjectionMatrix:projectionMatrix];
	[effect prepareToDraw];
}

- (void)clearScreen
{
	FUGraphicsSettings* settings = [self settings];
	GLKVector4 backgroundColor = (settings != nil) ? [settings backgroundColor] : FUColorBlack;
	glClearColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

@end


@implementation FUGraphicsRegistrationVisitor

@synthesize graphicsEngine = _graphicsEngine;

- (void)visitFUGraphicsSettings:(FUGraphicsSettings*)graphicsSettings
{
	[[self graphicsEngine] setSettings:graphicsSettings];
}

- (void)visitFUSpriteRenderer:(FUSpriteRenderer*)renderer
{
	[[[self graphicsEngine] spriteBuffer] addSprite:renderer];
}

@end


@implementation FUGraphicsUnregistrationVisitor

@synthesize graphicsEngine = _graphicsEngine;

- (void)unregisterFUSpriteRenderer:(FUSpriteRenderer*)renderer
{
	[[[self graphicsEngine] spriteBuffer] removeSprite:renderer];
}

@end
