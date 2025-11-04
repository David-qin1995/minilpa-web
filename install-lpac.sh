#!/bin/bash

# lpac 安装脚本 - 从源码编译

set -e

echo "=========================================="
echo "安装 lpac - eSIM LPA 工具"
echo "=========================================="
echo ""

# 1. 安装编译依赖
echo "1. 安装编译依赖..."
yum groupinstall -y "Development Tools" 2>&1 | grep -v "already installed" || true
yum install -y git cmake curl-devel pcsclite-devel 2>&1 | grep -v "already installed" || true
echo "✅ 完成"
echo ""

# 2. 克隆 lpac 仓库
echo "2. 下载 lpac 源码..."
cd /tmp
rm -rf lpac
git clone https://github.com/estkme-group/lpac.git
cd lpac
echo "✅ 完成"
echo ""

# 3. 编译
echo "3. 编译 lpac（需要几分钟）..."
mkdir -p build
cd build

# 使用新版 CMake（如果已安装）
if [ -f "/opt/cmake/bin/cmake" ]; then
    echo "使用新版 CMake..."
    /opt/cmake/bin/cmake .. || {
        echo "❌ CMake 配置失败"
        exit 1
    }
else
    cmake .. || {
        echo "❌ CMake 配置失败"
        echo ""
        echo "您的 CMake 版本太旧，需要 3.23 或更高版本"
        echo "请先运行: ./upgrade-cmake.sh"
        exit 1
    }
fi
make || {
    echo "❌ 编译失败"
    exit 1
}
echo "✅ 编译完成"
echo ""

# 4. 安装
echo "4. 安装 lpac..."
# 复制到系统目录
cp lpac /usr/local/bin/lpac
chmod +x /usr/local/bin/lpac

# 或者使用 make install
# make install

echo "✅ 安装完成"
echo ""

# 5. 验证安装
echo "5. 验证安装..."
if command -v lpac &> /dev/null; then
    echo "✅ lpac 已成功安装"
    echo ""
    lpac --version || lpac -h || echo "lpac 安装成功"
else
    echo "❌ lpac 安装失败"
    exit 1
fi
echo ""

# 6. 测试（如果有读卡器）
echo "6. 测试 lpac..."
echo "尝试读取芯片信息（如果没有读卡器会失败，这是正常的）..."
echo ""
if timeout 10 lpac chip info 2>&1; then
    echo ""
    echo "✅ lpac 工作正常！"
else
    echo ""
    echo "⚠️  无法读取芯片（可能是读卡器未插入或 eSIM 卡未插入）"
    echo "这是正常的，等读卡器到货后再测试"
fi
echo ""

# 清理
echo "7. 清理临时文件..."
cd /tmp
rm -rf lpac
echo "✅ 完成"
echo ""

echo "=========================================="
echo "🎉 lpac 安装完成！"
echo "=========================================="
echo ""
echo "lpac 位置: /usr/local/bin/lpac"
echo ""
echo "常用命令："
echo "  lpac chip info            # 查看芯片信息"
echo "  lpac profile list         # 列出配置文件"
echo "  lpac profile download -a <激活码>  # 下载配置"
echo "  lpac --help               # 查看帮助"
echo ""
echo "下一步："
echo "1. 插入读卡器和 eSIM 卡"
echo "2. 运行: lpac chip info"
echo "3. 如果成功，运行: cd /www/wwwroot/minilpa-web && ./deploy-hardware.sh"
echo ""
echo "=========================================="

