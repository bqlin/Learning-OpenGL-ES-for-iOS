//
//  AGLKContext.h
//  Ch03-01
//
//  Created by bqlin on 2018/7/18.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

/**
 EAGLContext 子类，仅添加了 `clearColor` 属性，使用 OC 封装了一些 C 接口
 */
@interface AGLKContext : EAGLContext

/// 仅当设置该值时，背景色才有效，setter 内部调用 `glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a)`
@property (nonatomic, assign) GLKVector4 clearColor;

/// 通过掩码设置背景色，内部调用 `glClear(mask);`
- (void)clear:(GLbitfield)mask;

/// 内部调用 `glEnable(capability)`
- (void)enable:(GLenum)capability;

/// 内部调用 `glDisable(capability)`
- (void)disable:(GLenum)capability;

/// 内部调用 `glBlendFunc(sfactor, dfactor)`
- (void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor;

@end
