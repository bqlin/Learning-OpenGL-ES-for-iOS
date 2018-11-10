# Ch05-05

实现投影矩阵

使用着色器以及 GLKBaseEffect 子类 AGLKTextureTransformBaseEffect 实现了 OpenGL ES 1.x 中的纹理矩阵功能。

**注意：**着色器中不会进行自动类型转换，因此一个整型的字面量是不能赋值给一个浮点型的变量。