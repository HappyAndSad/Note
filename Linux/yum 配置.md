# yum 配置
>yum 是一个软件仓库,管理软件之间的相互依赖

- 备份现有源
yum 源默认保存在/etc/yum.repos.d/
``` shell
> cp -fr --backup=numbered /etc/yum.repos.d  ~/
```
- 删除数据源
``` shell
> cd /etc/yum.repos.d/ && rm -f *
``` 
- 使用阿里云的yum镜像源(在线下载)
``` shell
> wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
``` 
输入`ls` 查看本地文件

- 修改文件中的实际地址
__直接编辑文件 选项-i ，会匹配file文件中每一行的所有$releasever替换为7__
``` shell
> sed -i  's/$releasever/7/g' /etc/yum.repos.d/CentOS-Base.repo
```
- 更新yum 配置
``` shell
> yum clean all # 清空缓存：
> yum makecache # 生成缓存
```


