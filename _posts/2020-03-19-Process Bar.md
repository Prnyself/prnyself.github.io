---
layout:     post
title:      进度条工具安利--vbauerster/mpb
subtitle:   使用体验最好的第三方 pkg，你值得拥有
date:       2020-03-19
author:     Lance
header-img: img/post-bg-mac-in-shadow.jpg
catalog: true
tags:
    - 工具集安利
---


## 写在最前

我们的 [qsctl](https://github.com/qingstor/qsctl) v2.0 正式版终于进入尾声了，为了用户更好的使用体验，需要加一个进度条，来告知用户现在的任务进度如何，免得让用户陷入面对黑色(没有歧视其他颜色的意思)命令行背景的无尽等待中。。。

## 调研工具

秉持着不要重复造轮子的精神，我去 google 了有哪些推荐的进度条工具，发现用的最多的是这一款: [cheggaaa/pb](https://github.com/cheggaaa/pb)，已经更新到 v3 版本了，同时 v1 也在同步支持。大概看了一下，支持常用的进度条功能，比如: 设置进度条刷新速率，可以代理 `io.Reader io.Writer` 来同步 io 进度，以及修改进度条样式等等。由于 `qsctl` 中大部分是多任务异步处理，所以需要使用到多进度条的功能，这个功能只有在 v1 版本中有，并且在文档中标明 (experimental and unstable)，是实验性的功能，暂不稳定。

## 试用 pb

先下载下来试用一下吧，看了下源码，本质上 pb 对 multiple bar 的支持还是使用的 `sync.WaitGroup` 来实现，在实际使用过程中感觉包中的 pool 并不能很好的控制进度条的动态加入队列和完成后的出队列操作。而我们的任务是很大概率有后启动的任务加入进度条显示的，所以感觉并不能满足需求，无奈 pass。

## 继续找寻

修改搜索关键字，利用 multiple process bar 搜索，又发现了一个库: [vbauerster/mpb](https://github.com/vbauerster/mpb)，看 Readme 的时候给我眼前一亮的感觉，就是作者利用 svg 直接在 Readme 中实现了进度条的动态效果，任君挑选。再看看，作者标明了该工具支持多进度条(这不废话么，名字都叫 mpb)，动态设置 total 值，动态添加和移除进度条，以及集成了多种指标样式，包括剩余时间推算等等。看起来不错，走起！

## 使用 mpb

跟刚才的 `pb` 一样，`mpb` 的多进度条本质上也是使用 `sync.WaitGroup` 实现，不过作者对 wg 封装了一层，在创建多进度条的时候需要将 wg 的实例作为参数传入，在进度条完成时触发 `wg.Done()` 操作，不用用户端自己去管理 wg，好评。而且除了进度走完(`current==total`)，还支持 `SetCurrent` 的时候传入是否已完成的参数，可以说很人性化了。

除此以外，作者在所有的导出方法的注释中，都有明确的解释，话不多说，贴出来看一下:
```go
// EwmaETA exponential-weighted-moving-average based ETA decorator.
// Note that it's necessary to supply bar.Incr* methods with incremental
// work duration as second argument, in order for this decorator to
// work correctly. This decorator is a wrapper of MovingAverageETA.
func EwmaETA(style TimeStyle, age float64, wcc ...WC) Decorator {
	var average MovingAverage
	if age == 0 {
		average = ewma.NewMovingAverage()
	} else {
		average = ewma.NewMovingAverage(age)
	}
	return MovingAverageETA(style, average, nil, wcc...)
}
```

如果单纯从一个工具包的满足需求的角度上来说，能够得到高 star 的项目都不分伯仲。但是随着深度的使用 `mpb` 包，你会发现你的需求都已经被作者想到了前边。比如:
* 当我们需要加一些状态的提示的时候，例如 `ios` 的 "转圈圈菊花"，发现作者已经写好了 `spinner`；
* 当我们需要在任务完成时候有一些变动和提示的时候，发现作者在示例中有 `OnComplete` 的插件，用于某些指标在进度完成后的呈现；
* 当我们需要进度条在完成后自动消失的时候，发现作者已经写好了 `bar.ClearOnComplete()` 方法，用于在进度条完成后从命令行界面清除。

如果你觉得上边我的描述是大惊小怪的话，那么接下来才是作者良心所在。在看第三方包的时候，是不是经常不知道哪些场景该怎么用哪些方法？是不是在想如果能看一看别人是怎么用的就好了？没问题，作者直接在项目中添加了 [\_examples](https://github.com/vbauerster/mpb/tree/master/_examples) 目录，里边放了十几种使用场景，包括动态修改进度条的 total 值，io 封装，多进度条场景，复杂进度条场景，移除进度条，`spinner` 类型状态等等。都是 `main()` 方法，直接 `run` 即可看到效果。真可谓业界良心。

## 最后

这次的实际使用体验可以说是非常良好了，当然维护一个开源软件需要付出很多的精力，丰富的示例只是其中一方面，还需要代码质量，issue 的回复，review PR 等等。最后再安利一下我们的 [qsctl](https://github.com/qingstor/qsctl) 工具，希望自己也能成为一个优秀的开源项目维护者。
