//
//  AGLKViewController.m
//  Ch02-02
//
//  Created by bqlin on 2018/11/5.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AGLKViewController.h"

static const NSInteger kAGLKDefaultFramePerSecond = 30;

@interface AGLKViewController ()

@end

@implementation AGLKViewController
{
    CADisplayLink *_displayLink;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit];
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
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
    self.preferredFramesPerSecond = kAGLKDefaultFramePerSecond;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.paused = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 确认从 IB 加载过来的视图
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]], @"View controller's view is not a AGLKView");
    
    view.opaque = YES;
    view.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.paused = NO;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.paused = YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return [super supportedInterfaceOrientations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: -

- (void)drawView:(id)sender {
    // 重绘
    [(AGLKView *)self.view display];
}

- (NSInteger)framesPerSecond {
    if (@available(iOS 10.0, *)) {
        return _displayLink.preferredFramesPerSecond;
    } else {
        return _preferredFramesPerSecond;
    }
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    _preferredFramesPerSecond = preferredFramesPerSecond;
    if (@available(iOS 10.0, *)) {
        _displayLink.preferredFramesPerSecond = preferredFramesPerSecond;
    } else {
        _displayLink.frameInterval = MAX(1, (60 / preferredFramesPerSecond));
    }
}

- (BOOL)paused {
    return _displayLink.paused;
}
- (void)setPaused:(BOOL)paused {
    _displayLink.paused = paused;
}

- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect {}

@end
