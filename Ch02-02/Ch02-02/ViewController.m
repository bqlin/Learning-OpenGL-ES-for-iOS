//
//  ViewController.m
//  Ch02-02
//
//  Created by bqlin on 2018/11/5.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"

// 存储每个顶点的数据类型
typedef struct {
    GLKVector3 positionCoords;
} SeceneVertex;

// 示例三角形顶点
static const SeceneVertex vertices[] = {
    {{-.5, -.5, .0}}, // 左下角
    {{.5, -.5, .0}}, // 右下角
    {{-.5, .5, .0}}, // 左上角
};

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation ViewController
{
    GLuint _vertexBufferID;
}

- (void)dealloc {
    if (0 != _vertexBufferID) {
        glDeleteBuffers(1, &_vertexBufferID);
        _vertexBufferID = 0;
    }
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 确认从 IB 加载的视图类型
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]], @"View controller's view is not a AGLKView");
    
    // 创建 OpenGL ES 2.0 上下文，并提供给视图
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    // 创建基础特效，提供标准 OpenGL ES 2.0 着色器程序
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // 设置当前上下文的背景色
    glClearColor(0, 0, 0, 1);
    
    // 生成、绑定，并初始化存储在 GPU 内存的缓存内容
    glGenBuffers(1, &_vertexBufferID); // 1️⃣
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID); // 2️⃣
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW); // 3️⃣
}

- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect {
    [self.baseEffect prepareToDraw];
    
    // 清理帧缓存
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 启用绑定顶点缓冲的位置
    glEnableVertexAttribArray(GLKVertexAttribPosition); // 4️⃣
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SeceneVertex), NULL);
    
    // 使用开始的三个绑定在顶点缓存的顶点绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
