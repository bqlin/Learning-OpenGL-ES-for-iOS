# Ch03-04

混合片元颜色。

加载两个带透明部分的图片构成两个纹理，将其混合并进行绘制。

本示例使用多通道（多次？）渲染，通过多次读写像素颜色渲染缓存来创建一个最终的渲染像素。

每次更新几何图形必须被渲染一次或多次，混合函数需要从像素颜色渲染缓存中读取颜色数据以便于片元颜色混合，然后结果被写辉帧缓存。当多次纹理层叠时，多个纹理的像素颜色渲染缓存的颜色会被再次读取、混合、重写。