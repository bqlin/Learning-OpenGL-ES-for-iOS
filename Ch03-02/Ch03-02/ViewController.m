//
//  ViewController.m
//  Ch03-02
//
//  Created by bqlin on 2018/8/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "AGLKTextureLoader.h"

/// 用于存储每个顶点的数据类型
typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

// 定义示例三角形顶点数据
static const SceneVertex vertices[] = {
    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}}, // lower right corner
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}, // upper left corner
};

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"Controller's view is not a GLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 创建基本效果，提供标准 OpenGL ES 2.0 shading 编程语言，并设置常量以供后续渲染
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // 设置存储在当前上下文的背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建包含绘制顶点的缓存
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    
    // 配置纹理
    CGImageRef imageReg = [UIImage imageNamed:@"leaves.gif"].CGImage;
    AGLKTextureInfo *texureInfo = [AGLKTextureLoader textureWithCGImage:imageReg options:nil error:NULL];
    
    _baseEffect.texture2d0.name = texureInfo.name;
    _baseEffect.texture2d0.target = texureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_baseEffect prepareToDraw];
    
    // 清理帧缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    // 绘制三角形
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
