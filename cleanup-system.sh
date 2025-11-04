#!/bin/bash

# 系统清理脚本 - 释放磁盘和内存

echo "=========================================="
echo "系统资源清理"
echo "=========================================="
echo ""

echo "当前资源使用情况："
echo "----------------------------------------"
df -h / | grep -v Filesystem
free -h | grep Mem
echo ""

# 1. 清理 yum 缓存
echo "1. 清理 yum 缓存..."
yum clean all
rm -rf /var/cache/yum
echo "✅ 完成"
echo ""

# 2. 清理 Docker（如果有）
echo "2. 清理 Docker 资源..."
if command -v docker &> /dev/null; then
    docker system prune -af --volumes || true
    echo "✅ 完成"
else
    echo "Docker 未安装，跳过"
fi
echo ""

# 3. 清理系统日志
echo "3. 清理旧日志..."
journalctl --vacuum-time=7d
find /var/log -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
echo "✅ 完成"
echo ""

# 4. 清理临时文件
echo "4. 清理临时文件..."
rm -rf /tmp/*
rm -rf /var/tmp/*
echo "✅ 完成"
echo ""

# 5. 清理编译缓存
echo "5. 清理编译缓存..."
rm -rf /tmp/lpac
rm -rf /tmp/cmake*
echo "✅ 完成"
echo ""

# 6. 释放内存缓存
echo "6. 释放内存缓存..."
sync
echo 3 > /proc/sys/vm/drop_caches
echo "✅ 完成"
echo ""

echo "=========================================="
echo "清理完成！"
echo "=========================================="
echo ""
echo "清理后资源："
echo "----------------------------------------"
df -h / | grep -v Filesystem
free -h | grep Mem
echo ""

