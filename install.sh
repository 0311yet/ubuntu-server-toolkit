#!/bin/bash

# Ubuntu Server Toolkit - 一键安装常用服务
# 适用于 Ubuntu Server 22.04 LTS

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 root 权限运行此脚本${NC}"
    echo "sudo bash $0"
    exit 1
fi

# 更新系统
update_system() {
    echo -e "${BLUE}正在更新系统...${NC}"
    apt update && apt upgrade -y
    echo -e "${GREEN}系统更新完成${NC}"
}

# 安装 Docker
install_docker() {
    echo -e "${BLUE}正在安装 Docker...${NC}"
    apt install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl start docker
    systemctl enable docker

    echo -e "${GREEN}Docker 安装完成${NC}"
    docker --version
}

# 安装 Docker Compose (独立版)
install_docker_compose() {
    echo -e "${BLUE}正在安装 Docker Compose...${NC}"
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo -e "${GREEN}Docker Compose 安装完成${NC}"
    docker-compose --version
}

# 安装 V2Ray
install_v2ray() {
    echo -e "${BLUE}正在安装 V2Ray...${NC}"
    bash <(curl -L https://raw.githubusercontent.com/233boy/v2ray/master/install.sh)

    echo -e "${GREEN}V2Ray 安装完成${NC}"
}

# 安装 Node.js (最新版)
install_nodejs() {
    echo -e "${BLUE}正在安装 Node.js...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt install -y nodejs

    echo -e "${GREEN}Node.js 安装完成${NC}"
    node --version
    npm --version
}

# 安装 OpenClaw
install_openclaw() {
    echo -e "${BLUE}正在安装 OpenClaw...${NC}"

    # 检查 Node.js 是否已安装
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}OpenClaw 需要 Node.js，正在安装...${NC}"
        install_nodejs
    fi

    # 使用 npm 全局安装 OpenClaw
    npm install -g openclaw

    echo -e "${GREEN}OpenClaw 安装完成${NC}"
    openclaw version
}

# 安装 Python
install_python() {
    echo -e "${BLUE}正在安装 Python...${NC}"
    apt install -y python3 python3-pip python3-venv

    echo -e "${GREEN}Python 安装完成${NC}"
    python3 --version
    pip3 --version
}

# 显示菜单
show_menu() {
    clear
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}   Ubuntu Server 22.04 LTS 工具箱${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo "请选择要安装的应用（支持多选，用空格分隔）："
    echo ""
    echo -e "${GREEN}[1]${NC} Docker"
    echo -e "${GREEN}[2]${NC} Docker Compose"
    echo -e "${GREEN}[3]${NC} V2Ray"
    echo -e "${GREEN}[4]${NC} Node.js (最新版)"
    echo -e "${GREEN}[5]${NC} OpenClaw"
    echo -e "${GREEN}[6]${NC} Python"
    echo ""
    echo -e "${YELLOW}[a]${NC} 安装全部"
    echo -e "${YELLOW}[q]${NC} 退出"
    echo ""
}

# 主函数
main() {
    show_menu

    while true; do
        read -p "请输入选择: " choice

        case $choice in
            1)
                update_system
                install_docker
                break
                ;;
            2)
                update_system
                install_docker_compose
                break
                ;;
            3)
                update_system
                install_v2ray
                break
                ;;
            4)
                update_system
                install_nodejs
                break
                ;;
            5)
                update_system
                install_openclaw
                break
                ;;
            6)
                update_system
                install_python
                break
                ;;
            a|A)
                update_system
                install_docker
                install_docker_compose
                install_v2ray
                install_nodejs
                install_openclaw
                install_python
                break
                ;;
            q|Q)
                echo -e "${YELLOW}已取消安装${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                ;;
        esac
    done

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}   安装完成！${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
}

# 运行主函数
main
