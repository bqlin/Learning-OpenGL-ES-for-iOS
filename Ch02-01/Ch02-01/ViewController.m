//
//  ViewController.m
//  Ch02-01
//
//  Created by bqlin on 2018/7/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"

/// 存储每个顶点信息的数据类型
typedef struct{
	GLKVector3 positionCoords;
} SceneVertex;

/// 定义示例三角形顶点数据
static const SceneVertex vertices[] = {
	{{-.5, -.5, .0}},   // 左下角
	{{.5, -.5, .0}},    // 右下角
	{{-.5, .5, .0}}     // 左上角
};

@interface ViewController()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation ViewController
{
	GLuint _vertexBufferID;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// 确认从 storyboard 创建的 view 类型
	GLKView *view = (GLKView *)self.view;
	NSAssert([view isKindOfClass:[GLKView class]], @"view controller's is not a GLKView");
	
	// 创建提供给视图的 OpenGL ES 2.0 上下文
	view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	// 设置 OpenGL ES 当前上下文
	[EAGLContext setCurrentContext:view.context];
	
	// 创建一个基本特效，提供标准的 OpenGL ES 2.0 着色器，并设置常量以供后续渲染
	_baseEffect = [[GLKBaseEffect alloc] init];
	_baseEffect.useConstantColor = GL_TRUE;
	_baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0); // RGBA
	
	// 设置存储在当前上下文的背景颜色
	glClearColor(.0, .0, .0, 1.0);
	
	/// 1. 为缓存生成一个独一无二的标识符
	// 生成、绑定并初始化一个存储到 GPU 内存的缓存内容
	glGenBuffers(1, &_vertexBufferID);
	
	/// 2. 为接下来的运算绑定缓存
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
	
	/// 3. 赋值数据到缓存中
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	[_baseEffect prepareToDraw];
	
	// 清除帧缓存，请求之前绘制的内容
	glClear(GL_COLOR_BUFFER_BIT);
	
	/// 4. 启动
	// 启用绑定顶点缓冲区中的位置
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	
	/// 5. 设置指针
	glVertexAttribPointer(GLKVertexAttribPosition,  // 当前绑定的缓存中，包含每个顶点数据
						  3,		// 每个位置有3个部分
						  GL_FLOAT,	// 每个部分保存为浮点类型
						  GL_FALSE,	// 小数点固定数据不可变，没有使用小数点固定的数据
						  sizeof(SceneVertex),	// 步幅，每个顶点保存的字节数
						  NULL);	// 可以从当前顶点缓存的开始位置访问数据
	
	/// 6. 绘制
	glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)dealloc {
	glDeleteBuffers(1, &_vertexBufferID);
	NSLog(@"%s", __FUNCTION__);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

@end

