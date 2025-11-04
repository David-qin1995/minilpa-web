#!/bin/bash

# lpac 完整安装脚本 - 包含 CMake 和 GCC 升级

set -e

echo "=========================================="
echo "完整安装 lpac（升级 CMake + GCC）"
echo "=========================================="
echo ""

# =======================================
# 步骤 1: 升级 GCC
# =======================================
echo "步骤 1: 升级 GCC"
echo "----------------------------------------"
echo "CentOS 7 默认的 GCC 4.8.5 太旧，需要升级到 GCC 7+"
echo ""

# 检查当前 GCC 版本
GCC_VERSION=$(gcc --version 2>/dev/null | head -1 || echo "GCC not found")
echo "当前 GCC: $GCC_VERSION"
echo ""

# 安装 SCL (Software Collections)
echo "安装 SCL..."
yum install -y centos-release-scl 2>&1 | grep -v "already installed" || true

# 安装 devtoolset-7 (GCC 7.3)
echo "安装 devtoolset-7（GCC 7.3）..."
yum install -y devtoolset-7 2>&1 | grep -v "already installed" || true

echo "✅ GCC 7.3 安装完成"
echo ""

# 启用 devtoolset-7
echo "启用 devtoolset-7..."
source /opt/rh/devtoolset-7/enable

# 验证 GCC 版本
echo "新 GCC 版本："
gcc --version | head -1
echo ""

# =======================================
# 步骤 2: 升级 CMake
# =======================================
echo "步骤 2: 升级 CMake"
echo "----------------------------------------"

# 检查 CMake 版本
CMAKE_VERSION=$(cmake --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' | head -1 || echo "0.0")
CMAKE_MAJOR=$(echo $CMAKE_VERSION | cut -d. -f1)
CMAKE_MINOR=$(echo $CMAKE_VERSION | cut -d. -f2)

echo "当前 CMake 版本: $CMAKE_VERSION"
echo ""

# 如果版本低于 3.23，升级
if [ "$CMAKE_MAJOR" -lt 3 ] || ([ "$CMAKE_MAJOR" -eq 3 ] && [ "$CMAKE_MINOR" -lt 23 ]); then
    echo "升级 CMake..."
    
    # 卸载旧版本
    yum remove -y cmake 2>/dev/null || true
    
    # 下载新版本
    cd /tmp
    echo "下载 CMake 3.27.9..."
    wget -q --tries=3 https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.tar.gz || {
        echo "从 GitHub 下载失败，尝试官方镜像..."
        wget -q https://cmake.org/files/v3.27/cmake-3.27.9-linux-x86_64.tar.gz
    }
    
    # 解压和安装
    tar -zxf cmake-3.27.9-linux-x86_64.tar.gz
    rm -rf /opt/cmake
    mv cmake-3.27.9-linux-x86_64 /opt/cmake
    
    # 创建软链接
    ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake
    
    # 清理
    rm -f cmake-3.27.9-linux-x86_64.tar.gz
    
    echo "✅ CMake 升级完成"
else
    echo "✅ CMake 版本满足要求"
fi

/opt/cmake/bin/cmake --version | head -1
echo ""

# =======================================
# 步骤 3: 安装编译依赖
# =======================================
echo "步骤 3: 安装编译依赖"
echo "----------------------------------------"
yum install -y git curl-devel pcsclite-devel 2>&1 | grep -v "already installed" || true
echo "✅ 完成"
echo ""

# =======================================
# 步骤 4: 下载 lpac 源码
# =======================================
echo "步骤 4: 下载 lpac 源码"
echo "----------------------------------------"
cd /tmp
rm -rf lpac
git clone https://github.com/estkme-group/lpac.git
cd lpac
echo "✅ 完成"
echo ""

# =======================================
# 步骤 5: 编译 lpac
# =======================================
echo "步骤 5: 编译 lpac（需要几分钟）"
echo "----------------------------------------"

# 确保使用新版工具
export PATH=/opt/cmake/bin:$PATH
source /opt/rh/devtoolset-7/enable

mkdir -p build
cd build

echo "使用工具版本："
echo "  GCC: $(gcc --version | head -1)"
echo "  CMake: $(cmake --version | head -1)"
echo ""

# 配置
/opt/cmake/bin/cmake .. || {
    echo "❌ CMake 配置失败"
    exit 1
}

# 编译
make || {
    echo "❌ 编译失败"
    exit 1
}

echo "✅ 编译完成"
echo ""

# =======================================
# 步骤 6: 安装
# =======================================
echo "步骤 6: 安装 lpac"
echo "----------------------------------------"
cp lpac /usr/local/bin/lpac
chmod +x /usr/local/bin/lpac
echo "✅ 安装完成"
echo ""

# =======================================
# 步骤 7: 验证
# =======================================
echo "步骤 7: 验证安装"
echo "----------------------------------------"
if command -v lpac &> /dev/null; then
    echo "✅ lpac 已成功安装"
    echo ""
    lpac --version 2>/dev/null || lpac -h 2>&1 | head -5 || echo "lpac 可执行"
else
    echo "❌ lpac 安装失败"
    exit 1
fi
echo ""

# =======================================
# 步骤 8: 清理
# =======================================
echo "步骤 8: 清理临时文件"
echo "----------------------------------------"
cd /tmp
rm -rf lpac
echo "✅ 完成"
echo ""

# =======================================
# 步骤 9: 测试
# =======================================
echo "步骤 9: 测试 lpac"
echo "----------------------------------------"
echo "尝试读取芯片信息..."
if timeout 10 lpac chip info 2>&1; then
    echo ""
    echo "✅ lpac 工作正常！"
else
    echo ""
    echo "⚠️  无法读取芯片（读卡器未插入或 eSIM 卡未插入）"
    echo "这是正常的，等读卡器到货后再测试"
fi
echo ""

echo "=========================================="
echo "🎉 安装完成！"
echo "=========================================="
echo ""
echo "安装信息："
echo "  GCC:   devtoolset-7 (GCC 7.3)"
echo "  CMake: /opt/cmake/bin/cmake"
echo "  lpac:  /usr/local/bin/lpac"
echo ""
echo "重要提示："
echo "  如果需要重新编译 lpac 或其他 C 程序，请先执行："
echo "  source /opt/rh/devtoolset-7/enable"
echo ""
echo "常用命令："
echo "  lpac chip info              # 查看芯片信息"
echo "  lpac profile list           # 列出配置文件"
echo "  lpac profile download -a <激活码>  # 下载配置"
echo ""
echo "下一步："
echo "1. 插入读卡器和 eSIM 卡"
echo "2. 运行: lpac chip info"
echo "3. 部署硬件版本: cd /www/wwwroot/minilpa-web && ./deploy-hardware.sh"
echo ""
echo "=========================================="

