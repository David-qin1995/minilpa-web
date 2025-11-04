#!/bin/bash

# 修复 PCSC 服务配置

echo "=========================================="
echo "修复 PCSC 服务配置"
echo "=========================================="
echo ""

# 1. 创建缺失的目录
echo "1. 创建 PID 文件目录..."
mkdir -p /var/run/pcscd
chmod 755 /var/run/pcscd
echo "✅ 完成"
echo ""

# 2. 重启 PCSC 服务
echo "2. 重启 PCSC 服务..."
systemctl stop pcscd
sleep 1
systemctl start pcscd
echo "✅ 完成"
echo ""

# 3. 检查服务状态
echo "3. 检查服务状态..."
if systemctl is-active --quiet pcscd; then
    echo "✅ PCSC 服务运行正常"
    systemctl status pcscd | head -10
else
    echo "❌ PCSC 服务未运行"
    systemctl status pcscd
    exit 1
fi
echo ""

# 4. 检查 PID 文件
echo "4. 检查 PID 文件..."
if [ -f "/var/run/pcscd/pcscd.pid" ]; then
    echo "✅ PID 文件已创建"
    cat /var/run/pcscd/pcscd.pid
else
    echo "⚠️  PID 文件不存在（但服务可能正常运行）"
fi
echo ""

# 5. 扫描读卡器
echo "5. 扫描读卡器..."
echo "（如果读卡器未插入，会显示无读卡器）"
echo ""
timeout 5 pcsc_scan -n 2>&1 || echo "扫描完成"
echo ""

echo "=========================================="
echo "修复完成！"
echo "=========================================="
echo ""
echo "如果插入了读卡器，可以测试："
echo "  pcsc_scan          # 扫描读卡器"
echo "  lpac chip info     # 读取芯片信息（需要先安装 lpac）"
echo ""
echo "=========================================="

