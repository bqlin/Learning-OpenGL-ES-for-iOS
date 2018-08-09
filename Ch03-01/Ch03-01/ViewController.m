//
//  ViewController.m
//  Ch03-01
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

/// 存储每个顶点信息的数据类型
typedef struct{
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

/// 定义示例三角形顶点数据
static const SceneVertex vertices[] = {
    {{-.5, -.5, .0}, {.0, .0}},	// 左下角
    {{.5, -.5, .0}, {1.0, .0}},	// 右下角
    {{-.5, .5, .0}, {.0, 1.0}}	// 左上角
};

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation ViewController

- (void)dealloc {
	NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
	// 确保从 storyboard 初始化过来的 view 是 GLKView
	GLKView *view = (GLKView *)self.view;
	NSAssert([view isKindOfClass:[GLKView class]], @"view controller's view is not a GLKView");
	
	// 创建上下文并提供给 view
	AGLKContext *glContext = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	view.context = glContext;
	
	// 设置当前上下文
	[EAGLContext setCurrentContext:view.context];
	
	// 创建基本特效
	_baseEffect = [[GLKBaseEffect alloc] init];
	_baseEffect.useConstantColor = GL_TRUE;
	_baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
	
	// 设置存储在当前上下文的背景色
	glContext.clearColor = GLKVector4Make(0, 0, 0, 1);
	
	// 创建包含需要绘制的顶点缓存
	_vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(sizeof(SceneVertex)) bytes:vertices usage:GL_STATIC_DRAW];
	
	// 配置纹理
	CGImageRef imageRef = [UIImage imageNamed:@"leaves.gif"].CGImage;
	
	GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
	
	_baseEffect.texture2d0.name = textureInfo.name;
	_baseEffect.texture2d0.target = textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	[_baseEffect prepareToDraw];
	
	// 清除帧缓存
	[(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
	
	[_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
	[_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
	
	// 使用在当前顶点缓存绑定3个顶点，绘制三角形
	[_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
