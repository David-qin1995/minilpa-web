#!/bin/bash

# 升级 CMake 到最新版本

set -e

echo "=========================================="
echo "升级 CMake"
echo "=========================================="
echo ""

# 检查当前版本
echo "当前 CMake 版本："
cmake --version 2>/dev/null || echo "未安装或版本太旧"
echo ""

# 1. 卸载旧版本
echo "1. 卸载旧版本 CMake..."
yum remove -y cmake 2>/dev/null || true
echo "✅ 完成"
echo ""

# 2. 下载最新版本的 CMake
echo "2. 下载 CMake 3.27..."
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.tar.gz || {
    echo "下载失败，尝试备用链接..."
    wget https://cmake.org/files/v3.27/cmake-3.27.9-linux-x86_64.tar.gz
}
echo "✅ 完成"
echo ""

# 3. 解压
echo "3. 解压..."
tar -zxf cmake-3.27.9-linux-x86_64.tar.gz
echo "✅ 完成"
echo ""

# 4. 移动到系统目录
echo "4. 安装到系统..."
rm -rf /opt/cmake
mv cmake-3.27.9-linux-x86_64 /opt/cmake
echo "✅ 完成"
echo ""

# 5. 创建软链接
echo "5. 创建软链接..."
ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake
ln -sf /opt/cmake/bin/ctest /usr/local/bin/ctest
ln -sf /opt/cmake/bin/cpack /usr/local/bin/cpack
echo "✅ 完成"
echo ""

# 6. 验证
echo "6. 验证安装..."
export PATH=/opt/cmake/bin:$PATH
cmake --version
echo "✅ 完成"
echo ""

# 7. 清理
echo "7. 清理临时文件..."
cd /tmp
rm -f cmake-3.27.9-linux-x86_64.tar.gz
echo "✅ 完成"
echo ""

echo "=========================================="
echo "🎉 CMake 升级完成！"
echo "=========================================="
echo ""
echo "新版本："
/opt/cmake/bin/cmake --version
echo ""
echo "重要：请重新加载环境变量"
echo "  export PATH=/opt/cmake/bin:\$PATH"
echo ""
echo "或者重新登录 SSH"
echo ""
echo "=========================================="

