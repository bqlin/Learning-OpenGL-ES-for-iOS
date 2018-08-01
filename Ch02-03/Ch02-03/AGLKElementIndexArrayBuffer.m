//
//  AGLKElementIndexArrayBuffer.m
//  Ch02-03
//
//  Created by bqlin on 2018/7/31.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AGLKElementIndexArrayBuffer.h"

@implementation AGLKElementIndexArrayBuffer

/////////////////////////////////////////////////////////////////
// This method creates a vertex attribute array buffer in
// the current OpenGL ES context for the thread upon which this
// method is called.
- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage {
    NSParameterAssert(0 < stride);
    NSAssert(0 < count && NULL != dataPtr || (0 == count && NULL == dataPtr), @"data must not be NULL or count > 0");
    
    if (self = [super init]) {
        _stride = stride;
        _bufferSizeBytes = _stride * count;
        
        // 1. 为存储生成一个独一无二的标识符
        glGenBuffers(1, &_name);
        
        // 2. 为接下来的运算绑定缓存
        glBindBuffer(GL_ARRAY_BUFFER, _name);
        
        // 3. 赋值数据到缓存中
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);
        
        NSAssert(0 != _name, @"Failed to generate name");
    }
    return self;
}

/////////////////////////////////////////////////////////////////
// This method loads the data stored by the receiver.
- (void)reinitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr {
    NSParameterAssert(0 < stride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    NSAssert(0 != _name, @"Invalid name");
    
    _stride = stride;
    _bufferSizeBytes = _stride * count;
    
    // 2. 为接下来的运算绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER, _name);
    
    // 3. 赋值数据到缓存中
    glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, GL_DYNAMIC_DRAW);
}

/////////////////////////////////////////////////////////////////
// A vertex attribute array buffer must be prepared when your
// application wants to use the buffer to render any geometry.
// When your application prepares an buffer, some OpenGL ES state
// is altered to allow bind the buffer and configure pointers.
- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable {
    NSParameterAssert(0 < count && count < 4);
    NSParameterAssert(offset < _stride);
    NSAssert(0 != _name, @"Invalid name");
    
    // 2. 为接下来的运算绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER, _name);
    
    // 4. 启用绑定顶点缓冲区的位置
    if (shouldEnable) glEnableVertexAttribArray(index);
    
    // 5. 设置指针
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, (GLsizei)_stride, NULL + offset);
    
#ifdef DEBUG
    // report any errrors
    GLenum error = glGetError();
    if (GL_NO_ERROR != error) {
        NSLog(@"GL Error: 0x%x", error);
    }
#endif
}

/////////////////////////////////////////////////////////////////
// Submits the drawing command identified by mode and instructs
// OpenGL ES to use count vertices from the buffer starting from
// the vertex at index first. Vertex indices start at 0.
- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count {
    NSAssert(_bufferSizeBytes >= (first + count) * _stride, @"Attempt to draw more vertex data than available.");
    
    // 6. 绘制
    glDrawArrays(mode, first, count);
}

/////////////////////////////////////////////////////////////////
// Submits the drawing command identified by mode and instructs
// OpenGL ES to use count vertices from previously prepared
// buffers starting from the vertex at index first in the
// prepared buffers
+ (void)drawPreparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count {
    // 6. 绘制
    glDrawArrays(mode, first, count);
}

/////////////////////////////////////////////////////////////////
// This method deletes the receiver's buffer from the current
// Context when the receiver is deallocated.
- (void)dealloc {
    // Delete buffer from current context
    if (0 != _name) {
        glDeleteBuffers(1, &_name);
        _name = 0;
    }
}

@end
