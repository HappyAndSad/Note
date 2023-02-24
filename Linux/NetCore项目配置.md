#Linux部署core3.1项目
> 参考文档:
>[微软文档 Kestrel web server](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-3.1)
> [微软文档 Host ASP.NET Core on Linux with Nginx](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-3.1)
> *微软文档可以选中文语言,但存在部分错误*

1. 本次部署架构
    采用的是官方推荐架构:
    ![](https://learn.microsoft.com/zh-cn/aspnet/core/fundamentals/servers/kestrel/_static/kestrel-to-internet.png?view=aspnetcore-3.1)

    Kestrel 是 Web 服务器，默认包括在 ASP.NET Core 项目模板中。
    **Kestrel 支持以下方案**：
    - HTTPS
    - 用于启用 WebSocket 的不透明升级
    - 用于获得 Nginx 高性能的 Unix 套接字
    - HTTP/2（在 macOS† 上除外）

    **推荐使用反向代理**
    - 分流加速
    - 安全保护
    - 端口统一
1. 项目启动添加Kestrel配置
    文件配置可以从`appsettings.json`或`appsettings.{Environment}.json`文件中加载
    ``` json 
    {
        "Kestrel": {
            "Limits": {
            "MaxConcurrentConnections": 100,
            "MaxConcurrentUpgradedConnections": 100
            },
            "DisableStringReuse": true
        }
    }
    ```
    **[KestrelServerOptions](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.server.kestrel.core.kestrelserveroptions?view=aspnetcore-3.1) 和 [Endpoint configuration](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-3.1#endpoint-configuration) 可以通过配置提供程序进行配置。 其余的 Kestrel 配置必须采用 C# 代码进行配置。**

    使用以下方法之一：
    - 初始化时加载Kestrel配置
        在`Program.cs`的`IHostBuilder`中添加配置
        参考备注,按需修改
        ``` c#
        public static IHostBuilder CreateHostBuilder(string[] args) =>
                Host.CreateDefaultBuilder(args)
                    .UseContentRoot(AppDomain.CurrentDomain.SetupInformation.ApplicationBase)//设置读取文件的根目录地址(执行文件路径)
                    .UseServiceProviderFactory(new AutofacServiceProviderFactory())//依赖注入
                    .ConfigureServices((context, services) =>
                    {
                        services.Configure<KestrelServerOptions>(
                            context.Configuration.GetSection("Kestrel"));//读取配置文件Kestrel节点
                    })
                    .ConfigureWebHostDefaults(webBuilder =>
                    {
                        webBuilder.ConfigureKestrel(serverOptions =>
                        {
                            //客户端最大连接数
                            serverOptions.Limits.MaxConcurrentConnections = 100;
                            //已从 HTTP 或 HTTPS升级到另一个协议（例如，Websocket 请求）的连接
                            serverOptions.Limits.MaxConcurrentUpgradedConnections = 100;
                            //请求正文最大大小
                            serverOptions.Limits.MaxRequestBodySize = 10 * 1024;
                            //请求正文最小数据速率
                            serverOptions.Limits.MinRequestBodyDataRate =
                                new MinDataRate(bytesPerSecond: 100,
                                    gracePeriod: TimeSpan.FromSeconds(10));
                            serverOptions.Limits.MinResponseDataRate =
                                new MinDataRate(bytesPerSecond: 100,
                                    gracePeriod: TimeSpan.FromSeconds(10));
                            //配置端口
                            serverOptions.Listen(IPAddress.Any, 7001);
                            serverOptions.Listen(IPAddress.Any, 7000, listenOptions =>
                                {
                                    // 将 Kestrel 配置为使用 HTTPS，采用默认证书。
                                    //listenOptions.UseHttps("testCert.pfx","testPassword");
                                });
                            ///获取或设置保持活动状态超时。 默认值为 2 分钟。
                            serverOptions.Limits.KeepAliveTimeout =
                                TimeSpan.FromMinutes(2);
                            //获取或设置服务器接收请求标头所花费的最大时间量。 默认值为 30 秒。
                            serverOptions.Limits.RequestHeadersTimeout =
                                TimeSpan.FromMinutes(1);

                        })
                        .UseStartup<Startup>();
                    });
        ```
    - 启动项中加载Kestrel配置
        ``` c#
        using Microsoft.Extensions.Configuration
        public class Startup
        {
            public Startup(IConfiguration configuration)
            {
                Configuration = configuration;
            }

            public IConfiguration Configuration { get; }

            public void ConfigureServices(IServiceCollection services)
            {
                services.Configure<KestrelServerOptions>(
                    Configuration.GetSection("Kestrel"));
            }

            public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
            {
                ...
            }
        }
        ```


1. 反向代理配置
    - 由于请求通过反向代理转发，因此使用 Microsoft.AspNetCore.HttpOverrides 包中的转接头中间件。 此中间件使用 X-Forwarded-Proto 标头来更新 Request.Scheme，使重定向 URI 和其他安全策略能够正常工作。
    - 转接头中间件应在其他中间件之前运行。 此顺序可确保依赖于转接头信息的中间件可以使用标头值进行处理。 若要在诊断和错误处理中间件后运行转接头中间件，请参阅转接头中间件顺序。
    - 调用其他中间件之前，请先在 Startup.Configure 的基础上调用 UseForwardedHeaders 方法。 配置中间件以转接 X-Forwarded-For 和 X-Forwarded-Proto 标头：

        ```c#
        using Microsoft.AspNetCore.HttpOverrides;

        ...

        app.UseForwardedHeaders(new ForwardedHeadersOptions
        {
            ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
        });

        app.UseAuthentication();
        ```

1. 设置守护进程
    > 使用 systemctl 管理
    - 撰写配置文件
        ``` bash
        > sudo vi /etc/systemd/system/kestrel-helloapp.service
        ```
        配置模版,详细参数查询systemctl 工具
        ``` conf
        [Unit]
        # 描述
        Description=Example .NET Web API App running on Ubuntu

        [Service]
        #工作目录
        WorkingDirectory=/var/www/helloapp
        #执行开始命令:启动工具  启动目录  //两个都必须写绝对路径
        ExecStart=/usr/bin/dotnet /var/www/helloapp/helloapp.dll
        #重启配置
        Restart=always
        # 重启时间 10s
        RestartSec=10
        KillSignal=SIGINT
        SyslogIdentifier=dotnet-example
        #执行用户,必须有相关文件的权限
        User=root
        Environment=ASPNETCORE_ENVIRONMENT=Production
        Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

        [Install]
        #多用户
        WantedBy=multi-user.target
        ```
    - 配置文件写入
    
        ```bash
        > systemctl enable kestrel-helloapp.service
        > systemctl start kestrel-helloapp.service
        ```
        *`.service` 可以不写*

