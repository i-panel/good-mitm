#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}error：${plain} The script must be run as root！\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}The system version was not detected, please contact the script author！${plain}\n" && exit 1
fi

# Modified architecture detection
arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    download_arch="x86_64-unknown-linux-gnu"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    download_arch="aarch64-unknown-linux-gnu"
elif [[ $arch == "armv7l" ]]; then
    download_arch="armv7-unknown-linux-gnueabihf"
else
    echo -e "${red}Unsupported architecture: ${arch}${plain}"
    exit 1
fi

echo "Architecture: ${arch}"
echo "Download architecture: ${download_arch}"

# Check if system is 32-bit
if [ "$(getconf WORD_BIT)" != '32' ] && [ "$(getconf LONG_BIT)" != '64' ] ; then
    echo "This software does not support 32-bit systems, please use 64-bit system"
    exit 2
fi

# OS version check
os_version=""

if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Please use CentOS 7 or later system！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Please use Ubuntu 16 or later system！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Please use Debian 8 or later！${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install epel-release -y
        yum install wget curl unzip tar crontabs socat -y
    else
        apt update -y
        apt install wget curl unzip tar cron socat -y
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /etc/systemd/system/video-mitm.service ]]; then
        return 2
    fi
    temp=$(systemctl status video-mitm | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

install_acme() {
    curl https://get.acme.sh | sh
}

install_Video-Mitm() {
    if [[ -e /usr/local/video-mitm/ ]]; then
        rm /usr/local/video-mitm/ -rf
    fi

    mkdir /usr/local/video-mitm/ -p
    cd /usr/local/video-mitm/

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/i-panel/good-mitm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}Failed to detect version, it may be beyond the Github API limit, please try again later, or manually specify the version to install${plain}"
            exit 1
        fi
        echo -e "Latest version detected: ${last_version}, starting installation"
    else
        if [[ $1 == v* ]]; then
            last_version=$1
        else
            last_version="v"$1
        fi
        echo -e "Starting installation version ${last_version}"
    fi

    # Remove 'v' prefix for filename
    version_number=${last_version#v}
    
    # Construct filename
    filename="video-mitm-${version_number}-${download_arch}.tar.xz"
    download_url="https://github.com/i-panel/good-mitm/releases/download/${last_version}/${filename}"
    
    echo "Downloading from: ${download_url}"
    wget -q -N --no-check-certificate -O /usr/local/video-mitm/${filename} ${download_url}
    
    if [[ $? -ne 0 ]]; then
        echo -e "${red}Download failed, please make sure the version exists and your server can access Github${plain}"
        exit 1
    fi

    tar -xJf ${filename}
    rm ${filename} -f
    chmod +x video-mitm
    
    mkdir /etc/video-mitm/ -p
    rm /etc/systemd/system/video-mitm.service -f
    
    wget -q -N --no-check-certificate -O /etc/systemd/system/video-mitm.service "https://github.com/i-panel/good-mitm/raw/main/video-mitm.service.template"
    
    wget -q -N --no-check-certificate -O /etc/video-mitm/config.yaml "https://raw.githubusercontent.com/i-panel/good-mitm/refs/heads/main/rules/netflix.yaml"
    if [[ $? -ne 0 ]]; then
        echo -e "${red}Failed to download config, please make sure your server can access Github${plain}"
        exit 1
    fi

    systemctl daemon-reload
    systemctl stop video-mitm
    systemctl enable video-mitm
    echo -e "${green}version ${last_version}${plain} installation complete, set to start on boot"

    if [[ ! -f /etc/video-mitm/config.yaml ]]; then
        cp config.yaml /etc/video-mitm/
        echo -e ""
        echo -e "Fresh installation, please refer to the documentation first: https://github.com/i-panel/good-mitm"
    else
        systemctl start video-mitm
        sleep 2
        check_status
        echo -e ""
        if [[ $? == 0 ]]; then
            echo -e "${green}video-mitm restarted successfully${plain}"
        else
            echo -e "${red}video-mitm may have failed to start, please check logs with 'video-mitm log'. If it won't start, config format may have changed, please check the wiki: https://github.com/XrayR-project/video-mitm/wiki${plain}"
        fi
    fi

    curl -o /usr/bin/video-mitm -Ls https://raw.githubusercontent.com/i-panel/good-mitm/main/video-mitm.sh
    chmod +x /usr/bin/video-mitm
    ln -s /usr/bin/video-mitm /usr/bin/Video-Mitm # 小写兼容
    chmod +x /usr/bin/Video-Mitm
    cd $cur_dir
    rm -f install.sh
    echo -e ""
    echo "How to use video-mitm management scripts (compatible with video-mitm execution, case insensitive): "
    echo "------------------------------------------"
    echo "video-mitm                    - Show admin menu (more features)"
    echo "video-mitm start              - start video-mitm"
    echo "video-mitm stop               - stop video-mitm"
    echo "video-mitm restart            - restart video-mitm"
    echo "video-mitm status             - View video-mitm status"
    echo "video-mitm enable             - Set video-mitm to start automatically at boot"
    echo "video-mitm disable            - Disable video-mitm autostart"
    echo "video-mitm log                - View video-mitm logs"
    echo "video-mitm update             - Update video-mitm"
    echo "video-mitm update x.x.x       - Update the specified version of video-mitm"
    echo "video-mitm config             - Show configuration file content"
    echo "video-mitm install            - Install video-mitm"
    echo "video-mitm uninstall          - Uninstall video-mitm"
    echo "video-mitm version            - View video-mitm version"
    echo "------------------------------------------"
}

echo -e "${green}start installation${plain}"
install_base
# install_acme
install_Video-Mitm $1
