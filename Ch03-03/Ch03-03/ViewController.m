//
//  ViewController.m
//  Ch03-03
//
//  Created by bqlin on 2018/8/11.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

#pragma mark - GLKEffectPropertyTexture 扩展

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value;

@end

@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value {
    glBindTexture(self.target, self.name);
    
    glTexParameteri(self.target, parameterID, value);
}

@end

#pragma mark - 数据定义

// 用于存储每个顶点信息的数据类型
typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

// 示例三角形
static SceneVertex vertices[] =
{
    {{-.5, -.5, .0}, {.0, .0}},
    {{.5, -.5, .0}, {1, .0}},
    {{-.5, .5, .0}, {.0, 1}},
};

// 定义用于重置的顶点
static SceneVertex defaultVertices[] =
{
    {{-.5, -.5, .0}, {.0, .0}},
    {{.5, -.5, .0}, {1, .0}},
    {{-.5, .5, .0}, {.0, 1}},
};

// 为动画提供存储，以控制每个顶点在每次动画时更新移动的方向和距离
static GLKVector3 movementVectors[3] = {
    {-.02, -.01, .0},
    {.01, -.005, .0},
    {-.01, .01, .0},
};

#pragma mark -

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) BOOL shouldUseLinearFilter;
@property (nonatomic, assign) BOOL shouldRepeatTexture;
@property (nonatomic, assign) GLfloat sCoordinateOffset;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

// 更新当前 OpenGL ES 上下文纹理包装模式
- (void)updateTextureParameters {
    [_baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S value:_shouldRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE];
    [_baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_MAG_FILTER value:_shouldUseLinearFilter ? GL_LINEAR : GL_NEAREST];
}

// 更新顶点数据位置以创建弹跳动画
- (void)updateAnimatedVertexPositions {
    if (_shouldAnimate) {
        // 为三角形顶点位置设置动画
        for (int i = 0; i < 3; i++) {
            vertices[i].positionCoords.x += movementVectors[i].x;
            if (vertices[i].positionCoords.x >= 1 || vertices[i].positionCoords.x <= -1) {
                movementVectors[i].x *= -1;
            }
            
            vertices[i].positionCoords.y += movementVectors[i].y;
            if (vertices[i].positionCoords.y >= 1 || vertices[i].positionCoords.y <= -1) {
                movementVectors[i].y *= -1;
            }
            
            vertices[i].positionCoords.z += movementVectors[i].x;
            if (vertices[i].positionCoords.z >= 1 || vertices[i].positionCoords.z <= -1) {
                movementVectors[i].z *= -1;
            }
        }
    } else {
        // 把三角形顶点位置重置为默认值
        for (int i = 0; i < 3; i++) {
            vertices[i].positionCoords.x = defaultVertices[i].positionCoords.x;
            vertices[i].positionCoords.y = defaultVertices[i].positionCoords.y;
            vertices[i].positionCoords.z = defaultVertices[i].positionCoords.z;
        }
    }
    
    // 调整 S 纹理坐标，以滑动纹理并显示其 repeat 模式和 clamp 模式的效果
    for (int i = 0; i < 3; i++) {
        vertices[i].textureCoords.s = defaultVertices[i].textureCoords.s + _sCoordinateOffset;
    }
}

// 以 `preferredFramesPerSecond` 属性定义的速率自动调用
- (void)update {
    [self updateAnimatedVertexPositions];
    [self updateTextureParameters];

    [_vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices];
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.preferredFramesPerSecond = 60;
    _shouldAnimate = YES;
    _shouldRepeatTexture = YES;
    
    // 确认 view 类型
    GLKView *view  = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"Veiw is not a GLKView");
    
    // 创建 OpenGL ES 2.0 上下文，并提供给 view，并设置为当前上下文
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    // 创建基本效果，提供标准 OpenGL ES 着色语言程序，并设置常量以后后续渲染
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // 创建包含绘制顶点的顶点缓存
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_DYNAMIC_DRAW];
    
    // 配置纹理
    CGImageRef imageRef = [UIImage imageNamed:@"grid.png"].CGImage;
    
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
    
    // 绘制三角形
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)takeSCoordinateOffsetFrom:(UISlider *)sender {
    self.sCoordinateOffset = sender.value;
}

- (IBAction)takeShouldRepeatTextureFrom:(UISwitch *)sender {
    self.shouldRepeatTexture = sender.on;
}

- (IBAction)takeShouldAnimateFrom:(UISwitch *)sender {
    self.shouldAnimate = sender.on;
}

- (IBAction)takeShouldUseLinearFilterFrom:(UISwitch *)sender {
    self.shouldUseLinearFilter = sender.on;
}

@end
