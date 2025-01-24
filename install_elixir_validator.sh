#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 权限运行该脚本：sudo ./install_elixir_validator.sh"
  exit 1
fi

echo "=== 一键安装 Elixir Validator ==="

# 更新系统并安装 Docker
echo "1. 更新系统并安装 Docker..."
apt update && apt upgrade -y
apt install -y docker.io

# 启动并启用 Docker
systemctl start docker
systemctl enable docker

# 创建工作目录
WORK_DIR=~/elixir-validator
echo "2. 创建工作目录：$WORK_DIR"
mkdir -p $WORK_DIR
cd $WORK_DIR

# 交互输入 .env 文件内容
echo "3. 配置 Validator 环境变量："
read -p "请输入显示名称 (STRATEGY_EXECUTOR_DISPLAY_NAME): " DISPLAY_NAME
read -p "请输入接收奖励的钱包地址 (STRATEGY_EXECUTOR_BENEFICIARY): " BENEFICIARY
read -p "请输入私钥 (SIGNER_PRIVATE_KEY - 不包含 0x): " PRIVATE_KEY

# 创建 .env 文件
echo "4. 创建 .env 文件..."
cat > validator.env <<EOF
STRATEGY_EXECUTOR_DISPLAY_NAME=$DISPLAY_NAME
STRATEGY_EXECUTOR_BENEFICIARY=$BENEFICIARY
SIGNER_PRIVATE_KEY=$PRIVATE_KEY
EOF

echo ".env 文件内容如下："
cat validator.env

# 拉取 Docker 镜像
echo "5. 拉取 Elixir Validator Docker 镜像..."
docker pull elixirprotocol/validator

# 启动容器
echo "6. 启动 Elixir Validator 容器..."
docker run -d \
  --env-file $WORK_DIR/validator.env \
  --name elixir \
  -p 17690:17690 \
  --restart unless-stopped \
  elixirprotocol/validator

# 检查容器运行状态
echo "7. 验证容器运行状态..."
docker ps

echo "=== 安装完成！ ==="
echo "您可以通过以下命令查看日志：docker logs elixir"
echo "如果启用了健康检查端口，可访问：http://<您的VPS_IP>:17690/metrics"
