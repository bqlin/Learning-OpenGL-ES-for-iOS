//
//  ViewController.m
//  Ch03-06
//
//  Created by bqlin on 2018/8/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

/// GLSL 程序统一索引
enum {
    UNIFORM_MODELIVEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE0_SAMPLER2D,
    UNIFORM_TEXTURE1_SAMPLER2D,
    NUM_UNIFORMS
};

/// GLSL 程序统一 ID
GLint uniforms[NUM_UNIFORMS];

/// 存储每个顶点信息的数据类型
typedef struct {
    GLKVector3 positionCoords;
    GLKVector3 normalCoords;
    GLKVector2 textureCoords;
} SceneVertex;

// 示例三角形顶点数据
static const SceneVertex vertices[] = {
    {{.5, -.5, -.5}, {1, 0, 0}, {0, 0}},
    {{.5, .5, -.5}, {1, 0, 0}, {1, 0}},
    {{.5, -.5, .5}, {1, 0, 0}, {0, 1}},
    
    {{.5, -.5, .5}, {1, 0, 0}, {0, 1}},
    {{.5, .5, .5}, {1, 0, 0}, {1, 1}},
    {{.5, .5, -.5}, {1, 0, 0}, {1, 0}},
    
    
    {{.5, .5, -.5}, {0, 1, 0}, {1, 0}},
    {{-.5, .5, -.5}, {0, 1, 0}, {0, 0}},
    {{.5, .5, .5}, {0, 1, 0}, {1, 1}},
    
    {{.5, .5, .5}, {0, 1, 0}, {1, 1}},
    {{-.5, .5, -.5}, {0, 1, 0}, {0, 0}},
    {{-.5, .5, .5}, {0, 1, 0}, {0, 1}},
    
    
    {{-.5, .5, -.5}, {-1, 0, 0}, {1, 0}},
    {{-.5, -.5, -.5}, {-1, 0, 0}, {0, 0}},
    {{-.5, .5, .5}, {-1, 0, 0}, {1, 1}},
    
    {{-.5, .5, .5}, {-1, 0, 0}, {1, 1}},
    {{-.5, -.5, -.5}, {-1, 0, 0}, {0, 0}},
    {{-.5, -.5, .5}, {-1, 0, 0}, {0, 1}},
    
    
    {{-.5, -.5, -.5}, {0, -1, 0}, {0, 0}},
    {{.5, -.5, -.5}, {0, -1, 0}, {1, 0}},
    {{-.5, -.5, .5}, {0, -1, 0}, {0, 1}},
    
    {{-.5, -.5, .5}, {0, -1, 0}, {0, 1}},
    {{.5, -.5, -.5}, {0, -1, 0}, {1, 0}},
    {{.5, -.5, .5}, {0, -1, 0}, {1, 1}},
    
    
    {{.5, .5, .5}, {0, 0, 1}, {1, 1}},
    {{-.5, .5, .5}, {0, 0, 1}, {0, 1}},
    {{.5, -.5, .5}, {0, 0, 1}, {1, 0}},
    
    {{.5, -.5, .5}, {0, 0, 1}, {1, 0}},
    {{-.5, .5, .5}, {0, 0, 1}, {0, 1}},
    {{-.5, -.5, .5}, {0, 0, 1}, {0, 0}},
    
    
    {{.5, -.5, -.5}, {0, 0, -1}, {4, 0}},
    {{-.5, -.5, -.5}, {0, 0, -1}, {0, 0}},
    {{.5, .5, -.5}, {0, 0, -1}, {4, 4}},
    
    {{.5, .5, -.5}, {0, 0, -1}, {4, 4}},
    {{-.5, -.5, -.5}, {0, 0, -1}, {0, 0}},
    {{-.5, .5, -.5}, {0, 0, -1}, {0, 4}},
};

@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value;

@end

@implementation GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value {
    glBindTexture(self.target, self.name);
    
    glTexParameteri(self.target, parameterID, value);
}

