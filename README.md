# Plugin MySQL for Qt Android

## 在Linux（64位）上配置Qt Android开发环境（其实可以用Windows和WSL解决编译问题）
**注意:** 以下所有终端命令必须以sudo开头，以获得管理员权限。

* 安装必要组件:
```
apt-get update
apt-get upgrade
apt-get install build-essential libgl1-mesa-dev cmake perl openssh-server git
```

* 修复 UMake 以快速安装 Android Studio:
```
add-apt-repository ppa:lyzardking/ubuntu-make
apt-get update
apt-get install ubuntu-make
```

* 安装 Android Studio: `umake android`
* 启动Android Studio并安装SDK ** r21 **（重要：安装此程序是因为它是NDK r10e满足的最后一个）
* 从 Qt 需要的 Android 站点下载 NDK，并将其解压缩到 SDK 文件夹中

* 从Qt网站（国内强烈推荐在清华tuna源离线安装）下载Qt-Online-Installer并进行安装（为其授予“ chmod + x”执行权限）

```

所需软件包：
* 5.9.3 Android ARMv7
* 5.9.3 Sources
* 5.9.3 Desktop gcc 64-bit
```

* 通过在Android部分中输入SDK和NDK r10e的路径来配置Qt Creator



## 构建 Plugin QtSQL MySQL for Android （Linux）

脚本的原始存储库 plugin MySQL for Android: https://bitbucket.org/aykutozdemir/mysql_driver_qt/

Ruscelli Fabio的备份存储库: https://github.com/fabiorush92/Qt_Android_MySQL_Plugin

* 在bash文件“ build_qt_mysql_driver.sh”中，修改对Qt文件夹和NDK的引用

* 克隆存储库：

`git clone <plugin_repo>`

`cd <plugin_repo>`

* 授予脚本执行权限并启动它：

`sudo chmod +x build_qt_mysql_driver.sh`

`./build_qt_mysql_driver.sh`

如果构建成功完成，则QSqlMySQL驱动程序将已经复制到Qt（Android ARMv7）的二进制文件中。

**注意:** 记住要添加刚刚构建并包含在以下库中的libmariadb.so库：
`<NDK_r10e>/platforms/android-21/arch-arm/usr/lib/mariadb`

## 构建 Plugin QtSQL MySQL for Android （Windows）
1、安装msys（关于msys用法请自己搜索）
2、下载NDK r12 的Windows和Linux版本，以及r21的Windows版本
3、在msys中用本脚本（r12）构建libiconv、openssl（注意修改对应的路径，下同。）
4、在WSL中用本脚本（r12）构建mariadb（注意把上面构建好的usr目录下的文件复制到Linux用）
5、在msys中用本脚本（r21）构建MySQL插件（注意把上面构建好的usr目录下的文件复制到Windows的r21版本用）
6、复制插件到对应位置。

**注意:** 记住要添加刚刚构建并包含在以下库中的libmariadb.so库：
`<NDK_r10e>/platforms/android-21/arch-arm/usr/lib/mariadb`

**注意:** 在第5步过程中可能会遇到编译完成arm 32位版本后编译64位失败而停止的情况，此时只需要自行到对应路径下make install就行了。
以上操作构建Qt 5.14.2对应版本插件成功。
不过就算能用，bug也不少，包括不能对全局的database直接初始化等等。“勉强能用”
