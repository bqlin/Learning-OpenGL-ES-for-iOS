# Ch02-02

自实现 GLKView、GLKViewController 实现与 Ch02-01 相同效果。

AGLKView 主要做了：

- 对 GL 参数的配置；
- 配置上下文；

AGLKViewController 主要做了：

- 使用 CADisplayLink 刷新界面；
- 不断调用 AGLKView 的 `-display` 方法进行重绘；