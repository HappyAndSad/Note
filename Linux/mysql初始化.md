# Mysql安装
> 通过yum安装

1. 清理环境
    查看是否已经安装Mysql
    ``` shell
    > rpm -qa | grep mysql
    ```
    如果有通过`rpm -e xxx`删除安装包

1. 安装 `Mysql` 源
    1. 下载适合版本,在[官网](https://dev.mysql.com/downloads/repo/yum/)查询
        ``` shell
        #通过wget 下载
        > wget https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
        ```
    1. 添加源
        ``` shell
        > yum install mysql80-community-release-el7-7.noarch.rpm
        ```
    1. 清理
        ```shell
        > rm mysql-community-debuginfo.repo
        > rm mysql-community-source.repo
        ``` 

    1. 查看结果
        ``` shell
        rpm -qa | grep mysql
        ```
1. 安装mysql
    yum 默认安装最新版,所以需要查询出特定版本的全名进行安装
    demo:安装8.0.22-1.el7版本的`mysql`服务
    ``` shell
    > yum search mysql-com --showduplicates
    > yum install mysql-community-server-8.0.22-1.el7.x86_64
    ```
    **yum 锁定更新:**
    防止因为使用 `yum update` 导致数据库升级;
    1. 使用 `Yum versionlock` 插件排除包
        ``` shell
        > yum install yum-plugin-versionlock.noarch
        > yum versionlock add mysql-*
        > yum versionlock list  #查看已锁包
        ```


1. 开启服务
    ``` shell
    > systemctl status  mysqld.service #查看mysql 服务状态
    > systemctl start  mysqld.service # 开启服务 
    ```
    
1. 登录mysql
    __启动服务之后才会生成临时密码__
    
    ``` shell
    > cat /var/log/mysqld.log |grep pass #查看临时密码
    > mysql -u root -p
    mysql> ALTER USER USER() IDENTIFIED BY '123~!@#Qwe';#更新密码
    ```

