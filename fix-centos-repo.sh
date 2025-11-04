#!/bin/bash

# 修复 CentOS 7 镜像源问题

echo "=========================================="
echo "修复 CentOS 7 镜像源"
echo "=========================================="
echo ""
echo "CentOS 7 已停止维护，需要切换到 vault 镜像源"
echo ""

# 1. 备份原有源
echo "1. 备份原有源..."
mkdir -p /etc/yum.repos.d/backup
cp /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ 2>/dev/null || true
echo "✅ 完成"
echo ""

# 2. 替换为 vault 镜像源
echo "2. 替换为 vault 镜像源..."

cat > /etc/yum.repos.d/CentOS-Base.repo << 'EOF'
[base]
name=CentOS-$releasever - Base
baseurl=https://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates
baseurl=https://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras
baseurl=https://vault.centos.org/7.9.2009/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://vault.centos.org/7.9.2009/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

cat > /etc/yum.repos.d/CentOS-SCLo-scl.repo << 'EOF'
[centos-sclo-sclo]
name=CentOS-7 - SCLo sclo
baseurl=https://vault.centos.org/7.9.2009/sclo/$basearch/sclo/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
EOF

cat > /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo << 'EOF'
[centos-sclo-rh]
name=CentOS-7 - SCLo rh
baseurl=https://vault.centos.org/7.9.2009/sclo/$basearch/rh/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
EOF

echo "✅ 完成"
echo ""

# 3. 清理缓存
echo "3. 清理 yum 缓存..."
yum clean all
echo "✅ 完成"
echo ""

# 4. 重建缓存
echo "4. 重建 yum 缓存..."
yum makecache
echo "✅ 完成"
echo ""

# 5. 测试
echo "5. 测试镜像源..."
if yum repolist 2>&1 | grep -q "repolist:"; then
    echo "✅ 镜像源配置成功"
    echo ""
    yum repolist
else
    echo "❌ 镜像源配置可能有问题"
fi
echo ""

echo "=========================================="
echo "🎉 修复完成！"
echo "=========================================="
echo ""
echo "现在可以正常使用 yum 安装软件了"
echo ""

