//
//  FUSupport.h
//  Fuji
//
//  Created by David Hart.
//  Copyright (c) 2012 hart[dev]. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>


#ifndef TEST
#define WEAK weak
#else
#define WEAK unsafe_unretained
#endif


#define NSTimerStart() \
	static uint64_t __totalTime = 0; \
	static uint64_t __sampleCount = 0; \
	uint64_t __startTime = mach_absolute_time();
#define NSTimerEnd() \
	uint64_t __endTime = mach_absolute_time(); \
	__totalTime += __endTime - __startTime; \
	__sampleCount++; \
	if (__sampleCount % 1000 == 0) { \
		mach_timebase_info_data_t __timer; \
		mach_timebase_info(&__timer); \
		uint64_t __time = (__totalTime / __sampleCount) * __timer.numer / __timer.denom; \
		NSLog(@"%@ Timer: %quns", NSStringFromSelector(_cmd), __time); \
	}


// From http://lukeredpath.co.uk/blog/a-note-on-objective-c-singletons.html
#define FU_SINGLETON_WITH_BLOCK(block) \
	static dispatch_once_t __predicate = 0; \
	__strong static id __singleton; \
	dispatch_once(&__predicate, ^{ \
		__singleton = block(); \
	}); \
	return __singleton;
