# Ch03-05

多重纹理替代多通道渲染。

通过设置 `GLKBaseEffect` 类的支持的两个纹理，并设置其最后一个纹理（`GLKEffectPropertyTexture`）的 `envMode` 混合模式，来实现两个纹理的混合绘制。

GPU 支持同时从至少两个纹理缓存中取样纹素。