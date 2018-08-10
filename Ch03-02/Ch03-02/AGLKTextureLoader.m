//
//  AGLKTextureLoader.m
//  Ch03-02
//
//  Created by bqlin on 2018/8/9.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AGLKTextureLoader.h"

// 该函数计算并返回最接近 2 的幂值，其结果 ≥ dimension && ≤ 1024
NS_INLINE size_t AGLKCalculatePowerOf2ForDinmension(size_t dimension) {
    int position = 0;
    while (dimension > 1) {
        dimension >>= 1;
        position++;
    }
    return 1 << (position + 1);
}

// 该函数返回 NSData 对象，包含了从给定的 Core Graphics 图像，CGImage 加载的字节数据。共函数同样返回（通过引用）2 的幂的宽高，用于从返回的 NSData 对象的字节数据初始化 OpenGL ES 纹理缓存。该 widthPtr 和 heightPtr 参数必须通过指针传递。
NS_INLINE NSData *AGLKDataWithResizedCGImageBytes(CGImageRef cgImage, size_t *widthPtr, size_t *heightPtr) {
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetWidth(cgImage);
    
    NSCAssert(originalWidth > 0, @"Invalid image width");
    NSCAssert(originalHeight > 0, @"Invalid image height");
    
    // 计算纹理缓存宽高，新纹理缓存将是 2 的幂
    size_t width = AGLKCalculatePowerOf2ForDinmension(originalWidth);
    size_t height = AGLKCalculatePowerOf2ForDinmension(originalHeight);
    
    // 为指定 2 的幂尺寸的 RGBA 像素样色数据分配足够的存储空间，每个 RGBA 像素 4 字节
    NSMutableData *imageData = [NSMutableData dataWithLength:height * width * 4];
    
    NSCAssert(imageData != nil, @"Unable to allocate image storage");
    
    // 创建 Core Graphics 上下文，用于绘制分配的字节数据
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(imageData.mutableBytes, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    // 翻转 Core Graphics Y 轴
    CGContextTranslateCTM(cgContext, 0, height);
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    
    // 绘制加载的图片到 Core Graphics 上下文，按需调整大小
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(cgContext);
    
    *widthPtr = width;
    *heightPtr = height;
    return imageData;
}

@interface AGLKTextureInfo()

- (instancetype)initWithName:(GLuint)name target:(size_t)target width:(size_t)width height:(size_t)height;

@end

@implementation AGLKTextureInfo

- (instancetype)initWithName:(GLuint)name target:(size_t)target width:(size_t)width height:(size_t)height {
    if (self = [super init]) {
        _name = name;
        _target = (GLuint)target;
        _width = (GLuint)width;
        _height = (GLuint)height;
    }
    return self;
}

@end

@implementation AGLKTextureLoader

// 该方法生成新的 OpenGL ES 纹理缓存，并且使用给定的 Core Graphics 图像，CGImage 的像素信息，初始化缓存内容。该方法返回一个不可变的 AGLKTextureInfo 实例，共实例通过新生成的纹理缓存初始化。生成的纹理缓存拥有 2 的幂大小。给定的图像数据会被通过 Core Graphics 拉伸（重采样），以适配生成的纹理缓存。
+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary<NSString *,NSNumber *> *)options error:(NSError *__autoreleasing *)outError {
    // 当拷贝数据到纹理缓存时获取字节数据
    size_t width, height;
    NSData *imageData = AGLKDataWithResizedCGImageBytes(cgImage, &width, &height);
    
    // 生成、绑定，并拷贝数据到新的纹理缓存中
    GLuint textureBufferID;
    
    // 1. 为缓存生成一个唯一标识符
    glGenTextures(1, &textureBufferID);
    // 2. 绑定缓存
    glBindBuffer(GL_TEXTURE_2D, textureBufferID);
    // 3. 复制数据到缓存中
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData.bytes);
    
    // 设置纹理采样参数
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // 初始化用于返回的 AGLKTextureInfo 对象
    AGLKTextureInfo *result = [[AGLKTextureInfo alloc] initWithName:textureBufferID target:GL_TEXTURE_2D width:width height:height];
    return result;
}

@end
