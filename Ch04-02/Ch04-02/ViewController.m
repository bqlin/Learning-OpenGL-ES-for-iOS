//
//  ViewController.m
//  Ch04-02
//
//  Created by bqlin on 2018/11/8.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

/// 存储顶点信息的数据类型
typedef struct {
    GLKVector3 position;
    GLKVector2 textureCoords;
} SceneVertex;

/// 存储三角形的数据类型
typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;

// 定义示例中每个顶点的位置坐标和纹理坐标
static SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 1.0}};
static SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.5}};
static SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0}};
static SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.5, 1.0}};
static SceneVertex vertexE = {{ 0.0,  0.0,  0.0}, {0.5, 0.5}};
static SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.5, 0.0}};
static SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {1.0, 1.0}};
static SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {1.0, 0.5}};
static SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {1.0, 0.0}};

/// 由给定顶点创建三角形
NS_INLINE SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC) {
    SceneTriangle result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    return result;
}

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
/// 灯光纹理
@property (nonatomic, strong) GLKTextureInfo *blandTextureInfo;
/// 材质纹理
@property (nonatomic, strong) GLKTextureInfo *interestingTextureInfo;
@property (nonatomic, assign) BOOL shouldUseDetailLighting;

@end

@implementation ViewController
{
    SceneTriangle _triangles[8];
}

- (void)dealloc {
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 确认加载的视图
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    // 创建 OpenGL ES 2.0 上下文，并提供给视图
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 创建提供标准着色器的基本特效
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // 配置观察角度
    {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30.0f), 0, 0, 1);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, .25f);
        _baseEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    // 配置纹理
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    CGImageRef blandSimulatedLightingImageRef = [UIImage imageNamed:@"Lighting256x256.png"].CGImage;
    _blandTextureInfo = [GLKTextureLoader textureWithCGImage:blandSimulatedLightingImageRef options:options error:nil];
    CGImageRef interstingSimulatedLightingImageRef = [UIImage imageNamed:@"LightingDetail256x256.png"].CGImage;
    _interestingTextureInfo = [GLKTextureLoader textureWithCGImage:interstingSimulatedLightingImageRef options:options error:nil];
    
    // 设置上下文背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建三角锥
    _triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    _triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    _triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    _triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    _triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    _triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    _triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    _triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    // 创建包含绘制的顶点的顶点缓存
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(_triangles) / sizeof(SceneVertex) bytes:_triangles usage:GL_DYNAMIC_DRAW];
    _shouldUseDetailLighting = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (_shouldUseDetailLighting) {
        _baseEffect.texture2d0.name = _interestingTextureInfo.name;
        _baseEffect.texture2d0.target = _interestingTextureInfo.target;
    } else {
        _baseEffect.texture2d0.name = _blandTextureInfo.name;
        _baseEffect.texture2d0.target = _blandTextureInfo.target;
    }
    
    [_baseEffect prepareToDraw];
    
    // 清除帧缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    // 绘制三角形
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(_triangles) / sizeof(SceneVertex)];
}

#pragma mark - action

- (IBAction)useDetailLightingSwitchAction:(UISwitch *)sender {
    _shouldUseDetailLighting = sender.on;
}


@end
