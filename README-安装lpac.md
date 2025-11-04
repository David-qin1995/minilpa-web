# lpac 安装指南 - CentOS 7

## 问题说明

在 CentOS 7 上安装 lpac 需要解决两个主要问题：

1. **CMake 版本太旧**：默认 2.8.12，需要 3.23+
2. **GCC 版本太旧**：默认 4.8.5，不支持 C11 的 `_Generic` 特性

## ⚡ 一键安装（推荐）

```bash
cd /www/wwwroot/minilpa-web
chmod +x install-lpac-gcc.sh
./install-lpac-gcc.sh
```

这个脚本会自动：
- ✅ 升级 GCC 到 7.3（通过 devtoolset-7）
- ✅ 升级 CMake 到 3.27
- ✅ 安装编译依赖
- ✅ 下载并编译 lpac
- ✅ 安装到系统
- ✅ 验证和清理

**需要时间：约 10-15 分钟**

---

## 📋 手动安装步骤

如果想手动操作，按以下步骤：

### 1. 升级 GCC

```bash
# 安装 SCL
yum install -y centos-release-scl

# 安装 devtoolset-7（GCC 7.3）
yum install -y devtoolset-7

# 启用新版 GCC
source /opt/rh/devtoolset-7/enable

# 验证
gcc --version
# 应该显示：gcc (GCC) 7.3.1
```

### 2. 升级 CMake

```bash
# 下载
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.tar.gz

# 解压和安装
tar -zxf cmake-3.27.9-linux-x86_64.tar.gz
rm -rf /opt/cmake
mv cmake-3.27.9-linux-x86_64 /opt/cmake
ln -sf /opt/cmake/bin/cmake /usr/local/bin/cmake

# 验证
cmake --version
# 应该显示：cmake version 3.27.9
```

### 3. 安装依赖

```bash
yum install -y git curl-devel pcsclite-devel
```

### 4. 编译 lpac

```bash
# 启用新版工具
source /opt/rh/devtoolset-7/enable
export PATH=/opt/cmake/bin:$PATH

# 下载源码
cd /tmp
git clone https://github.com/estkme-group/lpac.git
cd lpac

# 编译
mkdir build && cd build
cmake ..
make

# 安装
cp lpac /usr/local/bin/lpac
chmod +x /usr/local/bin/lpac

# 验证
lpac --version
```

### 5. 清理

```bash
cd /tmp
rm -rf lpac cmake-3.27.9-linux-x86_64.tar.gz
```

---

## ✅ 验证安装

```bash
# 查看版本
lpac --version

# 查看帮助
lpac -h

# 如果有读卡器，测试
lpac chip info
```

---

## 🔧 常见问题

### Q1: 编译时提示 CMake 版本太旧

**A:** 运行 `./upgrade-cmake.sh` 或使用 `./install-lpac-gcc.sh`

### Q2: 编译时出现 `_Generic` 错误

**A:** GCC 版本太旧，运行 `./install-lpac-gcc.sh` 会自动升级

### Q3: 安装 devtoolset 失败

**A:** 
```bash
# 先安装 SCL
yum install -y centos-release-scl

# 更新 yum 缓存
yum clean all
yum makecache

# 重试安装
yum install -y devtoolset-7
```

### Q4: 以后如何使用新版 GCC？

**A:** 每次需要编译时，先执行：
```bash
source /opt/rh/devtoolset-7/enable
```

或者永久添加到 `~/.bashrc`：
```bash
echo 'source /opt/rh/devtoolset-7/enable' >> ~/.bashrc
source ~/.bashrc
```

---

## 📦 已安装的组件

安装完成后，您将拥有：

| 组件 | 位置 | 版本 |
|------|------|------|
| GCC | /opt/rh/devtoolset-7 | 7.3.1 |
| CMake | /opt/cmake | 3.27.9 |
| lpac | /usr/local/bin/lpac | 最新版 |

---

## 🚀 下一步

lpac 安装完成后：

1. **插入读卡器和 eSIM 卡**

2. **测试硬件**：
   ```bash
   lpac chip info
   ```

3. **部署硬件版本**：
   ```bash
   cd /www/wwwroot/minilpa-web
   ./deploy-hardware.sh
   ```

---

## 📚 参考资源

- **lpac 项目**：https://github.com/estkme-group/lpac
- **devtoolset 文档**：https://www.softwarecollections.org/en/scls/rhscl/devtoolset-7/
- **CMake 下载**：https://cmake.org/download/

---

**祝安装顺利！** 🎉

