# ib-overlay
Custom overlay files and scripts for OpenWrt ImageBuilder 24.10.2
<br>
此项目 记录了我修改的文件和脚本。你可以把它当做模板。
## 定位到ImageBuilder的根目录下

## 下载整个项目的 master.zip
wget -O master.zip https://gh-proxy.com/https://github.com/wukongdaily/ib-overlay/archive/refs/heads/master.zip
## 解压 master.zip 到当前目录，去除无关文件
```
unzip master.zip -d tempdir
rm -f tempdir/*/.gitignore tempdir/*/README.md tempdir/*/LICENSE
mv tempdir/*/* ./
rm -rf tempdir
ls -lah
```
> 当然你也可以先【fork】本项目 将项目同步到自己的空间，做一些修改、删减。然后在下载整个项目的zip 或者 git clone

## 关键修改说明
> `.config` 此文件是全部配置，是.开头的隐藏文件,一般不需要动。如果 想去掉ext4 格式 可以在这里改<br>
> `extra-packages` 这是我新建的目录 可以存放run文件。也可以存放自定义ipk 但最好是run 因为这样比较整齐 是一个整体<br>
> `files` 这也是我新建的目录 它对应的就是openwrt的根目录，比如files/etc  可覆盖openwrt系统里的/etc 这里存放的文件 会原样注入系统<br>
> `prepare-packages.sh` 此脚本用于 make image之前的准备工作，用于将`extra-packages`中的run解压后的ipk 或者原本的ipk复制到`packages`中<br>
> `packages` 用于存放自定义ipk的，但是我为了整齐 可读性强，我采用上述脚本方式 自动将`extra-packages`中的所有ipk拷贝过来<br>
> `repositories.conf`  这是仓库地址 你可以修改它 将ImageBuilder工具中的仓库地址替换为阿里云仓库 加快构建时的下载速度<br>
