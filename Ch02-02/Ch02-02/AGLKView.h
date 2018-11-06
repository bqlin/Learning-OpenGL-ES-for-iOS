//
//  AGLKView.h
//  Ch02-02
//
//  Created by bqlin on 2018/11/5.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;
@class AGLKView;

@protocol AGLKViewDelegate <NSObject>

@optional
- (void)glkView:(AGLKView *)glkView drawInRect:(CGRect)rect;

@end

// 深度缓存格式
typedef NS_ENUM(NSInteger, AGLKViewDrawableDepthFormat) {
    AGLKViewDrawableDepthFormatNone = 0,
    AGLKViewDrawableDepthFormat16,
};

@interface AGLKView : UIView

@property (nonatomic, weak) id<AGLKViewDelegate> delegate;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign, readonly) NSInteger drawableWidth;
@property (nonatomic, assign, readonly) NSInteger drawableHeight;
@property (nonatomic, assign) AGLKViewDrawableDepthFormat drawableDepthFormat;

/// 调用该方法来重绘 OpenGL ES 帧缓存，配置 GL 并进行回调。
- (void)display;

@end
