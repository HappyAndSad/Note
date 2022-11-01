# SSH 远程服务器文件中文乱码

1. 检测本地语言环境
	+ locale :查看本地语言环境
	+ locale -a: 查看本机所有支持的编码环境

2. 通过系统工具重新安装语言包
	+ dpkg-reconfigure  
	> dpkg 命令用于管理系统包,“Debian Packager ”的简写<br/>
	> Debian Linux中重新配置已经安装过的软件包，可以将一个或者多个已安装的软件包传递给此指令，它将询问软件初次安装后的配置问题。
	```
	dpkg-reconfigure locale
	```

3. 设置本地语言指向对应的语言版本
	```
	//将所有语言编码设置为 en_US.UTF-8;
	export LC_ALL="en_US.UTF-8"
	```


	https://github.com/dotnetcore/fastgithub/releases#:~:text=fastgithub_linux%2Darm64.
	https://github.com/dotnetcore/FastGithub/releases/download/2.1.4/fastgithub_linux-arm64.zip
	https://github.com/v2fly/v2ray-core/releases/download/v5.1.0/v2ray-linux-arm64-v8a.zip

	