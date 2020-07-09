---
layout:     post
title:      rpm 包的 pre/post install/remove 脚本
subtitle:   yum / rpm 使用心得
date:       2020-07-09
author:     Lance
header-img: img/post-bg-rain-drops.jpg
catalog: true
tags:
    - Devops
    - 工具集安利
---

## rpm

众所周知，rpm 是 Redhat 开发的在 centos 上的包管理方式，使用rpm我们可以方便的进行软件的安装、查询、卸载、升级等工作。我们可以将自己写好的程序打包成 .rpm 文件，其中可能包含配置文件的模板，用到的脚本，以及最重要的二进制文件等。这样只需要在对应的服务器上执行 
```
rpm -ivh xxx.rpm
``` 
命令即可完成安装操作。

同样，也可以使用 yum 来对服务器上的包进行管理，相比 rpm 而言，yum 处理依赖更容易，而且也可以像 Ubuntu 的 apt-get 一样在线下载并安装需要的包。

## nfpm

接下来谈谈如何打包成 rpm 包。在我刚来公司的时候，还有许多项目中包含着 "祖传脚本"，里边是前期同事写好的各种打包脚本，逻辑复杂且需要各种依赖，对新入职的我而言非常不友好。

后来在我们这个项目开发差不多的时候，也需要进行打包的操作以方便进行部署。对着一堆 shell 脚本的我，一脸懵逼。这时候又是小伙伴 [Xuanwo](https://xuanwo.io/) 告诉我可以尝试一下 [nfpm](https://goreleaser.com/customization/nfpm/)，[github链接](https://github.com/goreleaser/nfpm)。

看了看文档，这是一个 golang 开发的工具，只需要通过 
```
go get -u github.com/goreleaser/nfpm/cmd/nfpm
```
即可安装。打包时使用 
```
nfpm pkg --target xxx
``` 

所有的打包配置全都通过一个 `nfpm.yaml` 文件，里边可以配置诸如包名、适用的架构、平台、版本号、release、维护信息等等。当然最重要的还是需要配置包中的文件与配置文件。除此之外，nfpm 也支持 pre, post, preun 与 postun 脚本，只不过他们在 nfpm 的配置中对应 `preinstall`, `postinstall`, `preremove`, `postremove`。

**PS**: nfpm 支持打包为 rpm 和 deb 文件，你只需要命名打包的 target 以 `.rpm` 结尾还是 `.deb` 结尾，会自动识别并调用相应的打包工具进行打包操作。

## upgrade

接下来是今天的重点，我们的服务是基于 supervisor 来管理的，所以自然而然的期望在 postinstall 中加入 `supervisorctl update` 或者 `supervisor start` 这样的操作；同时，在 postremove 中加入 `supervisorctl stop` 和 `supervisorctl remove` 的操作。

我们期待的行为是：
- 在第一次安装包的时候，完成安装之后直接可以将服务拉起来；
- 在卸载包的时候，完成卸载之后可以将服务从 supervisor 中删掉；
- 当升级的时候，**先卸载旧包，再安装新包**，依然可以使得服务继续运行。

**理想很丰满，现实很骨感。**

在我添加了脚本之后，在测试机上进行升级操作时，发现是**先安装新包，再删除掉旧包**。这样就使得每次安装完，最后执行的是 `supervisorctl remove` 的操作，postinstall 的部分相当于被覆盖了。

就又只能借助谷歌了，找到了这么一篇文章[用 RPM 打包软件，第 3 部分
--在安装和卸载时运行脚本](https://www.ibm.com/developerworks/cn/linux/management/package/rpm/part3/index.html)。

>以下是 RPM 如何执行升级：
1. 运行新包的 %pre
2. 安装新文件
3. 运行新包的 %post
4. 运行旧包的 %preun
5. 删除新文件未覆盖的所有旧文件
6. 运行旧包的 %postun

>如果我们使用前面的示例来升级，那么 RPM 最后将运行 %postun 脚本， 它将除去我们在安装脚本中所做的所有工作！

这不正是我们遇到的问题么。。。

## 解决方案

>相当幸运的是，在一定程度上，脚本有一种方法可以告之是否正在安装、删除或升级包。每个脚本都被传递单一命令行参数 ― 一个数字。 这应该告诉脚本 在当前包完成安装或卸载之后将安装多少个包的副本。

| Action | Count |
| --- | --- |
| Install the first time | 1 |
| Upgrade | 2 or higher (depending on the number of versions installed) |
| Remove last version of package | 0 |

>只查看在各种情况下传递的值或许更容易，而不是尝试计算它。
- 这里是在安装期间传递的实际值：
  - 运行新包的 %pre (1)
  - 安装新文件
  - 运行新包的 %post (1)
- 这里是在升级期间传递的值：
  - 运行新包的 %pre (2)
  - 安装新文件
  - 运行新包的 %post (2)
  - 运行旧包的 %preun (1)
  - 删除新文件未覆盖的任何旧文件
  - 运行旧包的 %postun (1)
- 这里是在删除期间传递的值：
  - 运行旧包的 %preun (0)
  - 删除文件
  - 运行旧包的 %postun (0)

所以我们只需要在脚本中添加一个参数获取，并且对该参数进行条件判断，来确定是否是我们所需要的情况即可。

## 最后一个坑

为了确保这个参数正确，我先把所有的脚本操作改为 `echo post insall/remove $1`，来确认是否正常的得到参数。

然后到测试服务器上进行更新操作，结果发现只打印了 `post install 2`，并没有打印 `post remove 1`。检查了一下，添加了更多的测试打印信息，并删除了 postinstall 脚本之后，又进行了一次更新操作。结果这次只打印了，`post remove 1`。

到底是咋回事呢？

又翻了一下日志的输入，突然明白了，我们在当次执行 `upgrade` 操作，将包 v1 升级成 v2，调用的是 v2 包的 postinstall 脚本和 v1 包的 postremove 脚本。

## 总结

1. 要动手去试，工具/程序的逻辑可能与我们想当然的有出入。
2. 一切现象都是可以解释的，如果它暂时不合理，那不应该用不合理的方式去忽略它，而应该去进一步探究真相。

