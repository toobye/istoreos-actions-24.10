#!/bin/bash

# 克隆 OpenWrt 源码
echo -e "${YELLOW}克隆 OpenWrt 源码...${NC}"
git clone --depth=1 https://github.com/hanwckf/immortalwrt-mt798x.git openwrt

# 更新 feeds 并安装
cd openwrt || exit
echo -e "${GREEN}更新并安装 feeds...${NC}"
echo -e "\nsrc-git extraipk https://github.com/Jaykwok2999/istoreos-ipk" >> feeds.conf.default
echo 'src-git store https://github.com/linkease/istore;main' >>feeds.conf.default
./scripts/feeds update -a
./scripts/feeds install -a

# 修改默认IP
echo -e "${YELLOW}修改默认IP${NC}"
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 设置默认密码
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow

# profile
echo -e "${YELLOW}profile${NC}"
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/PS1/a\export TERM=xterm-color' package/base-files/files/etc/profile

# TTYD
echo -e "${YELLOW}TTYD${NC}"
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# Nginx
echo -e "${YELLOW}Nginx${NC}"
sed -i "s/large_client_header_buffers 2 1k/large_client_header_buffers 4 32k/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i "s/client_max_body_size 128M/client_max_body_size 2048M/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tclient_body_buffer_size 8192M;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tserver_names_hash_bucket_size 128;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -ri "/luci-webui.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations
sed -ri "/luci-cgi_io.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations

# uwsgi
echo -e "${YELLOW}uwsgi${NC}"
sed -i 's,procd_set_param stderr 1,procd_set_param stderr 0,g' feeds/packages/net/uwsgi/files/uwsgi.init
sed -i 's,buffer-size = 10000,buffer-size = 131072,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's,logger = luci,#logger = luci,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd
echo -e "${YELLOW}rpcd${NC}"
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# mwan3
echo -e "${YELLOW}负载均衡${NC}"
sed -i 's/MultiWAN 管理器/负载均衡/g' feeds/luci/applications/luci-app-mwan3/po/zh_Hans/mwan3.po

##
echo -e "\nmsgid \"Control\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"控制\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo -e "\nmsgid \"NAS\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"网络存储\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo -e "\nmsgid \"VPN\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"魔法网络\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

##取消bootstrap为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

##更换主题为argon
rm -rf feeds/luci/themes/luci-theme-argon/*
cp -af feeds/extraipk/theme/luci-theme-argon/* feeds/luci/themes/luci-theme-argon/

##加入作者信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='OpenWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By JayKwok'/g" package/base-files/files/etc/openwrt_release

##WiFi
sed -i "s/MT7986_AX6000_2.4G/OpenWrt-2.4G/g" package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b0.dat
sed -i "s/MT7986_AX6000_5G/OpenWrt-5G/g" package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b1.dat

sed -i "s/MT7981_AX3000_2.4G/OpenWrt-2.4G/g" package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b0.dat
sed -i "s/MT7981_AX3000_5G/OpenWrt-5G/g" package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b1.dat

##New WiFi
sed -i "s/ImmortalWrt-2.4G/OpenWrt-2.4G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "s/ImmortalWrt-5G/OpenWrt-5G/g" package/mtk/applications/mtwifi-cfg/files/mtwifi.sh


##更新FQ
rm -rf feeds/luci/applications/luci-app-openclash/*
cp -af feeds/extraipk/patch/wall-luci/luci-app-openclash/*  feeds/luci/applications/luci-app-openclash/

rm -rf package/base-files/files/etc/banner
cp -af feeds/extraipk/patch/diy/banner  package/base-files/files/etc/
rm -rf feeds/extraipk/nas-packages-luci/luci/luci-app-quickstart/htdocs/luci-static/quickstart/index.js
cp -af feeds/extraipk/diy/index.js feeds/extraipk/nas-packages-luci/luci/luci-app-quickstart/htdocs/luci-static/quickstart/

##MosDNS
rm -rf feeds/packages/net/mosdns/*
cp -af feeds/extraipk/op-mosdns/mosdns/* feeds/packages/net/mosdns/
rm -rf feeds/packages/net/v2ray-geodata/*
cp -af feeds/extraipk/op-mosdns/v2ray-geodata/* feeds/packages/net/v2ray-geodata/

# 一键配置拨号
echo -e "${YELLOW}一键配置拨号${NC}"
git clone --depth=1 https://github.com/sirpdboy/luci-app-netwizard package/luci-app-netwizard

# 修改名称
echo -e "${YELLOW}修改名称${NC}"
sed -i "s/hostname='ImmortalWrt'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='ImmortalWrt'/hostname='OpenWrt'/g" include/version.mk

# 进阶设置
echo -e "${YELLOW}进阶设置${NC}"
git clone https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus

# NTP
echo -e "${YELLOW}NTP${NC}"
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

./scripts/feeds update -a
./scripts/feeds install -a

# 加载 .config
echo -e "${YELLOW}加载 .config${NC}"
echo -e "${YELLOW}加载自定义配置...${NC}"
curl -skL https://github.com/Jaykwok2999/istoreos-actions/blob/main/configs/360T7.config -o .config

# 生成默认配置
echo -e "${GREEN}生成默认配置...${NC}"
make defconfig

# 编译 ZeroWrt
echo -e "${BLUE}开始编译 OpenWrt...${NC}"
echo -e "${YELLOW}使用所有可用的 CPU 核心进行并行编译...${NC}"
make -j$(nproc) || make -j1 || make -j1 V=s
  
# 输出编译完成的固件路径
echo -e "${GREEN}编译完成！固件已生成至：${NC} bin/targets"
