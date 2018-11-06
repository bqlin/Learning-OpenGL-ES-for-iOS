//
//  AGLKView.m
//  Ch02-02
//
//  Created by bqlin on 2018/11/5.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AGLKView.h"

@implementation AGLKView
{
    GLuint _defaultFrameBuffer;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        self.context = context;
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.drawableProperties =
    @{
      kEAGLDrawablePropertyRetainedBacking: @(NO),
      kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
      };
}

- (void)drawRect:(CGRect)rect {
    if ([self.delegate respondsToSelector:@selector(glkView:drawInRect:)]) {
        [self.delegate glkView:self drawInRect:self.bounds];
    }
}

- (void)layoutSubviews {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    // 确保上下文是当前的
    [EAGLContext setCurrentContext:_context];
    
    // 初始化当前帧缓冲区的像素颜色缓冲区，以便它共享相应的核心动画层的像素颜色存储
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    if (0 != _depthRenderBuffer) {
        glDeleteRenderbuffers(1, &_depthRenderBuffer); // 7️⃣
        _depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth = (GLint)self.drawableWidth;
    GLint currentDrawableHeight = (GLint)self.drawableHeight;
    
    if (self.drawableDepthFormat != AGLKViewDrawableDepthFormatNone && 0 < currentDrawableWidth && 0 < currentDrawableHeight) {
        glGenRenderbuffers(1, &_depthRenderBuffer); // 1️⃣
        glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer); // 2️⃣
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, currentDrawableWidth, currentDrawableHeight); // 3️⃣
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer); // 4️⃣
    }
    
    // 检查配置缓存中的错误
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete frame buffer object %x", status);
    }
    
    // 让颜色渲染缓冲为当前缓冲以显示出来
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
}

// MARK: - property

- (void)setContext:(EAGLContext *)context {
    if (context == _context) return;
    
    // 删除在旧上下文创建的缓存
    [EAGLContext setCurrentContext:context];
    
    if (0 != _defaultFrameBuffer) {
        glDeleteFramebuffers(1, &_defaultFrameBuffer); // 7️⃣
        _defaultFrameBuffer = 0;
    }
    if (0 != _colorRenderBuffer) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer); // 7️⃣
        _colorRenderBuffer = 0;
    }
    if (0 != _depthRenderBuffer) {
        glDeleteRenderbuffers(1, &_depthRenderBuffer); // 7️⃣
        _depthRenderBuffer = 0;
    }
    
    _context = context;
    
    if (_context) {
        // 通过必需的缓存配置新上下文
        [EAGLContext setCurrentContext:_context];
        
        glGenFramebuffers(1, &_defaultFrameBuffer); // 1️⃣
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer); // 2️⃣
        
        glGenRenderbuffers(1, &_colorRenderBuffer); // 1️⃣
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer); // 2️⃣
        
        // 绑定颜色渲染缓存对帧缓存
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
        
        //根据 defaultFrameBuffer 的可绘制大小创建其他渲染缓冲
        [self setNeedsLayout];
    }
}

- (NSInteger)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return (NSInteger)backingWidth;
}

- (NSInteger)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return (NSInteger)backingHeight;
}

// MARK: - public

- (void)display {
    [EAGLContext setCurrentContext:_context];
    glViewport(0, 0, (GLsizei)self.drawableWidth, (GLsizei)self.drawableHeight);
    
    [self drawRect:self.bounds];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
