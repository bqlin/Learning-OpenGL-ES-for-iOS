//
//  ViewController.m
//  Ch03-04
//
//  Created by bqlin on 2018/8/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

/// 存储顶点的数据类型
typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

/// 示例矩形（使用两个三角形组成）
static const SceneVertex vertices[] = {
    {{-1, -.67, .0}, {.0, .0}}, // 第一个三角形
    {{1, -.67, 0}, {1, 0}},
    {{-1, .67, 0}, {0, 1}},
    {{1, -.67, 0}, {1, 0}}, // 第二个三角形
    {{-1, .67, 0}, {0, 1}},
    {{1, .67, 0}, {1, 1}},
};

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, strong) GLKTextureInfo *textureInfo0;
@property (nonatomic, strong) GLKTextureInfo *textureInfo1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 确认加载的 view
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View is not a GLKView");
    
    // 创建 OpenGL ES 2.0 上下文，并提供给视图
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 创建基本效果，提供标准的 OpenGL ES 2.0 着色程序，并设置常量以供后续使用
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // 配置当前上下文的背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建包含用于绘制的顶点缓存
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    
    // 配置纹理0
    CGImageRef imageRef0 = [UIImage imageNamed:@"leaves_transparency.gif"].CGImage;
    _textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:options error:nil];
    
    // 配置纹理1
    CGImageRef imageRef1 = [UIImage imageNamed:@"beetle.png"].CGImage;
    _textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:options error:nil];
    
    // 启用片元与帧缓冲内容混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清除帧缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    // 为着色器提供顶点位置
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    // 为着色器提供一组纹理坐标
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    // 设定纹理1
    _baseEffect.texture2d0.name = _textureInfo0.name;
    _baseEffect.texture2d0.target = _textureInfo0.target;
    [_baseEffect prepareToDraw];
    
    // 绘制当前绑定的顶点缓存中的三角形
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    
    // 设定纹理2
    _baseEffect.texture2d0.name = _textureInfo1.name;
    _baseEffect.texture2d0.target = _textureInfo1.target;
    [_baseEffect prepareToDraw];
    
    // 再绘制一遍
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [EAGLContext setCurrentContext:nil];
    NSLog(@"%s", __FUNCTION__);
}

@end
