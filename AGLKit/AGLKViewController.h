//
//  AGLKViewController.h
//  Ch02-02
//
//  Created by bqlin on 2018/11/5.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGLKView.h"

@interface AGLKViewController : UIViewController <AGLKViewDelegate>

/// 包含绘制是所需的每秒帧数，默认 30 fps
@property (nonatomic, assign) NSInteger preferredFramesPerSecond;

/// 基于 preferredFramesPerSecond 值，在 GLKView 所在的屏幕的实际帧率。该值趋近与 preferredFramesPerSecond，但不会超过屏幕刷新率。此值不考虑丢弃的帧，因此它不是统计帧的度量，它只是更新的静态值。
@property (nonatomic, assign, readonly) NSInteger framesPerSecond;

/// 暂停或恢复以给定的 preferredFramesPerSecond 绘制，默认是 NO
@property (nonatomic, assign) BOOL paused;

@end
