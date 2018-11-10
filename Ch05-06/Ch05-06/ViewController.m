//
//  ViewController.m
//  Ch05-06
//
//  Created by bqlin on 2018/11/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "sphere.h"

static const GLfloat kSceneEarthAxialTiltDeg = 23.5;
static const GLfloat kSceneDaysPerMoonOrbit = 28;
static const GLfloat kSceneMoonRadiusFractionOfEarth = .25;
static const GLfloat kSceneMoonDistanceFromEarth = 3;

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;
@property (nonatomic, strong) GLKTextureInfo *earthTextureInfo;
@property (nonatomic, strong) GLKTextureInfo *moonTextureInfo;
@property (nonatomic, assign) GLKMatrixStackRef modelviewMatrixStack;
@property (nonatomic, assign) GLfloat earthRotationAngleDegrees;
@property (nonatomic, assign) GLfloat moonRotationAngleDegrees;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _modelviewMatrixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
    
    // 确认视图类型
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    // 配置上下文
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 配置基本特效
    _baseEffect = [[GLKBaseEffect alloc] init];
    // 配置光照
    [self configureLight];
    
    // 配置合理的初始投影矩阵
    _baseEffect.transform.projectionMatrix =
    GLKMatrix4MakeOrtho(-1.0 * 4 / 3,
                        -1.0 * 4 / 3,
                        -1, 1, 1, 120);
    // 把地球放置到观察中心点附近
    _baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0, 0, -5);
    
    // 配置上下文背景色
    ((AGLKContext *)view.context). clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建顶点缓存
    _vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    _vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    _vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    
    // 配置地球纹理
    NSError *error = nil;
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    CGImageRef earthImageRef = [UIImage imageNamed:@"Earth512x256.jpg"].CGImage;
    _earthTextureInfo = [GLKTextureLoader textureWithCGImage:earthImageRef options:options error:&error];
    [self logError:error];
    
    // 配置月球纹理
    CGImageRef moonImageRef = [UIImage imageNamed:@"Moon256x128.png"].CGImage;
    _moonTextureInfo = [GLKTextureLoader textureWithCGImage:moonImageRef options:options error:&error];
    [self logError:error];
    
    // 初始化矩阵栈
    GLKMatrixStackLoadMatrix4(_modelviewMatrixStack, _baseEffect.transform.modelviewMatrix);
    
    // 初始化轨道中月球的位置
    _moonRotationAngleDegrees = -20;
    
//    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 更新每帧以进行动画（每60帧更新一天）
    _earthRotationAngleDegrees += 360.0 / 60;
    _moonRotationAngleDegrees += 360.0 / 60 / kSceneDaysPerMoonOrbit;
    
    // 清除缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    
    [_vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    
    [self drawEarth];
    [self drawMoon];
    
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}

- (void)logError:(NSError *)error {
    NSLog(@"error: %@", error);
    error = nil;
}

/// 配置模拟阳光的光照
- (void)configureLight {
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);
    _baseEffect.light0.position = GLKVector4Make(1, 0, .8, 0);
    _baseEffect.light0.ambientColor = GLKVector4Make(.2, .2, .2, 1);
}

/// 绘制地球
- (void)drawEarth {
    _baseEffect.texture2d0.name = _earthTextureInfo.name;
    _baseEffect.texture2d0.target = _earthTextureInfo.target;
    
    GLKMatrixStackPush(_modelviewMatrixStack);
    {
        GLKMatrixStackRotate(_modelviewMatrixStack, GLKMathDegreesToRadians(kSceneEarthAxialTiltDeg),
                             1, 0, 0);
        GLKMatrixStackRotate(_modelviewMatrixStack, GLKMathDegreesToRadians(_earthRotationAngleDegrees),
                             0, 1, 0);
        
        _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_modelviewMatrixStack);
        [_baseEffect prepareToDraw];
        
        // 绘制
        [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    }
    GLKMatrixStackPop(_modelviewMatrixStack);
    
    _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_modelviewMatrixStack);
}

/// 绘制月球
- (void)drawMoon {
    _baseEffect.texture2d0.name = _moonTextureInfo.name;
    _baseEffect.texture2d0.target = _moonTextureInfo.target;
    
    GLKMatrixStackPush(_modelviewMatrixStack);
    {
        GLKMatrixStackRotate(_modelviewMatrixStack, GLKMathDegreesToRadians(_moonRotationAngleDegrees),
                             0, 1, 0); // 旋转到轨道位置
        GLKMatrixStackTranslate(_modelviewMatrixStack,
                                0, 0, kSceneMoonDistanceFromEarth);
        GLKMatrixStackScale(_modelviewMatrixStack,
                            kSceneMoonRadiusFractionOfEarth, kSceneMoonRadiusFractionOfEarth, kSceneMoonRadiusFractionOfEarth);
        GLKMatrixStackRotate(_modelviewMatrixStack, GLKMathDegreesToRadians(_moonRotationAngleDegrees),
                             0, 1, 0); // 在自己轴上旋转
        
        _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_modelviewMatrixStack);
        [_baseEffect prepareToDraw];
        
        // 绘制
        [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
    }
    GLKMatrixStackPop(_modelviewMatrixStack);
    
    _baseEffect.transform.modelviewMatrix = GLKMatrixStackGetMatrix4(_modelviewMatrixStack);
}

#pragma mark - action

- (IBAction)usePerspectiveAction:(UISwitch *)sender {
}

@end
