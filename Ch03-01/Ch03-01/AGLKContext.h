//
//  AGLKContext.h
//  Ch03-01
//
//  Created by bqlin on 2018/7/18.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext

/// 仅当设置该值时，背景色才有效
@property (nonatomic, assign) GLKVector4 clearColor;

/// 通过掩码设置背景色
- (void)clear:(GLbitfield)mask;
- (void)enable:(GLenum)capability;
- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor;

@end
