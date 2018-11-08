//
//  ViewController.m
//  Ch04-01
//
//  Created by bqlin on 2018/8/20.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

/// 用于存储顶点信息的数据类型
typedef struct {
    GLKVector3 position; // 顶点
    GLKVector3 normal; // 法向量
} SceneVertex;

/// 存储三角形信息的数据类型
typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;

/// 定义示例顶点
static const SceneVertex vertexA = {{-.5, .5, -.5}, {0, 0, 1}};
static const SceneVertex vertexB = {{-.5, 0, -.5}, {0, 0, 1}};
static const SceneVertex vertexC = {{-.5, -.5, -.5}, {0, 0, 1}};
static const SceneVertex vertexD = {{0, .5, -.5}, {0, 0, 1}};
static const SceneVertex vertexE = {{0, 0, -.5}, {0, 0, 1}};
static const SceneVertex vertexF = {{0, -.5, -.5}, {0, 0, 1}};
static const SceneVertex vertexG = {{.5, .5, -.5}, {0, 0, 1}};
static const SceneVertex vertexH = {{.5, 0, -.5}, {0, 0, 1}};
static const SceneVertex vertexI = {{.5, -.5, -.5}, {0, 0, 1}};

/// 要渲染的场景由八个三角形组成。金字塔本身有四个三角形，其他四个水平三角形代表金字塔的基础
#define NUM_FACES (8)

/// 需要48个顶点来绘制所有法线向量：
/// 8个三角形 * 每个三角形3个顶点 = 24个顶点
/// 24个顶点 * 每个顶点1个法向量 * 每个法向量2个顶点 = 48个顶点
#define NUM_NORMAL_LINE_VERTS (48)

/// 所有法向量需要 50 个顶点绘制
/// 在所有法向量个数的基础上再添加2个顶点绘制光线方向
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)

/// 返回指定顶点组成的三角形
static SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC) {
    SceneTriangle result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    
    return result;
}

/// 返回顶点A和顶点B的叉积方向一致的单位向量（AB向量的叉积的单位向量）
GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA, const GLKVector3 vectorB) {
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
}

