#!/bin/bash

# 完整安装 lpac（包括升级 CMake）

set -e

echo "=========================================="
echo "完整安装 lpac"
echo "=========================================="
echo ""

# 检查 CMake 版本
CMAKE_VERSION=$(cmake --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' | head -1 || echo "0.0")
CMAKE_MAJOR=$(echo $CMAKE_VERSION | cut -d. -f1)
CMAKE_MINOR=$(echo $CMAKE_VERSION | cut -d. -f2)

echo "当前 CMake 版本: $CMAKE_VERSION"
echo ""

# 如果版本低于 3.23，先升级
if [ "$CMAKE_MAJOR" -lt 3 ] || ([ "$CMAKE_MAJOR" -eq 3 ] && [ "$CMAKE_MINOR" -lt 23 ]); then
    echo "⚠️  CMake 版本太旧，需要升级..."
    echo ""
    
    # 1. 升级 CMake
    echo "步骤 1: 升级 CMake"
    echo "----------------------------------------"
    
    # 卸载旧版本
    yum remove -y cmake 2>/dev/null || true
    
    # 下载新版本
    cd /tmp
    echo "下载 CMake 3.27.9..."
    wget -q https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.tar.gz || {
        echo "从 GitHub 下载失败，尝试官方镜像..."
        wget -q https://cmake.org/files/v3.27/cmake-3.27.9-linux-x86_64.tar.gz
    }
    
    # 解压和安装
    tar -zxf cmake-3.27.9-linux-x86_64.tar.gz
    rm -rf /opt/cmake
    mv cmake-3.27.9-linux-x86_64 /opt/cmake
    
    # 创建软链接
    ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake
    ln -sf /opt/cmake/bin/ctest /usr/local/bin/ctest
    ln -sf /opt/cmake/bin/cpack /usr/local/bin/cpack
    
    # 更新 PATH
    export PATH=/opt/cmake/bin:$PATH
    
    # 清理
    rm -f cmake-3.27.9-linux-x86_64.tar.gz
    
    echo "✅ CMake 升级完成"
    /opt/cmake/bin/cmake --version
    echo ""
else
    echo "✅ CMake 版本满足要求"
    echo ""
fi

# 2. 安装编译依赖
echo "步骤 2: 安装编译依赖"
echo "----------------------------------------"
yum groupinstall -y "Development Tools" 2>&1 | grep -v "already installed" || true
yum install -y git curl-devel pcsclite-devel 2>&1 | grep -v "already installed" || true
echo "✅ 完成"
echo ""

# 3. 下载 lpac 源码
echo "步骤 3: 下载 lpac 源码"
echo "----------------------------------------"
cd /tmp
rm -rf lpac
git clone https://github.com/estkme-group/lpac.git
cd lpac
echo "✅ 完成"
echo ""

# 4. 编译 lpac
echo "步骤 4: 编译 lpac（需要几分钟）"
echo "----------------------------------------"
mkdir -p build
cd build

# 使用新版 CMake
if [ -f "/opt/cmake/bin/cmake" ]; then
    /opt/cmake/bin/cmake ..
else
    cmake ..
fi

make
echo "✅ 编译完成"
echo ""

# 5. 安装
echo "步骤 5: 安装 lpac"
echo "----------------------------------------"
cp lpac /usr/local/bin/lpac
chmod +x /usr/local/bin/lpac
echo "✅ 安装完成"
echo ""

# 6. 验证
echo "步骤 6: 验证安装"
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

# 7. 清理
echo "步骤 7: 清理临时文件"
echo "----------------------------------------"
cd /tmp
rm -rf lpac
echo "✅ 完成"
echo ""

# 8. 测试（如果有读卡器）
echo "步骤 8: 测试 lpac"
echo "----------------------------------------"
echo "尝试读取芯片信息（如果没有读卡器会失败）..."
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
echo "  CMake: /opt/cmake/bin/cmake"
echo "  lpac:  /usr/local/bin/lpac"
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

