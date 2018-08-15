//
//  ViewController.m
//  Ch02-03
//
//  Created by bqlin on 2018/7/31.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
    GLKVector3 positionCoords;
} SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
static const SceneVertex vertices[] =
{
    {{-.5f, -.5f, .0}},
    {{.5f, -.5f, .0}},
    {{-.5, .5f, .0}}
};

@interface ViewController ()

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

@implementation ViewController

- (void)dealloc {
    [AGLKContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Verify the type of view created automatically by the Interface Builder storyboard
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the view
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    // shading language programs and set constants to be used for
    // all subsequent rendering
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    // Set the background color stored in the current context
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0, 0, 0, 1);
    
    // Create vertex buffer containing vertices to draw
    _vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
}

/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [_baseEffect prepareToDraw];
    
    // Clear back frame buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [_vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    
    // Draw triangles using the first three vertices in the
    // currently bound vertex buffer
    [_vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