/// 返回三角形的表面法线向量
static GLKVector3 SceneTrianleFaceNormal(const SceneTriangle triangle) {
    GLKVector3 vectorA = GLKVector3Subtract(triangle.vertices[1].position, triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(triangle.vertices[2].position, triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(vectorA, vectorB);
}

/// 计算8个三角形的面法线向量，然后使用三角形的顶点的三角形面法线更新每个三角形的每个顶点的法线向量
static void SceneTriagnlesUpdateFaceNormals(SceneTriangle someTriangles[NUM_FACES]) {
    for (int i = 0; i < NUM_FACES; i++) {
        GLKVector3 faceNormal = SceneTrianleFaceNormal(someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

/// 计算8个三角形的面法线向量，然后通过平均共享顶点的每个三角形的面法线向量来更新每个顶点的法线向量
static void SceneTrianglesUpdateVertexNormals(SceneTriangle someTriangles[NUM_FACES]) {
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    
    GLKVector3 faceNormals[NUM_FACES];
    
    // 计算每个三角形的面法线
    for (int i = 0; i < NUM_FACES; i++) {
        faceNormals[i] = SceneTrianleFaceNormal(someTriangles[i]);
    }
    
    // 使用4个相邻顶点的面法线，计算每个顶点法线的平均值
    newVertexA.normal = faceNormals[0];
    newVertexB.normal =
    GLKVector3MultiplyScalar(
                             GLKVector3Add(
                                           GLKVector3Add(
                                                         GLKVector3Add(faceNormals[0], faceNormals[1]),
                                                         faceNormals[2]),
                                           faceNormals[3]),
                             0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal =
    GLKVector3MultiplyScalar(
                             GLKVector3Add(
                                           GLKVector3Add(
                                                         GLKVector3Add(faceNormals[0], faceNormals[2]),
                                                         faceNormals[4]),
                                           faceNormals[6]),
                             0.25);
    newVertexE.normal =
    GLKVector3MultiplyScalar(
                             GLKVector3Add(
                                           GLKVector3Add(
                                                         GLKVector3Add(faceNormals[2], faceNormals[3]),
                                                         faceNormals[4]),
                                           faceNormals[5]),
                             0.25);
    newVertexF.normal =
    GLKVector3MultiplyScalar(
                             GLKVector3Add(
                                           GLKVector3Add(
                                                         GLKVector3Add(faceNormals[1], faceNormals[3]),
                                                         faceNormals[5]),
                                           faceNormals[7]),
                             0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal =
    GLKVector3MultiplyScalar(
                             GLKVector3Add(
                                           GLKVector3Add(
                                                         GLKVector3Add(faceNormals[4], faceNormals[5]),
                                                         faceNormals[6]),
                                           faceNormals[7]),
                             0.25);
    newVertexI.normal = faceNormals[7];
    
    // 使用重新计算法线的顶点重新创建场景的三角形
    someTriangles[0] = SceneTriangleMake(newVertexA, newVertexB, newVertexD);
    someTriangles[1] = SceneTriangleMake(newVertexB, newVertexC, newVertexF);
    someTriangles[2] = SceneTriangleMake(newVertexD, newVertexB, newVertexE);
    someTriangles[3] = SceneTriangleMake(newVertexE, newVertexB, newVertexF);
    someTriangles[4] = SceneTriangleMake(newVertexD, newVertexE, newVertexH);
    someTriangles[5] = SceneTriangleMake(newVertexE, newVertexF, newVertexH);
    someTriangles[6] = SceneTriangleMake(newVertexG, newVertexD, newVertexH);
    someTriangles[7] = SceneTriangleMake(newVertexH, newVertexF, newVertexI);
}

/// 初始化 someNormalLineVertices 中的值，其中顶点标识8个三角形的法线向量的线和表示光线方向的线
static void SceneTriangleNormalLinesUpdate(const SceneTriangle someTriangles[NUM_FACES], GLKVector3 lightPosition, GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]) {
    int lineVetexIndex = 0;
    // 定义指示每个法向量方向的线
    for (int trianglesIndex = 0; trianglesIndex < NUM_FACES; trianglesIndex++) {
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[0].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(someTriangles[trianglesIndex].vertices[0].position,
                      GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[0].normal, .5));
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[1].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(someTriangles[trianglesIndex].vertices[1].position,
                      GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[1].normal, .5));
        someNormalLineVertices[lineVetexIndex++] = someTriangles[trianglesIndex].vertices[2].position;
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(someTriangles[trianglesIndex].vertices[2].position,
                      GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertices[2].normal, 0.5));
    }
    
    // 添加一条线以指示光线方向
    someNormalLineVertices[lineVetexIndex++] = lightPosition;
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(0, 0, -.5);
}

@interface ViewController ()
{
    SceneTriangle _triangles[NUM_FACES];
}

/// 绘制三角锥
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

/// 绘制法线
@property (nonatomic, strong) GLKBaseEffect *extraEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *extraBuffer;

@property (nonatomic, assign) GLfloat centerVertexHeight;
@property (nonatomic, assign) BOOL shouldUseFaceNormals;
@property (nonatomic, assign) BOOL shouldDrawNormals;

@end

@implementation ViewController

- (void)dealloc {
    [EAGLContext setCurrentContext:nil];
}

/// 调用使用面法线或平均顶点法线重新计算接收器三角形的法线向量
- (void)updateNormals {
    if (self.shouldUseFaceNormals) {
        // 光照步骤3
        // 使用面法向量来产生面效果
        SceneTriagnlesUpdateFaceNormals(_triangles);
    } else {
        // 光照步骤3
        // 插值法线向量以获得平滑的圆角效果
        SceneTrianglesUpdateVertexNormals(_triangles);
    }
    
    // 重新初始化包含绘制顶点的顶点缓存
    [_vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(_triangles) / sizeof(SceneVertex) bytes:_triangles];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View is not a GLKView");
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 创建一个基本特效，提供标准的 OpenGL ES 2.0 着色器，并设置常量以用于后续渲染
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(.7, .7, .7, 1); // 光照颜色
    _baseEffect.light0.position = GLKVector4Make(1, 1, .5, 0); // 前三个元素表示光源的位置或设置为一个指向无限远的光源方向；最后一个元素指示前三个元素是位置（0）还是方向
    
    // for test: 添加第二束光
    _baseEffect.light1.enabled = GL_TRUE;
    _baseEffect.light1.diffuseColor = GLKVector4Make(1, 1, .5, 1);
    _baseEffect.light1.position = GLKVector4Make(0, 1, .8, .5);
    _baseEffect.light1.specularColor = GLKVector4Make(0, 0, 1, 1); // 镜面反射颜色
    _baseEffect.light1.ambientColor = GLKVector4Make(0, 0, .2, .1); // 环境颜色
    
    _extraEffect = [[GLKBaseEffect alloc] init];
    _extraEffect.useConstantColor = GL_TRUE;
    _extraEffect.constantColor = GLKVector4Make(0, 1, 0, 1);
    
    // 注释此块，可以是场景自上而下渲染
    {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60), 1, 0, 0);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30), 0, 0, 1);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, .25);

        _baseEffect.transform.modelviewMatrix = _extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    
    // 设置存储在当前上下文的背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    _triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    _triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    _triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    _triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    _triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    _triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    _triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    _triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    
    // 创建顶点缓存
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(_triangles) / sizeof(SceneVertex) bytes:_triangles usage:GL_DYNAMIC_DRAW];
    
    // 为绘制显示法线的线条创建额外的缓冲区
    _extraBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    
    self.centerVertexHeight = 0;
    self.shouldUseFaceNormals = YES;
}