@end

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation ViewController
{
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    GLfloat _rotation;
    
    GLuint _vertexArray;
//    GLuint _vertexBuffer;
    GLuint _texture0ID;
    GLuint _texture1ID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 确认 view 类型
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View is not a GLKView");
    
    // 创建 OpenGL ES 2.0 上下文，并赋值给 view
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [AGLKContext setCurrentContext:view.context];
    
    [self loadShaders];
    
    // 创建基本特效，提供标准 OpenGL ES 2.0 着色语言程序，并设置常量以供后续渲染使用
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.light0.enabled = GL_TRUE;
    _baseEffect.light0.diffuseColor = GLKVector4Make(.7, .7, .7, 1);
    
    glEnable(GL_DEPTH_TEST);
    
    // 配置存储在当前上下文的背景色
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(.65, .65, .65, 1);
    
    // 创建包含绘制的顶点的顶点缓存
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    
    NSDictionary *options = nil;
    
    // 配置纹理0
    CGImageRef imageRef0 = [UIImage imageNamed:@"leaves_transparency.gif"].CGImage;
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:options error:nil];
    _baseEffect.texture2d0.name = textureInfo0.name;
    _baseEffect.texture2d0.target = textureInfo0.target;
    [_baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_S value:GL_REPEAT];
    [_baseEffect.texture2d0 aglkSetParameter:GL_TEXTURE_WRAP_T value:GL_REPEAT];
    
    // 配置纹理1
    CGImageRef imageRef1 = [UIImage imageNamed:@"beetle.png"].CGImage;
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:options error:nil];
    _baseEffect.texture2d1.name = textureInfo1.name;
    _baseEffect.texture2d1.target = textureInfo1.target;
    _baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [_baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_S value:GL_REPEAT];
    [_baseEffect.texture2d1 aglkSetParameter:GL_TEXTURE_WRAP_T value:GL_REPEAT];
}

// 自动调用
- (void)update {
    float aspect = fabs(CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds));
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, .1, 100);
    
    _baseEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -4);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0, 1, 0);
    
    // 计算 GLKit 渲染的对象的模型视图矩阵
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1.5);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1, 1, 1);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _baseEffect.transform.modelviewMatrix = modelViewMatrix;
    
    // 计算使用 ES2 渲染的对象的模型矩形矩阵
    modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, 1.5);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1, 1, 1);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, NULL));
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * .5;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清除帧缓存
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT];
    
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, normalCoords) shouldEnable:YES];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord1 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    [_baseEffect prepareToDraw];
    
    // 使用 baseEffect 绘制三角形
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    
    // 使用 ES2 再次渲染对象
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELIVEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_TEXTURE0_SAMPLER2D], 0);
    glUniform1i(uniforms[UNIFORM_TEXTURE1_SAMPLER2D], 1);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    if (_program) glDeleteProgram(_program);
    [EAGLContext setCurrentContext:nil];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders {
    GLuint vertShader, fragShader;
    NSString *vertShaderPath, *fragShaderPath;
    
    // 创建着色器程序
    _program = glCreateProgram();
    
    // 创建并编译顶点着色器
    vertShaderPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER path:vertShaderPath]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // 创建并编译片元着色器
    fragShaderPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER path:fragShaderPath]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // 把顶点着色器连接到程序
    glAttachShader(_program, vertShader);
    
    // 把片元这色漆连接到程序
    glAttachShader(_program, fragShader);
    
    /// 绑定属性位置
    // 在链接前完成：
    glBindAttribLocation(_program, GLKVertexAttribPosition, "aPosition");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "aNormal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "aTextureCoord0");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord1, "aTextureCoord1");
    
    // 连接程序
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
        }
        if (fragShader) {
            glDeleteShader(fragShader);
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return NO;
    }
    
    // 获取统一位置
    uniforms[UNIFORM_MODELIVEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "uModelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "uNormalMatrix");
    uniforms[UNIFORM_TEXTURE0_SAMPLER2D] = glGetUniformLocation(_program, "uSampler0");
    uniforms[UNIFORM_TEXTURE1_SAMPLER2D] = glGetUniformLocation(_program, "uSampler1");
    
    // 释放顶点和片元着色器
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type path:(NSString *)path {
    GLint status;
    const GLchar *source = (GLchar *)[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil].UTF8String;
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)program {
    GLint status;
    glLinkProgram(program);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)program {
    GLint logLength, status;
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
