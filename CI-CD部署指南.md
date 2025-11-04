# GitHub CI/CD 自动部署指南

## 📋 方案说明

**工作流程：**
```
开发者提交代码
    ↓
GitHub 仓库接收
    ↓
GitHub Actions 自动触发
    ↓
构建项目（npm build）
    ↓
SSH 连接到服务器
    ↓
自动部署（Docker）
    ↓
网站自动更新
```

---

## 🚀 快速开始

### 第一步：服务器准备

```bash
cd /www/wwwroot/minilpa-web

# 运行设置脚本
chmod +x setup-cicd.sh
./setup-cicd.sh
```

脚本会自动：
- ✅ 安装 Git
- ✅ 初始化仓库
- ✅ 生成 SSH 密钥
- ✅ 配置 SSH 访问
- ✅ 显示需要的配置信息

---

### 第二步：创建 GitHub 仓库

1. **登录 GitHub**

2. **创建新仓库**
   - 仓库名：`minilpa-web`
   - 可见性：Private（推荐）或 Public
   - 不要初始化（README、.gitignore 等）

3. **复制仓库地址**
   ```
   https://github.com/your-username/minilpa-web.git
   ```

---

### 第三步：推送代码到 GitHub

```bash
cd /www/wwwroot/minilpa-web

# 配置 Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 添加远程仓库
git remote add origin https://github.com/your-username/minilpa-web.git

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: MiniLPA Web"

# 推送到 GitHub（第一次需要输入账号密码或 Token）
git push -u origin main
```

**如果提示需要 Token：**
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. 勾选 `repo` 权限
4. 复制 Token
5. 在推送时使用 Token 作为密码

---

### 第四步：配置 GitHub Secrets

1. **进入仓库设置**
   ```
   GitHub 仓库页面 → Settings → Secrets and variables → Actions
   ```

2. **点击 "New repository secret"**

3. **添加以下 4 个 Secrets：**

#### Secret 1: SERVER_HOST
```
Name: SERVER_HOST
Value: 你的服务器IP（如：123.456.789.0）
```

#### Secret 2: SERVER_USER
```
Name: SERVER_USER
Value: root
```

#### Secret 3: SERVER_PORT
```
Name: SERVER_PORT
Value: 22
```

#### Secret 4: SSH_PRIVATE_KEY
```
Name: SSH_PRIVATE_KEY
Value: 运行 setup-cicd.sh 后显示的私钥内容
       (完整复制 -----BEGIN... 到 ...END----- 的所有内容)
```

---

### 第五步：测试自动部署

```bash
cd /www/wwwroot/minilpa-web

# 修改一个文件（测试）
echo "# Test CI/CD" >> README.md

# 提交并推送
git add .
git commit -m "test: CI/CD deployment"
git push origin main
```

**查看部署进度：**
1. GitHub 仓库 → Actions 标签
2. 看到运行中的工作流
3. 点击查看详细日志
4. 等待 ✅ 成功标记

**约 5-10 分钟后，网站自动更新！**

---

## 📊 工作流说明

### 自动触发条件

- ✅ 推送到 `main` 或 `master` 分支
- ✅ 手动触发（Actions → Run workflow）

### 工作流步骤

1. **Checkout code** - 拉取代码
2. **Setup Node.js** - 配置环境
3. **Install dependencies** - 安装依赖
4. **Build project** - 构建项目
5. **Deploy to server** - 部署到服务器
   - SSH 连接
   - git pull
   - 运行部署脚本
6. **Deployment status** - 显示结果

---

## 🔧 配置文件说明

### `.github/workflows/deploy.yml`
- **主部署流程**
- 触发：推送到 main/master
- 操作：构建 + 部署

### `.github/workflows/test.yml`
- **测试流程**
- 触发：所有分支推送和 PR
- 操作：仅测试构建

---

## 💡 使用场景

### 场景 1：日常开发

