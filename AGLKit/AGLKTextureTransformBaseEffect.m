//
//  AGLKTextureTransformBaseEffect.m
//  Ch05-05
//
//  Created by bqlin on 2018/11/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AGLKTextureTransformBaseEffect.h"

/// GLSL program uniform indices.
enum {
    AGLKModelviewMatrix,
    AGLKMVPMatrix,
    AGLKNormalMatrix,
    AGLKTex0Matrix,
    AGLKTex1Matrix,
    AGLKSamplers,
    AGLKTex0Enabled,
    AGLKTex1Enabled,
    AGLKGlobalAmbient,
    AGLKLight0Pos,
    AGLKLight0Direction,
    AGLKLight0Diffuse,
    AGLKLight0Cutoff,
    AGLKLight0Exponent,
    AGLKLight1Pos,
    AGLKLight1Direction,
    AGLKLight1Diffuse,
    AGLKLight1Cutoff,
    AGLKLight1Exponent,
    AGLKLight2Pos,
    AGLKLight2Diffuse,
    AGLKNumUniforms
};

@interface AGLKTextureTransformBaseEffect ()

@property (nonatomic, assign) GLKVector3 light0EyePosition;
@property (nonatomic, assign) GLKVector3 light0EyeDirection;
@property (nonatomic, assign) GLKVector3 light1EyePosition;
@property (nonatomic, assign) GLKVector3 light1EyeDirection;
@property (nonatomic, assign) GLKVector3 light2EyePosition;

@end

@implementation AGLKTextureTransformBaseEffect
{
    GLuint _program;
    GLint _uniforms[AGLKNumUniforms];
}

- (instancetype)init {
    if (self = [super init]) {
        _textureMatrix2d0 = GLKMatrix4Identity;
        _textureMatrix2d1 = GLKMatrix4Identity;
        self.texture2d0.enabled = GL_FALSE;
        self.texture2d1.enabled = GL_FALSE;
        self.material.ambientColor = GLKVector4Make(1, 1, 1, 1);
        self.lightModelAmbientColor = GLKVector4Make(1, 1, 1, 1);
        self.light0.enabled = GL_FALSE;
        self.light1.enabled = GL_FALSE;
        self.light2.enabled = GL_FALSE;
    }
    return self;
}

