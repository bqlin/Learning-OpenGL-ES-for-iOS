//
//  ViewController.m
//  Ch03-01
//
//  Created by bqlin on 2018/7/17.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"

/// 存储每个顶点信息的数据类型
typedef struct{
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

/// 定义示例三角形顶点数据
static const SceneVertex vertices[] = {
    {{-.5, -.5, .0}, {.0, .0}},	// 左下角
    {{.5, -.5, .0}, {1.0, .0}},	// 右下角
    {{-.5, .5, .0}, {.0, 1.0}}	// 左上角
};

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
	// 确保从 storyboard 初始化过来的 view 是 GLKView
	GLKView *view = (GLKView *)self.view;
	NSAssert([view isKindOfClass:[GLKView class]], @"view controller's view is not a GLKView");
	
	// 创建上下文并提供给 view
	view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	// 设置当前上下文
	[EAGLContext setCurrentContext:view.context];
	
	// 创建基本特效
	_baseEffect = [[GLKBaseEffect alloc] init];
	_baseEffect.useConstantColor = GL_TRUE;
	_baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
	
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
