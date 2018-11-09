//
//  AGLKTextureTransformBaseEffect.h
//  Ch05-05
//
//  Created by bqlin on 2018/11/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

/**
 该类扩展了 GLBaseEffect，以便为每个纹理使用单独的纹理矩阵。
 使用带有 `_textureMatrix0` 和 `_textureMatrix1` 的多纹理时，使用 `-prepareToDrawWithTextures`。
 使用 `-prepareToDraw` 从 GLKBaseEffect 获取继承的行为。
 */
@interface AGLKTextureTransformBaseEffect : GLKBaseEffect

@property (nonatomic, assign) GLKVector4 light0Position;
@property (nonatomic, assign) GLKVector3 light0SpotDirection;

@property (nonatomic, assign) GLKVector4 light1Position;
@property (nonatomic, assign) GLKVector3 light1SpotDirection;

@property (nonatomic, assign) GLKVector4 light2Position;

@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;

/**
 该方法是 GLKBaseEffect 的 `-prepareToDraw` 的替代方法。内部调用了 `-prepareToDraw` 以使用继承的着色语言程序和功能。使用此方法可以从此类提供的纹理矩阵添加，以及没像素光计算中受益。
 注意：速腾哦此方法进行的照明的实现可能不同于继承的实现。例如，使用此方法，light2 必须是方向性的，并且忽略灯光的镜面反射分量。
 */
- (void)prepareToDrawMultitextures;

@end


@interface GLKEffectPropertyTexture (AGLKAdditions)

- (void)aglkSetParameter:(GLenum)parameterID value:(GLint)value;

@end
