//
//  AGLKVertexAttribArrayBuffer.h
//  Ch02-03
//
//  Created by bqlin on 2018/7/31.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, AGLKVertexAttrib) {
    AGLKVertexAttribPosition = GLKVertexAttribPosition,
    AGLKVertexAttribNormal = GLKVertexAttribNormal,
    AGLKVertexAttribColor = GLKVertexAttribColor,
    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
};

/**
 封装了顶点缓存的 7 个步骤
 */
@interface AGLKVertexAttribArrayBuffer : NSObject

/// 缓存标识符
@property (nonatomic, assign, readonly) GLuint name;

/// 缓存字节数
@property (nonatomic, assign, readonly) GLsizeiptr bufferSizeBytes;

/// 步幅
@property (nonatomic, assign, readonly) GLsizeiptr stride;

/**
 绘制
 内部调用 `glDrawArrays(mode, first, count)`
 
 @param mode 处理模式
 @param first 缓存中第一顶点的位置
 @param count 顶点数量
 */
+ (void)drawPreparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

/**
 初始化

 @param stride 步幅
 @param count 顶点数量
 @param dataPtr 顶点数组指针
 @param usage 用途
 @return AGLKVertexAttribArrayBuffer 实例
 */
- (instancetype)initWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count bytes:(const GLvoid *)dataPtr usage:(GLenum)usage;

/**
 重新加载存储在接收者的数据
 用途使用 `GL_DYNAMIC_DRAW`

 @param stride 步幅
 @param count 顶点数量
 @param dataPtr 顶点数组指针
 */
- (void)reinitWithAttribStride:(GLsizeiptr)stride numberOfVertices:(GLsizei)count  bytes:(const GLvoid *)dataPtr;

/**
 准备顶点数组到缓冲区

 @param index 准备的顶点索引
 @param count 顶点总数
 @param offset 位移
 @param shouldEnable 是否启用
 */
- (void)prepareToDrawWithAttrib:(GLuint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizeiptr)offset shouldEnable:(BOOL)shouldEnable;

/**
 绘制
 内部调用 `glDrawArrays(mode, first, count)`
 
 @param mode 处理模式
 @param first 缓存中第一顶点的位置
 @param count 顶点数量
 */
- (void)drawArrayWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;



@end
