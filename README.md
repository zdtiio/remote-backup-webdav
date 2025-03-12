# remote-backup-webdav
Linux服务器利用webdav功能（davfs2客户端）挂载远端存储，定时备份服务器数据。

# 项目目录

默认存放在 `/home` 下

```
/home/remote_backup
        - log               ：存放日志文件
        - sh                ：存放shell脚本
        - tmp_size_file     ：存放计算文件大小的临时文件夹
        - webdav            ：用于挂载 webdav 文件夹
```

# 使用方式

1. Linux 安装配置 `davfs2` 客户端，并配置免输入用户名密码登录；
2. 将本项目拷贝到 `/home` 文件夹下；
3. 将本项目中的示例脚本 `task1_remote_backup.sh` 修改为你需要备份的目录；
4. 将本项目中 `sh` 文件夹下的脚本添加可执行权限， `chmod +x your_sh_file_name` ；
5. 添加 `cron 定时任务`，配置定时执行 `main_sync.sh`。