- (void)prepareToDrawMultitextures {
    if (0 == _program) {
        [self loadShaders];
    }
    
    if (0 != _program) {
        glUseProgram(_program);
        
        // 本地存储纹理样本 ID
        const GLuint sampleIDs[2] = {0, 1};
        
        // 预先计算 mvpMatrix
        GLKMatrix4 modelviewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, self.transform.modelviewMatrix);
        
        // 标准矩阵
        glUniformMatrix4fv(_uniforms[AGLKModelviewMatrix], 1, 0, self.transform.modelviewMatrix.m);
        glUniformMatrix4fv(_uniforms[AGLKMVPMatrix], 1, 0, modelviewProjectionMatrix.m);
        glUniformMatrix3fv(_uniforms[AGLKNormalMatrix], 1, 0, self.transform.normalMatrix.m);
        glUniformMatrix4fv(_uniforms[AGLKTex0Matrix], 1, 0, self.textureMatrix2d0.m);
        glUniformMatrix4fv(_uniforms[AGLKTex1Matrix], 1, 0, self.textureMatrix2d1.m);
        
        // 两个纹理样本
        glUniform1iv(_uniforms[AGLKSamplers], 2, (const GLint *)sampleIDs);
        
        // Pre-calculate the global ambient light contribution using only uniform parameters rather than send all the separate uniforms to the vertex shader
        GLKVector4 globalAmbient =GLKVector4Multiply(self.lightModelAmbientColor, self.material.ambientColor);
        if (self.light0.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light0.ambientColor, self.material.ambientColor));
        }
        if (self.light1.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light1.ambientColor, self.material.ambientColor));
        }
        if (self.light2.enabled) {
            globalAmbient = GLKVector4Add(globalAmbient, GLKVector4Multiply(self.light2.ambientColor, self.material.ambientColor));
        }
        glUniform4fv(_uniforms[AGLKGlobalAmbient], 1, globalAmbient.v);
        
        // Scale factors for texture contribution
        glUniform1f(_uniforms[AGLKTex0Enabled], self.texture2d0.enabled ? 1 : 0);
        glUniform1f(_uniforms[AGLKTex1Enabled], self.texture2d1 ? 1 : 0);
        
        // 光照0
        // 材料和光照的漫反射被烘烤，因此没有理由将材质漫反射颜色发送到着色器
        if (self.light0.enabled) {
            glUniform3fv(_uniforms[AGLKLight0Pos], 1, _light0EyePosition.v);
            glUniform3fv(_uniforms[AGLKLight0Direction], 1, _light0EyeDirection.v);
            glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, GLKVector4Multiply(self.light0.diffuseColor, self.material.diffuseColor).v);
            glUniform1f(_uniforms[AGLKLight0Cutoff], GLKMathDegreesToRadians(self.light0.spotCutoff));
            glUniform1f(_uniforms[AGLKLight0Exponent], self.light0.spotExponent);
        } else {
            glUniform4fv(_uniforms[AGLKLight0Diffuse], 1, GLKVector4Make(0, 0, 0, 1).v);
        }
        
        // 光照1
        if (self.light1.enabled) {
            glUniform3fv(_uniforms[AGLKLight1Pos], 1, _light1EyePosition.v);
            glUniform3fv(_uniforms[AGLKLight1Direction], 1, _light1EyeDirection.v);
            glUniform4fv(_uniforms[AGLKLight1Diffuse], 1, GLKVector4Multiply(self.light1.diffuseColor, self.material.diffuseColor).v);
            glUniform1f(_uniforms[AGLKLight1Cutoff], GLKMathDegreesToRadians(self.light1.spotCutoff));
            glUniform1f(_uniforms[AGLKLight1Exponent], self.light1.spotExponent);
        } else {
            glUniform4fv(_uniforms[AGLKLight1Diffuse], 1, GLKVector4Make(0, 0, 0, 1).v);
        }
        
        // 光照2
        if (self.light2.enabled) {
            glUniform3fv(_uniforms[AGLKLight2Pos], 1, self.light2EyePosition.v);
            glUniform4fv(_uniforms[AGLKLight2Diffuse], 1, GLKVector4Multiply(self.light2.diffuseColor, self.material.diffuseColor).v);
        } else {
            glUniform4fv(_uniforms[AGLKLight2Diffuse], 1, GLKVector4Make(0, 0, 0, 1).v);
        }
        
        // 将纹理绑定到各自单元中
        glActiveTexture(GL_TEXTURE0);
        if (0 != self.texture2d0.name && self.texture2d0.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d0.name);
        } else {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        
        glActiveTexture(GL_TEXTURE1);
        if (0 != self.texture2d1.name && self.texture2d1.enabled) {
            glBindTexture(GL_TEXTURE_2D, self.texture2d1.name);
        } else {
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        
#ifdef DEBUG
        {  // Report any errors
            GLenum error = glGetError();
            if(GL_NO_ERROR != error)
            {
                NSLog(@"GL Error: 0x%x", error);
            }
        }
#endif
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

/// 该方法加载、编译、连接，并初始化着色器程序
- (BOOL)loadShaders {
    GLuint vertShader, fragShader;
    NSString *vertShaderPath, *fragShaderPath;
    
    // 创建着色器程序
    _program = glCreateProgram();
    
    // 创建并编译顶点着色器
    vertShaderPath = [[NSBundle mainBundle] pathForResource:@"AGLKTextureMatrix2PointLightShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER filePath:vertShaderPath]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // 创建并编译片元着色器
    fragShaderPath = [[NSBundle mainBundle] pathForResource:@"AGLKTextureMatrix2PointLightShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER filePath:fragShaderPath]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // 连接顶点着色器至程序
    glAttachShader(_program, vertShader);
    // 连接片元着色器至程序
    glAttachShader(_program, fragShader);
    
    // 绑定属性位置，需要再链接前完成
    glBindAttribLocation(_program, GLKVertexAttribPosition, "a_position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "a_normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "a_texCoord0");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord1, "a_texCoord1");
    
    // 链接程序
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // 获取统一符位置
    _uniforms[AGLKModelviewMatrix] = glGetUniformLocation(_program, "u_modelviewMatrix");
    _uniforms[AGLKMVPMatrix] = glGetUniformLocation(_program, "u_mvpMatrix");
    _uniforms[AGLKNormalMatrix] = glGetUniformLocation(_program, "u_normalMatrix");
    _uniforms[AGLKTex0Matrix] = glGetUniformLocation(_program, "u_tex0Matrix");
    _uniforms[AGLKTex1Matrix] = glGetUniformLocation(_program, "u_tex1Matrix");
    _uniforms[AGLKSamplers] = glGetUniformLocation(_program, "u_unit2d");
    _uniforms[AGLKTex0Enabled] = glGetUniformLocation(_program, "u_tex0Enabled");
    _uniforms[AGLKTex1Enabled] = glGetUniformLocation(_program, "u_tex1Enabled");
    _uniforms[AGLKGlobalAmbient] = glGetUniformLocation(_program, "u_globalAmbient");
    _uniforms[AGLKLight0Pos] = glGetUniformLocation(_program, "u_light0EyePos");
    _uniforms[AGLKLight0Direction] = glGetUniformLocation(_program, "u_light0NormalEyeDirection");
    _uniforms[AGLKLight0Diffuse] = glGetUniformLocation(_program, "u_light0Diffuse");
    _uniforms[AGLKLight0Cutoff] = glGetUniformLocation(_program, "u_light0Cutoff");
    _uniforms[AGLKLight0Exponent] = glGetUniformLocation(_program, "u_light0Exponent");
    _uniforms[AGLKLight1Pos] = glGetUniformLocation(_program, "u_light1EyePos");
    _uniforms[AGLKLight1Direction] = glGetUniformLocation(_program, "u_light1NormalEyeDirection");
    _uniforms[AGLKLight1Diffuse] = glGetUniformLocation(_program, "u_light1Diffuse");
    _uniforms[AGLKLight1Cutoff] = glGetUniformLocation(_program, "u_light1Cutoff");
    _uniforms[AGLKLight1Exponent] = glGetUniformLocation(_program, "u_light1Exponent");
    _uniforms[AGLKLight2Pos] = glGetUniformLocation(_program, "u_light2EyePos");
    _uniforms[AGLKLight2Diffuse] = glGetUniformLocation(_program, "u_light2Diffuse");
    
    // 删除顶点和片元着色器
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

/// 编译着色器，通过 shader 指针返回编译结果（shader ID）
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath {
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil].UTF8String;
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

/// 验证程序
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

#pragma mark - property

- (GLKVector4)light0Position {
    return self.light0.position;
}
- (void)setLight0Position:(GLKVector4)light0Position {
    self.light0.position = light0Position;
    
    light0Position = GLKMatrix4MultiplyVector4(self.light0.transform.modelviewMatrix, light0Position);
    _light0EyePosition = GLKVector3Make(light0Position.x, light0Position.y, light0Position.z);
}

- (GLKVector3)light0SpotDirection {
    return self.light0.spotDirection;
}
- (void)setLight0SpotDirection:(GLKVector3)light0SpotDirection {
    self.light0.spotDirection = light0SpotDirection;
    
    light0SpotDirection = GLKMatrix4MultiplyVector3(self.light0.transform.modelviewMatrix, light0SpotDirection);
    _light0EyeDirection = GLKVector3Normalize(GLKVector3Make(light0SpotDirection.x, light0SpotDirection.y, light0SpotDirection.z));
}

- (GLKVector4)light1Position {
    return self.light1.position;
}
- (void)setLight1Position:(GLKVector4)light1Position {
    self.light1.position = light1Position;
    
    light1Position = GLKMatrix4MultiplyVector4(self.light1.transform.modelviewMatrix, light1Position);
    _light1EyePosition = GLKVector3Make(light1Position.x, light1Position.y, light1Position.z);
}

- (GLKVector3)light1SpotDirection {
    return self.light1.spotDirection;
}
- (void)setLight1SpotDirection:(GLKVector3)light1SpotDirection {
    self.light1.spotDirection = light1SpotDirection;
    
    light1SpotDirection = GLKMatrix4MultiplyVector3(self.light1.transform.modelviewMatrix, light1SpotDirection);
    _light1EyeDirection = GLKVector3Normalize(GLKVector3Make(light1SpotDirection.x, light1SpotDirection.y, light1SpotDirection.z));
}

- (GLKVector4)light2Position {
    return self.light2.position;
}
- (void)setLight2Position:(GLKVector4)light2Position {
    self.light2.position = light2Position;
    
    light2Position = GLKMatrix4MultiplyVector4(self.light2.transform.modelviewMatrix, light2Position);
    _light2EyePosition = GLKVector3Make(light2Position.x, light2Position.y, light2Position.z);
}

@end


@implementation GLKEffectPropertyTexture (AGLKAdditions)

/////////////////////////////////////////////////////////////////
// This method wraps the OpenGL glTexParameteri() function
// and provides a place to implement side effects to state
// changes.
- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value {
    glBindTexture(self.target, self.name);
    glTexParameteri(self.target, parameterID, value);
}

@end