```bash
# 修改代码
vim src/App.vue

# 提交并自动部署
git add .
git commit -m "feat: add new feature"
git push
```

### 场景 2：紧急修复

```bash
# 修复 bug
vim server/index.js

# 快速部署
git add .
git commit -m "fix: critical bug"
git push

# 等待自动部署（5-10分钟）
```

### 场景 3：多人协作

```bash
# A 开发者推送
git push origin main
→ 自动部署

# B 开发者推送
git push origin main
→ 自动部署（覆盖 A 的部署）
```

### 场景 4：回滚

```bash
# 查看历史提交
git log --oneline

# 回滚到之前的版本
git revert <commit-hash>
git push

# 自动部署旧版本
```

---

## 🛡️ 安全建议

### 1. 使用 Private 仓库
```
避免代码泄露
保护服务器配置
```

### 2. 定期更新 SSH 密钥
```bash
# 重新生成密钥
ssh-keygen -t rsa -b 4096 -f /root/.ssh/minilpa_deploy -N ""

# 更新 GitHub Secret
# 复制新的私钥到 SSH_PRIVATE_KEY
```

### 3. 限制 SSH 访问
```bash
# 只允许密钥登录
vi /etc/ssh/sshd_config
# 设置：PasswordAuthentication no
systemctl restart sshd
```

### 4. 使用环境变量
```
不要在代码中硬编码敏感信息
使用 GitHub Secrets 存储
```

---

## 🔍 故障排查

### 问题 1: 部署失败 "Permission denied"

**解决：**
```bash
# 检查 SSH 密钥
cat /root/.ssh/minilpa_deploy.pub
cat /root/.ssh/authorized_keys

# 确保公钥在 authorized_keys 中
```

### 问题 2: Git pull 失败

**解决：**
```bash
# 在服务器配置 Git
cd /www/wwwroot/minilpa-web
git config --global --add safe.directory /www/wwwroot/minilpa-web

# 或重新 clone
cd /www/wwwroot
rm -rf minilpa-web
git clone https://github.com/your-username/minilpa-web.git
```

### 问题 3: Docker 构建失败

**解决：**
```bash
# SSH 到服务器
docker system prune -f
docker build --no-cache -t minilpa-web .
```

### 问题 4: Actions 无法连接服务器

**检查：**
1. ✅ SERVER_HOST 是否正确
2. ✅ SERVER_PORT 是否开放
3. ✅ SSH_PRIVATE_KEY 是否完整
4. ✅ 服务器防火墙设置

---

## 📝 常用 Git 命令

```bash
# 查看状态
git status

# 查看日志
git log --oneline

# 查看差异
git diff

# 撤销修改
git checkout -- <file>

# 创建分支
git checkout -b feature-branch

# 合并分支
git checkout main
git merge feature-branch

# 标签（版本）
git tag v1.0.0
git push origin v1.0.0
```

---

## 🎯 进阶配置

### 添加测试环境

创建 `develop` 分支自动部署到测试服务器：

```yaml
# .github/workflows/deploy-test.yml
on:
  push:
    branches:
      - develop
```

### 添加通知

部署成功后发送通知到钉钉/企业微信：

```yaml
- name: Send notification
  uses: zcong1993/actions-ding@master
  with:
    dingToken: ${{ secrets.DING_TOKEN }}
    body: '部署成功！'
```

### 添加构建缓存

加速构建过程：

```yaml
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

---

## ✅ 验证清单

部署前确认：

- [ ] Git 已初始化
- [ ] GitHub 仓库已创建
- [ ] 代码已推送
- [ ] Secrets 已配置（4个）
- [ ] SSH 密钥已生成
- [ ] 工作流文件已提交
- [ ] 首次部署成功

---

## 📞 需要帮助？

如果遇到问题：

1. 查看 GitHub Actions 日志
2. SSH 到服务器查看日志
3. 检查网络和防火墙
4. 验证 Secrets 配置

---

**祝自动化部署顺利！** 🎉

