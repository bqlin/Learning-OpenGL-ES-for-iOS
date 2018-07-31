//
//  AGLKElementIndexArrayBuffer.h
//  Ch02-03
//
//  Created by bqlin on 2018/7/31.
//  Copyright © 2018年 Bq. All rights reserved.
//
// 封装了顶点缓存的 7 个步骤

#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, AGLKVertexAttrib) {
    AGLKVertexAttribPosition = GLKVertexAttribPosition,
    AGLKVertexAttribNormal = GLKVertexAttribNormal,
    AGLKVertexAttribColor = GLKVertexAttribColor,
    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0;
    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1;
};

@interface AGLKElementIndexArrayBuffer : NSObject

@property (nonatomic, assign, readonly) GLuint name;
@property (nonatomic, assign, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, assign, readonly) GLsizeiptr stride;

+ (void)drawPreparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count  bytes:(const GLvoid *)dataPtr;

@end
