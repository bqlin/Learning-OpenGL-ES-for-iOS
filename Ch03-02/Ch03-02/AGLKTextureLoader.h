//
//  AGLKTextureLoader.h
//  Ch03-02
//
//  Created by bqlin on 2018/8/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

/**
 对纹理缓存的封装
 */
@interface AGLKTextureInfo : NSObject

/// 纹理 ID
@property (nonatomic, assign, readonly) GLuint name;
@property (nonatomic, assign, readonly) GLenum target;
@property (nonatomic, assign, readonly) GLuint width;
@property (nonatomic, assign, readonly) GLuint height;

@end

/**
 加载 OpenGL ES 纹理数据工具类
 */
@interface AGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary<NSString *,NSNumber *> *)options error:(NSError **)outError;

@end
