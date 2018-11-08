//
//  ViewController.m
//  Ch05-03
//
//  Created by bqlin on 2018/11/8.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 确认加载的视图
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]], @"View controller's view is not a AGLKView");
    
    // 配置深度格式
    view.drawableDepthFormat = AGLKViewDrawableDepthFormat16;
    
    // 创建 OpenGL ES 2.0 上下文，并提供给视图
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 创建提供标准着色器的基本特效
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(.7, .7, .7, 1);
    _baseEffect.light0.ambientColor = GLKVector4Make(.2, .2, .2, 1);
    _baseEffect.light0.position = GLKVector4Make(1, 0, -.8, 0);
    
    // 配置纹理
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    CGImageRef imageRef = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:options error:nil];
    _baseEffect.texture2d0.name = textureInfo.name;
    _baseEffect.texture2d0.target = textureInfo.target;
    
    // 设置上下文背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建顶点缓存
    _vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat) numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    _vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:3 * sizeof(GLfloat) numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    _vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:2 * sizeof(GLfloat) numberOfVertices:sizeof(sphereTexCoords) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    
    // 开启深度测试
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_baseEffect prepareToDraw];
    
    // 清除缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    
    [_vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    // 根据与此示例匹配的屏幕宽高比的视图的宽高比缩放 Y 坐标
    {
        const GLfloat aspectRatio = 1.0 * view.drawableWidth / view.drawableHeight;
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1, aspectRatio, 1);
    }
    
    // 绘制
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
