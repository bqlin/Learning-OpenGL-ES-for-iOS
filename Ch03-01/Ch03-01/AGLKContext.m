//
//  AGLKContext.m
//  Ch03-01
//
//  Created by bqlin on 2018/7/18.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext

#pragma mark - property

- (void)setClearColor:(GLKVector4)clearColor {
	_clearColor = clearColor;
	
	NSAssert(self == [self.class currentContext], @"receiving context required to be current context");
	
	glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
}

- (void)clear:(GLbitfield)mask {
	NSAssert(self == [self.class currentContext], @"receiving context required to be current context");
	
	glClear(mask);
}

- (void)enable:(GLenum)capability {
	NSAssert(self == [self.class currentContext], @"receiving context required to be current context");
	
	glEnable(capability);
}

- (void)disable:(GLenum)capability {
	NSAssert(self == [self.class currentContext], @"receiving context required to be current context");
	
	glDisable(capability);
}

- (void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor {
	glBlendFunc(sfactor, dfactor);
}

@end
