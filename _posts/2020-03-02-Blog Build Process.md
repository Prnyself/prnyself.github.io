---
layout:     post_dark
title:      博客建立的历程
subtitle:   与其感慨路难行，不如马上出发
date:       2020-03-02
author:     Lance
header-img: img/post-bg-desktop.jpg
catalog: true
tags:
    - UnCategory
    - 工具集安利
---


## 写在最前

这个博客的简历是受小伙伴 [Xuanwo](https://xuanwo.io/) 的启发，之前我想到的博客还是 WordPress 那种，被他吐槽 "9102 年了，用静态博客吧"。
但是翻了翻教程看起来从零开始也挺麻烦的，于是本来打算直接用 github page 凑合个主题开始的我就把这事儿搁一边了。最近疫情在家想着还是应该把写博客这件事拾起来，毕竟作为程序猿平常与人交流的机会就不多，用文字表达的机会就更少了。未雨绸缪，现在就拿写博客开始锻炼吧。

## 搜个模板

趁着这个周末就搜个博客的模板看看，就找到了这个在 github 上 star 很多的项目 [BY 的博客](https://github.com/qiubaiying/qiubaiying.github.io)，于是就凑表脸的 fork 了一份拿来改起。

## 准备本地预览环境

不建议大家每次更新都 push 到 github 上去看效果，这样效率太低，最好本地构建个预览环境，每次修改后先在本地确认效果，再 push 到线上即可。这个 blog 也没什么复杂的依赖，看起来只有 [Jekyll](https://jekyllcn.com/) 一个 Gem 而已。
由于之前一直凑合着用 Mac 自带的 Ruby 来做解释器，(还是 1.9.3 的上古版本)，并没需求升级。现在开始装 [Jekyll](https://jekyllcn.com/) 的 Gem 包的时候，被提示 Ruby 版本过低，需要至少 2.4.0 以上。所以只能去提升 Ruby 版本了。

## 安装 RVM

升级 Ruby 版本推荐使用 [RVM (Ruby Version Manager)](https://rvm.io/rvm/install) 来安装，这里不得不吐槽一下 ruby China 的文档，和我当年看的还是一样的，貌似现在 GPG key 生成的链接变了也没更新，建议大家直接按 RVM 官网的 install 说明来即可。安装完成后，使用 `rvm -v` 指令能够正确查看到版本信息即说明安装成功。

## 安装 Ruby

没啥好说的，直接 `rvm install x.x.x` 即可。不确定的话可以 `rvm list known` 查看可用的 Ruby 版本列表，这里选择了 2.5 版本的，即 `rvm install 2.5`，rvm 会自动选择小版本号进行安装。

## 安装 Jekyll Gem

执行 `gem install jekyll bundler` 来安装 Jekyll Gem，结果发现提示 Homebrew update 失败，看了看应该是墙的原因导致连不上 Homebrew 的。

## 替换 Homebrew 源镜像

继续 Google 解决办法，国内的清华搞的有开源软件镜像站，可以将 Homebrew 的源替换为国内的镜像，从而解决墙的问题。链接在此 [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/) 请自行取用。

## 重新安装 Jekyll Gem

重新安装 Jekyll Gem，成功后进入你的 blog 项目目录，在目录下执行 `jekyll serve` 命令即可构建本地环境，启动后即可在浏览器打开页面 (默认是 `http://127.0.0.1:4000`) 查看。

## 启动报错

服务启动后页面上可正常浏览，但是主页没有显示完全，在终端中看到有报错提示如 `Liquid Warning: Liquid syntax error index.html (line 61)`，不知道是不是 Liquid 的语法发生了变化，我们只需要将 html 文件中的注入模板修改即可: `"tag[1].size > {{site.featured-condition-size}}"` 修改成 `"tag[1].size > site.featured-condition-size"`。

另外还有翻页插件报错，提示需要再 config 中配置 `plugins: [jekyll-paginate]`，只需要将这个配置加进 `_config.yml` 文件即可。如果本地没有安装 `jekyll-paginate` 这个 Gem 的话，只需要 `gem install jekyll-paginate` 安装就行了。

## gitalk

这个博客项目的教程中有关于评论插件的说明，这里不再赘述。我把 token 配置好后，发现新建评论报网络错误，看了一下报错信息，发现是新建应用时的 `Authorization callback URL` 填的是 `http://prnyself.github.io`。而由于我添加了 CNAME 导致会自动跳转，所以导致 OAuth 回调的地址对不上。直接去 [github developer setting](https://github.com/settings/developers) 中修改回调地址即可。

## 图片处理

博客经常需要有各种配图，但是现在动辄截图都是几个 M，更不用说网上的高清图片了。本身 github 连接就不快的前提下，只能压缩图片了。安利一个在 Mac 上挺好用的图片处理软件，`Movavi Photo Editor 6`，已经可以应对日常大部分非专业图片处理的需求了。

## 最后

总算在这里写完了第一篇博客，希望以这个作为一个好的开始。

> PS: 副标题中 ”与其感慨路难行，不如马上出发“
这句话是 DOTA2 中小骷髅的台词，英文原句是 Better to run than curse the road.