//
//  AGLKTextureLoader.h
//  Ch03-02
//
//  Created by bqlin on 2018/8/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKTextureInfo : NSObject

@property (nonatomic, assign, readonly) GLuint name;
@property (nonatomic, assign, readonly) GLenum target;
@property (nonatomic, assign, readonly) GLuint width;
@property (nonatomic, assign, readonly) GLuint height;

@end

@interface AGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary<NSString *,NSNumber *> *)options error:(NSError **)outError;

@end