// 绘制线以表示法向量和光方向
- (void)drawNormals {
    GLKVector3 normalLineVertices[NUM_LINE_VERTS];
    
    // 根据8个三角形计算所有50个顶点
    SceneTriangleNormalLinesUpdate(_triangles, GLKVector3MakeWithArray(_baseEffect.light0.position.v), normalLineVertices);
    
    [_extraBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:NUM_LINE_VERTS bytes:normalLineVertices];
    
    [_extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    // 绘制表示法线向量和光线方向的线，请勿使用等过以显示线条颜色
    _extraEffect.useConstantColor = GL_TRUE;
    _extraEffect.constantColor = GLKVector4Make(0, 1, 0, 1); // green
    [_extraEffect prepareToDraw];
    
    [_extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:NUM_NORMAL_LINE_VERTS];
    _extraEffect.constantColor = GLKVector4Make(1, 1, 0, 1); // yellow
    [_extraEffect prepareToDraw];
    
    [_extraBuffer drawArrayWithMode:GL_LINES startVertexIndex:NUM_NORMAL_LINE_VERTS numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_baseEffect prepareToDraw];
    
    // 清理帧缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, normal) shouldEnable:YES];
    
    // 绘制三角形
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(_triangles) / sizeof(SceneVertex)];
    
    if (self.shouldDrawNormals) {
        [self drawNormals];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - property

- (void)setCenterVertexHeight:(GLfloat)centerVertexHeight {
    _centerVertexHeight = centerVertexHeight;
    
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = _centerVertexHeight;
    
    _triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    _triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    _triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    _triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    
    [self updateNormals];
}

- (void)setShouldUseFaceNormals:(BOOL)shouldUseFaceNormals {
    if (_shouldUseFaceNormals == shouldUseFaceNormals) return;
    _shouldUseFaceNormals = shouldUseFaceNormals;
    [self updateNormals];
}

#pragma mark - actions

/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals to the
// value obtained from sender
- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender {
    self.shouldUseFaceNormals = sender.on;
}

/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals to the
// value obtained from sender
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender {
    self.shouldDrawNormals = sender.on;
}

/////////////////////////////////////////////////////////////////
// This method sets the value of the center vertex height to the
// value obtained from sender
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender {
    self.centerVertexHeight = sender.value;
}

@end
