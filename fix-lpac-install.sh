#!/bin/bash

# 修复 lpac 安装 - 查找并安装编译好的文件

echo "=========================================="
echo "查找并安装 lpac"
echo "=========================================="
echo ""

# 进入构建目录
cd /tmp/lpac/build || {
    echo "❌ 构建目录不存在"
    exit 1
}

echo "1. 查找 lpac 可执行文件..."
echo ""

# 查找 lpac 文件
LPAC_FILE=$(find . -name "lpac" -type f -executable | head -1)

if [ -z "$LPAC_FILE" ]; then
    echo "尝试查找所有 lpac 文件..."
    find . -name "lpac" -type f
    echo ""
    echo "❌ 找不到 lpac 可执行文件"
    exit 1
fi

echo "✅ 找到 lpac: $LPAC_FILE"
ls -lh "$LPAC_FILE"
echo ""

# 安装
echo "2. 安装 lpac 到 /usr/local/bin..."
cp "$LPAC_FILE" /usr/local/bin/lpac
chmod +x /usr/local/bin/lpac
echo "✅ 安装完成"
echo ""

# 验证
echo "3. 验证安装..."
if command -v lpac &> /dev/null; then
    echo "✅ lpac 已成功安装"
    echo ""
    lpac --version 2>/dev/null || lpac -h 2>&1 | head -5 || echo "lpac 可执行"
else
    echo "❌ lpac 验证失败"
    exit 1
fi
echo ""

# 清理
echo "4. 清理临时文件..."
cd /tmp
rm -rf lpac
echo "✅ 完成"
echo ""

# 测试
echo "5. 测试 lpac..."
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
echo "lpac 位置: /usr/local/bin/lpac"
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

