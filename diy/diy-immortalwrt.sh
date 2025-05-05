#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 修改名称
sed -i 's/ImmortalWrt/OpenWrt/' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/OpenWrt/' include/version.mk
sed -i 's/24.10-SNAPSHOT/24.10.0-rc4/' include/version.mk

##New WiFi
sed -i "s/ImmortalWrt-2.4G/OpenWrt_2.4G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "s/ImmortalWrt-5G/OpenWrt_5G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
# sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
# sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# default-settings
git clone --depth=1 -b openwrt-24.10 https://github.com/Jaykwok2999/default-settings package/default-settings

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://git.kejizero.online/zhao/luci-app-dockerman -b 24.10 feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone https://git.kejizero.online/zhao/packages_utils_docker feeds/packages/utils/docker
git clone https://git.kejizero.online/zhao/packages_utils_dockerd feeds/packages/utils/dockerd
git clone https://git.kejizero.online/zhao/packages_utils_containerd feeds/packages/utils/containerd
git clone https://git.kejizero.online/zhao/packages_utils_runc feeds/packages/utils/runc
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/docker/0001-dockerd-fix-bridge-network.patch | patch -p1
    curl -s https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/docker/0002-docker-add-buildkit-experimental-support.patch | patch -p1
    curl -s https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/openwrt-24.10/files/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch | patch -p1
popd

# uwsgi
# sed -i 's,procd_set_param stderr 1,procd_set_param stderr 0,g' feeds/packages/net/uwsgi/files/uwsgi.init
# sed -i 's,buffer-size = 10000,buffer-size = 131072,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# sed -i 's,logger = luci,#logger = luci,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
# sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
# sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd
# sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
# sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# mwan3
sed -i 's/MultiWAN 管理器/负载均衡/g' feeds/luci/applications/luci-app-mwan3/po/zh_Hans/mwan3.po

# samba4
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json

# HD磁盘工具调至NAS
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json

# 修改FileBrowser
sed -i 's/msgstr "FileBrowser"/msgstr "文件浏览器"/g' feeds/luci/applications/luci-app-filebrowser/po/zh_Hans/filebrowser.po
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-filebrowser/root/usr/share/luci/menu.d/luci-app-filebrowser.json
sed -i 's/msgstr "FileBrowser"/msgstr "文件浏览器GO"/g' feeds/luci/applications/luci-app-filebrowser-go/po/zh_Hans/filebrowser.po
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-filebrowser-go/root/usr/share/luci/menu.d/luci-app-filebrowser.json

# 修改socat为端口转发
sed -i 's/msgstr "Socat"/msgstr "端口转发"/g' feeds/luci/applications/luci-app-socat/po/zh_Hans/socat.po

##加入作者信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='OpenWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By JayKwok'/g" package/base-files/files/etc/openwrt_release

# 移除要替换的包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,adguardhome}
rm -rf feeds/packages/net/ddns-go feeds/luci/applications/luci-app-ddns-go
rm -rf feeds/packages/net/alist feeds/luci/applications/luci-app-alist
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/istoreos_ipk/op-daed
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/istoreos_ipk/msd_lite
rm -rf feeds/istoreos_ipk/op-fileBrowser
rm -rf feeds/istoreos_ipk/op-mosdns
cp -af feeds/istoreos_ipk/patch/wall-luci/luci-app-openclash feeds/luci/applications/
cp -af feeds/istoreos_ipk/ddns-go feeds/packages/net/
cp -af feeds/istoreos_ipk/luci-app-ddns-go feeds/luci/applications/

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# golong1.24.2依赖
rm -rf feeds/packages/lang/golang
# git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# SSRP & Passwall
#git clone https://git.kejizero.online/zhao/openwrt_helloworld.git package/helloworld -b v5
#rm -rf package/helloworld/luci-app-openclash

# Alist
git clone https://git.kejizero.online/zhao/luci-app-alist package/alist

# Mosdns
#git clone https://git.kejizero.online/zhao/luci-app-mosdns.git -b v5 package/mosdns
#git clone https://git.kejizero.online/zhao/v2ray-geodata.git package/v2ray-geodata

# 锐捷认证
git clone https://github.com/sbwml/luci-app-mentohust package/mentohust

# Realtek 网卡 - R8168 & R8125 & R8126 & R8152 & R8101
rm -rf package/kernel/r8168 package/kernel/r8101 package/kernel/r8125 package/kernel/r8126
git clone https://git.kejizero.online/zhao/package_kernel_r8168 package/kernel/r8168
git clone https://git.kejizero.online/zhao/package_kernel_r8152 package/kernel/r8152
git clone https://git.kejizero.online/zhao/package_kernel_r8101 package/kernel/r8101
git clone https://git.kejizero.online/zhao/package_kernel_r8125 package/kernel/r8125
git clone https://git.kejizero.online/zhao/package_kernel_r8126 package/kernel/r8126

# Adguardhome
git_sparse_clone master https://github.com/kenzok8/openwrt-packages adguardhome luci-app-adguardhome

# smartdns
rm -rf feeds/{packages/netsmartdns,luci/applications/luci-app-smartdns}
git_sparse_clone master https://github.com/kenzok8/openwrt-packages smartdns luci-app-smartdns

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone https://git.kejizero.online/zhao/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
git clone https://git.kejizero.online/zhao/luci-app-upnp feeds/luci/applications/luci-app-upnp -b master

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# frpc名称
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,frps 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,frpc 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# 必要的补丁
 pushd feeds/luci
     curl -s https://github.com/Jaykwok2999/istoreos-actions/blob/main/patch/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
 popd

# 修改登录字符
rm -rf feeds/luci/modules/luci-base/po/zh_Hans/base.po
cp -af feeds/istoreos_ipk/patch/diy/base.po feeds/luci/modules/luci-base/po/zh_Hans/

# 修改默认密码
sed -i 's/root:::0:99999:7:::/root:$1$5mjCdAB1$Uk1sNbwoqfHxUmzRIeuZK1:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# 更改 banner
rm -rf package/base-files/files/etc/banner
cp -af feeds/istoreos_ipk/patch/diy/OpenWrt/banner package/base-files/files/etc/

# tailscale
rm -rf feeds/packages/net/tailscale/*
cp -af feeds/istoreos_ipk/tailscale/tailscale/*  feeds/packages/net/tailscale/
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile

./scripts/feeds update -a
./scripts/feeds install -a
