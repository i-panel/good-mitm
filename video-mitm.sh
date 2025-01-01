#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}error: ${plain} The root user must be used to run this script!\n" && exit 1

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

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [default$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "whether to restart video-mitm" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Press enter to return to the main menu: ${plain}" && read temp
    show_menu
}

install() {
    bash <(curl -Ls https://raw.githubusercontent.com/kontorol/good-mitm/main/install.sh)
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    if [[ $# == 0 ]]; then
        echo && echo -n -e "Enter the specified version (default latest version): " && read version
    else
        version=$2
    fi
#    confirm "本功能会强制重装当前最新版，数据不会丢失，是否继续?" "n"
#    if [[ $? != 0 ]]; then
#        echo -e "${red}已取消${plain}"
#        if [[ $1 != 0 ]]; then
#            before_show_menu
#        fi
#        return 0
#    fi
    bash <(curl -Ls https://raw.githubusercontent.com/kontorol/good-mitm/main/install.sh) $version
    if [[ $? == 0 ]]; then
        echo -e "${green}The update is complete and video-mitm has automatically restarted, please use video-mitm log to view the running log ${plain}"
        exit
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

config() {
    echo "video-mitm It will automatically try to restart after modifying the configuration"
    vi /etc/video-mitm/config.yaml
    sleep 2
    check_status
    case $? in
        0)
            echo -e "video-mitm state: ${green} has been run ${plain}"
            ;;
        1)
            echo -e "It is detected that you have not started video-mitm or video-mitm failed to restart automatically, check the log？[Y/n]" && echo
            read -e -p "(default: y):" yn
            [[ -z ${yn} ]] && yn="y"
            if [[ ${yn} == [Yy] ]]; then
               show_log
            fi
            ;;
        2)
            echo -e "video-mitm status: ${red}Not Installed${plain}"
    esac
}

uninstall() {
    confirm "Are you sure you want to uninstall video-mitm?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop video-mitm
    systemctl disable video-mitm
    rm /etc/systemd/system/video-mitm.service -f
    systemctl daemon-reload
    systemctl reset-failed
    rm /etc/video-mitm/ -rf
    rm /usr/local/video-mitm/ -rf

    echo ""
    echo -e "The uninstall is successful, if you want to delete this script, run it after exiting the script ${green}rm /usr/bin/video-mitm -f${plain} to delete"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}video-mitm Already running, no need to start again, if you need to restart, please select restart${plain}"
    else
        systemctl start video-mitm
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            echo -e "${green}video-mitm The startup is successful, please use video-mitm log to view the running log${plain}"
        else
            echo -e "${red}video-mitm startup may fail, please use video-mitm log to check the log information later${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    systemctl stop video-mitm
    sleep 2
    check_status
    if [[ $? == 1 ]]; then
        echo -e "${green}video-mitm stop success${plain}"
    else
        echo -e "${red}video-mitm failed to stop, probably because the stop time exceeded two seconds, please check the log information later${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    systemctl restart video-mitm
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        echo -e "${green}video-mitm restarted successfully, please use video-mitm log to view the running log${plain}"
    else
        echo -e "${red}video-mitm may fail to start, please use video-mitm log to view log information later${plain}"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    systemctl status video-mitm --no-pager -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    systemctl enable video-mitm
    if [[ $? == 0 ]]; then
        echo -e "${green}video-mitm Set the boot to start automatically${plain}"
    else
        echo -e "${red}video-mitm failed to set autostart${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    systemctl disable video-mitm
    if [[ $? == 0 ]]; then
        echo -e "${green}video-mitm Cancellation of automatic startup${plain}"
    else
        echo -e "${red}video-mitm failed to cancel autostart${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    journalctl -u video-mitm.service -e --no-pager -f
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

install_bbr() {
    bash <(curl -L -s https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/main/tcp.sh)
    #if [[ $? == 0 ]]; then
    #    echo ""
    #    echo -e "${green}安装 bbr 成功，请重启服务器${plain}"
    #else
    #    echo ""
    #    echo -e "${red}下载 bbr 安装脚本失败，请检查本机能否连接 Github${plain}"
    #fi

    #before_show_menu
}

update_shell() {
    wget -O /usr/bin/video-mitm -N --no-check-certificate https://raw.githubusercontent.com/kontorol/good-mitm/main/video-mitm.sh
    if [[ $? != 0 ]]; then
        echo ""
        echo -e "${red}Failed to download the script, please check whether the machine can connect to Github${plain}"
        before_show_menu
    else
        chmod +x /usr/bin/video-mitm
        echo -e "${green}The upgrade script was successful, please run the script again${plain}" && exit 0
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

check_enabled() {
    temp=$(systemctl is-enabled video-mitm)
    if [[ x"${temp}" == x"enabled" ]]; then
        return 0
    else
        return 1;
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        echo -e "${red}video-mitm already installed, please do not repeat the installation${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        echo -e "${red}Please install video-mitm first${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
        0)
            echo -e "video-mitm status: ${green}has been run${plain}"
            show_enable_status
            ;;
        1)
            echo -e "video-mitm status: ${yellow}not running${plain}"
            show_enable_status
            ;;
        2)
            echo -e "video-mitm status: ${red}Not Installed${plain}"
    esac
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "Whether to start automatically: ${green}yes${plain}"
    else
        echo -e "Whether to start automatically: ${red}no${plain}"
    fi
}

generate_ca() {
    echo -n "video-mitm Generating CA Cert："
    /usr/local/video-mitm/video-mitm genca
    echo ""
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_usage() {
    echo "video-mitm How to use the management script: "
    echo "------------------------------------------"
    echo "video-mitm              - Show admin menu (more features)"
    echo "video-mitm start        - start video-mitm"
    echo "video-mitm stop         - stop video-mitm"
    echo "video-mitm restart      - restart video-mitm"
    echo "video-mitm status       - Check video-mitm status"
    echo "video-mitm enable       - Set video-mitm to start automatically at boot"
    echo "video-mitm disable      - Disable video-mitm autostart"
    echo "video-mitm log          - View video-mitm logs"
    echo "video-mitm update       - Update video-mitm"
    echo "video-mitm update x.x.x - Update the specified version of video-mitm"
    echo "video-mitm install      - Install video-mitm"
    echo "video-mitm uninstall    - uninstall video-mitm"
    echo "video-mitm version      - View video-mitm version"
    echo "video-mitm genca        - Generate CA Certificate"
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}XrayR backend management script，${plain}${red}not applicabledocker${plain}
--- https://github.com/kontorol/good-mitm ---
  ${green}0.${plain} Change setting
————————————————
  ${green}1.${plain} Install video-mitm
  ${green}2.${plain} renew video-mitm
  ${green}3.${plain} uninstall video-mitm
————————————————
  ${green}4.${plain} start video-mitm
  ${green}5.${plain} stop video-mitm
  ${green}6.${plain} reboot video-mitm
  ${green}7.${plain} Check video-mitm status
  ${green}8.${plain} View video-mitm logs
————————————————
  ${green}9.${plain} Set video-mitm to start automatically at boot
 ${green}10.${plain} Disable video-mitm autostart
————————————————
 ${green}11.${plain} One-click install bbr (latest kernel)
 ${green}12.${plain} View video-mitm version 
 ${green}13.${plain} Upgrade maintenance script
 ${green}14.${plain} Generate CA Certificate
 "
 #后续更新可加入上方字符串中
    show_status
    echo && read -p "Please enter selection [0-13]: " num

    case "${num}" in
        0) config
        ;;
        1) check_uninstall && install
        ;;
        2) check_install && update
        ;;
        3) check_install && uninstall
        ;;
        4) check_install && start
        ;;
        5) check_install && stop
        ;;
        6) check_install && restart
        ;;
        7) check_install && status
        ;;
        8) check_install && show_log
        ;;
        9) check_install && enable
        ;;
        10) check_install && disable
        ;;
        11) install_bbr
        ;;
        12) check_install && show_Video-Mitm_version
        ;;
        13) update_shell
        ;;
        14) generate_ca
        ;;
        *) echo -e "${red}Please enter the correct number [0-12]${plain}"
        ;;
    esac
}


if [[ $# > 0 ]]; then
    case $1 in
        "start") check_install 0 && start 0
        ;;
        "stop") check_install 0 && stop 0
        ;;
        "restart") check_install 0 && restart 0
        ;;
        "status") check_install 0 && status 0
        ;;
        "enable") check_install 0 && enable 0
        ;;
        "disable") check_install 0 && disable 0
        ;;
        "log") check_install 0 && show_log 0
        ;;
        "update") check_install 0 && update 0 $2
        ;;
        "config") config $*
        ;;
        "install") check_uninstall 0 && install 0
        ;;
        "uninstall") check_install 0 && uninstall 0
        ;;
        "version") check_install 0 && show_Video_Mitm_version 0
        ;;
        "update_shell") update_shell
        ;;
        "genca") generate_ca
        ;;
        *) show_usage
    esac
else
    show_menu
fi