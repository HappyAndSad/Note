# Mysql主从
>参考文档:[秋天的童话_的《如何使用MySQL进行主从复制》](https://blog.csdn.net/han1725692339/article/details/125912816)
- MySQL数据库默认是支持主从复制的.MySQL主从复制是一个异步的复制过程，底层是基于Mysql数据库自带的 二进制日志 功能.
- 二进制日志（BINLOG）记录了所有的 DDL（数据定义语言）语句和 DML（数据操纵语言）语句，但是不包括数据查询语句。

__MySQL的主从复制原理如下 ：__

![](https://img-blog.csdnimg.cn/81d967947dee465f8c98b124697cf3bd.png)

## 配置
__安装Mysql就不写了,详细描述一下主从的步骤__
__建议浏览全文之后进行配置,大概清楚要弄哪些东西__
1. 修改各自数据库的配置文件/etc/my.cnf

    __主服务器__
    ```conf
    log-bin=mysql-bin  #开启二进制日志
    server-id=200  #服务器唯一ID(用于标识该语句最初是从哪个server写入的)
    ```

    __从服务器__

    ```conf
    server-id=201  #服务器唯一ID(用于标识该语句最初是从哪个server写入的)
    ```
    配置之后重启数据库
2. 主库查看信息
    __主服务器创建用户用于同步__
    ``` sql
    -- 创建用户
    create user 'syncdata'@'%' identified by 'SyncData@2022!';
    -- 提升权限
    grant replication slave on *.* to 'syncdata'@'%'; 
    -- 查看日志位点信息，包括binlog file，binlog position等
    show master status;
    ``` 
    关注红框中的参数,需要在从库中配置
    ![](https://img-blog.csdnimg.cn/c966d8cb6fcf4d38bfeb8898ba18c074.png)

3. 从库配置

    __总体顺序为,设置主从,开启slave,查看主从状态__
    __设置失败之后,关闭slave,设置主从,开启slave,查看主从状态__
    ```sql
    -- (参数都是主库的!)设置主库链接,设置之前需要关闭 slave;
    -- 参数分别为host,用户,端口,密码,binlog file,binlog position
    change master to master_host='192.168.199.128',master_user='copy',master_port=3307,master_password='123456',master_log_file='mysql-bin.000001',master_log_pos=154;
    --启动IO线程和SQL线程
    start slave; 
    --查看状态
    show slave status \G;
    ```
    ![结果](https://img-blog.csdnimg.cn/3e13c9c808dd4d0e84386d62ac7e814a.png)
    两个都是yes才表示开启成功
    错误的话,error 中提供错误日志
    ``` sql
    -- 关闭slave (需要重新配置主从的话)
    stop slave;
    ```

