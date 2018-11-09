//
//  ViewController.m
//  Ch05-05
//
//  Created by bqlin on 2018/11/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "AGLKTextureTransformBaseEffect.h"

/// 存储顶点的数据结构
typedef struct {
    GLKVector3 position;
    GLKVector2 textureCoords;
} SceneVertex;

// 示例三角形
static const SceneVertex vertices[] = {
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

@interface ViewController ()

@property (nonatomic, strong) AGLKTextureTransformBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertxBuffer;
@property (nonatomic, assign) CGFloat textureScaleFactor;
@property (nonatomic, assign) CGFloat textureAngle;
@property (nonatomic, assign) GLKMatrixStackRef textureMatrixStack;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _textureMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    _textureScaleFactor = 1.0;
    
    // 确认视图类型
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    // 配置上下文
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 配置基本特效
    _baseEffect = [[AGLKTextureTransformBaseEffect alloc] init];
    //_baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // 配置上下文背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建顶点缓存
    _vertxBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    
    // 配置纹理
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    CGImageRef imageRef0 = [UIImage imageNamed:@"leaves_transparency.gif"].CGImage;
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:options error:nil];
    _baseEffect.texture2d0.name = textureInfo0.name;
    _baseEffect.texture2d0.target = textureInfo0.target;
    _baseEffect.texture2d0.enabled = GL_TRUE;
    
    CGImageRef imageRef1 = [UIImage imageNamed:@"beetle.png"].CGImage;
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:options error:nil];
    _baseEffect.texture2d1.name = textureInfo1.name;
    _baseEffect.texture2d1.target = textureInfo1.target;
    _baseEffect.texture2d1.enabled = GL_TRUE;
    _baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [_baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S value:GL_REPEAT];
    [_baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T value:GL_REPEAT];
    
    GLKMatrixStackLoadMatrix4(_textureMatrixStack, _baseEffect.textureMatrix2d1);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清除缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [_vertxBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    [_vertxBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    [_vertxBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    GLKMatrixStackPush(_textureMatrixStack);
    
    // 拉伸并旋转纹理
    GLKMatrixStackTranslate(_textureMatrixStack, .5, .5, 0);
    GLKMatrixStackScale(_textureMatrixStack, _textureScaleFactor, _textureScaleFactor, 1);
    GLKMatrixStackRotate(_textureMatrixStack, GLKMathDegreesToRadians(_textureAngle), 0, 0, 1);
    GLKMatrixStackTranslate(_textureMatrixStack, -.5, -.5, 0);
    
    _baseEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(_textureMatrixStack);
    
    [_baseEffect prepareToDrawMultitextures];
    //[_baseEffect prepareToDraw];
    
    // 绘制
    [_vertxBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    
    GLKMatrixStackPop(_textureMatrixStack);
    
    _baseEffect.textureMatrix2d1 = GLKMatrixStackGetMatrix4(_textureMatrixStack);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textureScaleAction:(UISlider *)sender {
    _textureScaleFactor = sender.value;
}

- (IBAction)textureRotateAction:(UISlider *)sender {
    _textureAngle = sender.value;
}


@end
