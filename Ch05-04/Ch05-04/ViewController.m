//
//  ViewController.m
//  Ch05-04
//
//  Created by bqlin on 2018/11/8.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "lowPolyAxesAndModels2.h"

/// 可供选择的变换类型
typedef NS_ENUM(NSInteger, SceneTransformationSelector) {
    SceneTranslate = 0,
    SceneRotate,
    SceneScale,
};

/// 可供选择的坐标轴
typedef NS_ENUM(NSInteger, SceneTransformationAxisSelector) {
    SceneXAxis = 0,
    SceneYAxis,
    SceneZAxis,
};

NS_INLINE GLKMatrix4 SceneMatrixForTransform(SceneTransformationSelector type, SceneTransformationAxisSelector axis, CGFloat value) {
    GLKMatrix4 result = GLKMatrix4Identity;
    switch (type) {
        case SceneRotate:{
            switch (axis) {
                case SceneXAxis:{
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0 * value), 1, 0, 0);
                } break;
                case SceneYAxis:{
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0 * value), 0, 1, 0);
                } break;
                case SceneZAxis:{
                    result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180.0 * value), 0, 0, 1);
                } break;
            }
        } break;
        case SceneScale:{
            switch (axis) {
                case SceneXAxis:{
                    result = GLKMatrix4MakeScale(1.0 + value, 1, 1);
                } break;
                case SceneYAxis:{
                    result = GLKMatrix4MakeScale(1, 1.0 + value, 1);
                } break;
                case SceneZAxis:{
                    result = GLKMatrix4MakeScale(1, 1, 1.0 + value);
                } break;
            }
        } break;
        case SceneTranslate:{
            switch (axis) {
                case SceneXAxis:{
                    result = GLKMatrix4MakeTranslation(.3 * value, 0, 0);
                } break;
                case SceneYAxis:{
                    result = GLKMatrix4MakeTranslation(0, .3 * value, 0);
                } break;
                case SceneZAxis:{
                    result = GLKMatrix4MakeTranslation(0, 0, .3 * value);
                } break;
            }
        } break;
    }
    return result;
}

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (weak, nonatomic) IBOutlet UISlider *transform1ValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *transform2ValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *transform3ValueSlider;

@end

@implementation ViewController
{
    SceneTransformationSelector _transform1Type;
    SceneTransformationAxisSelector _transform1Axis;
    CGFloat _transform1Value;
    
    SceneTransformationSelector _transform2Type;
    SceneTransformationAxisSelector _transform2Axis;
    CGFloat _transform2Value;
    
    SceneTransformationSelector _transform3Type;
    SceneTransformationAxisSelector _transform3Axis;
    CGFloat _transform3Value;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 确认视图类型
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    // 配置上下文
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 设置提供标准着色器的基本特效
    _baseEffect = [[GLKBaseEffect alloc] init];
    // 配置模拟阳光的灯光
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.ambientColor = GLKVector4Make(.4, .4, .4, 1);
    _baseEffect.light0.position = GLKVector4Make(1, .8, .4, .0);
    
    // 配置上下文背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // 创建顶点缓存
    _vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(lowPolyAxesAndModels2Verts) / (3 * sizeof(GLfloat)) bytes:lowPolyAxesAndModels2Verts usage:GL_STATIC_DRAW];
    _vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(lowPolyAxesAndModels2Normals) / (3 * sizeof(GLfloat)) bytes:lowPolyAxesAndModels2Normals usage:GL_STATIC_DRAW];
    
    // 开启深度测试
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
    
    // 设置观察角度
    GLKMatrix4 modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30), 1, 0, 0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, GLKMathDegreesToRadians(-30), 0, 1, 0);
    modelviewMatrix = GLKMatrix4Translate(modelviewMatrix, -.25, 0, -.2);
    _baseEffect.transform.modelviewMatrix = modelviewMatrix;
    
    // 开启并配置混合
    [(AGLKContext *)view.context enable:GL_BLEND];
    [(AGLKContext *)view.context setBlendSourceFunction:GL_SRC_ALPHA destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 拉伸坐标轴以防止变形
    const GLfloat aspectRatio = 1.0 * view.drawableWidth / view.drawableHeight;
    _baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(-.5 * aspectRatio, .5 * aspectRatio,
                                                                 -.5, .5,
                                                                 -5, 5);
    // 清除帧缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    
    // 准备绘制的顶点缓存
    [_vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [_vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    
    // 设置本地坐标，进行对应的3次级联的对各个轴的平移、旋转、缩放变换
    GLKMatrix4 savedModelviewMatrix = _baseEffect.transform.modelviewMatrix;
    GLKMatrix4 newModelviewMatrix = GLKMatrix4Multiply(savedModelviewMatrix, SceneMatrixForTransform(_transform1Type, _transform1Axis, _transform1Value));
    newModelviewMatrix = GLKMatrix4Multiply(newModelviewMatrix, SceneMatrixForTransform(_transform2Type, _transform2Axis, _transform2Value));
    newModelviewMatrix = GLKMatrix4Multiply(newModelviewMatrix, SceneMatrixForTransform(_transform3Type, _transform3Axis, _transform3Value));
    _baseEffect.transform.modelviewMatrix = newModelviewMatrix;
    
    // 绘制
    _baseEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);
    [_baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:lowPolyAxesAndModels2NumVerts];
    // 再次绘制进行混合
    _baseEffect.transform.modelviewMatrix = savedModelviewMatrix;
    _baseEffect.light0.diffuseColor = GLKVector4Make(1, 1, 0, .3);
    [_baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:lowPolyAxesAndModels2NumVerts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)resetIdentityAction:(UIButton *)sender {
    _transform1ValueSlider.value = 0;
    _transform1Value = 0;
    
    _transform2ValueSlider.value = 0;
    _transform2Value = 0;
    
    _transform3ValueSlider.value = 0;
    _transform3Value = 0;
}

- (IBAction)takeTransform1TypeFrom:(UISegmentedControl *)sender {
    _transform1Type = sender.selectedSegmentIndex;
}

- (IBAction)takeTransform2TypeFrom:(UISegmentedControl *)sender {
    _transform2Type = sender.selectedSegmentIndex;
}

- (IBAction)takeTransform3TypeFrom:(UISegmentedControl *)sender {
    _transform3Type = sender.selectedSegmentIndex;
}

- (IBAction)takeTransform1AxisFrom:(UISegmentedControl *)sender {
    _transform1Axis = sender.selectedSegmentIndex;
}

- (IBAction)takeTransform2AxisFrom:(UISegmentedControl *)sender {
    _transform2Axis = sender.selectedSegmentIndex;
}

- (IBAction)takeTransform3AxisFrom:(UISegmentedControl *)sender {
    _transform3Axis = sender.selectedSegmentIndex;
}

- (IBAction)takeTransform1ValueFrom:(UISlider *)sender {
    _transform1Value = sender.value;
}

- (IBAction)takeTransform2ValueFrom:(UISlider *)sender {
    _transform2Value = sender.value;
}

- (IBAction)takeTransform3ValueFrom:(UISlider *)sender {
    _transform3Value = sender.value;
}

@end
