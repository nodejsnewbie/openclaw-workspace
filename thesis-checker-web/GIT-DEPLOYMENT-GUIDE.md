# 🚀 使用 Git 部署到腾讯云轻量应用服务器

## 前提条件

1. ✅ 已安装 Git
2. ✅ 已拥有 Git 仓库（Gitee、GitHub、GitLab 等）
3. ✅ 服务器已安装 Docker

---

## 步骤 1：初始化 Git 仓库并推送代码

### 在本地 Windows 系统执行：

```bash
# 打开 Git Bash 或 PowerShell
cd e:/repo/openclaw-workspace/thesis-checker-web

# 初始化 Git 仓库
git init

# 添加 .gitignore（如果还没有）
cat > .gitignore << 'EOF'
# Node modules
node_modules/
npm-debug.log
yarn-error.log

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/

# 环境变量文件
.env
.env.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# 日志文件
*.log
logs/

# 数据库文件
*.db
*.sqlite

# 上传文件
backend/uploads/*
!backend/uploads/.gitkeep

# 生成的报告
backend/reports/*
!backend/reports/.gitkeep

# Docker volumes
mongodb_data/
EOF

# 添加所有文件到暂存区
git add .

# 提交代码
git commit -m "Initial commit: 毕业论文检查系统"

# 添加远程仓库（替换为您的仓库地址）
# 例如 Gitee：
git remote add origin https://gitee.com/your-username/thesis-checker-web.git

# 推送代码
git branch -M main
git push -u origin main
```

---

## 步骤 2：在服务器上克隆项目并部署

### 通过 SSH 连接到服务器：

```bash
ssh root@***.***.***.***
```

### 在服务器上执行：

```bash
# 安装 Git（如果没有）
yum install -y git

# 克隆项目
cd /root/projects
git clone https://gitee.com/your-username/thesis-checker-web.git
cd thesis-checker-web

# 启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

---

## 步骤 3：创建自动化部署脚本

### 在服务器上创建快速部署脚本：

```bash
# 创建部署脚本
cat > /root/update-thesis-checker.sh << 'EOF'
#!/bin/bash

# 毕业论文检查系统 - 快速更新脚本

echo "🔄 开始更新毕业论文检查系统..."

# 进入项目目录
cd /root/projects/thesis-checker-web

# 拉取最新代码
echo "📥 拉取最新代码..."
git pull origin main

# 重启服务
echo "🔄 重启服务..."
docker-compose down
docker-compose up -d --build

# 查看服务状态
echo "📊 服务状态："
docker-compose ps

echo "✅ 更新完成！"
echo ""
echo "🌐 访问地址："
echo "  - 前端：http://***.***.***.***:8000"
echo "  - API文档：http://***.***.***.***:8000/docs"
EOF

# 添加执行权限
chmod +x /root/update-thesis-checker.sh
```

### 使用方法：

```bash
# 每次更新代码后，只需在服务器上执行：
/root/update-thesis-checker.sh
```

---

## 步骤 4：创建本地快速推送脚本

### 在本地 Windows 创建推送脚本（deploy.bat）：

```batch
@echo off
chcp 65001 > nul
echo ========================================
echo   毕业论文检查系统 - 快速推送脚本
echo ========================================
echo.

echo [1/4] 添加文件到暂存区...
git add .

echo.
echo [2/4] 提交代码...
set /p message="请输入提交信息: "
git commit -m "%message%"

echo.
echo [3/4] 推送到远程仓库...
git push origin main

echo.
echo [4/4] 提示更新服务器...
echo ✅ 代码已推送！
echo.
echo 请在服务器上执行更新脚本：
echo ssh root@***.***.***.*** "/root/update-thesis-checker.sh"
echo.

pause
```

---

## 完整的自动化部署方案（本地 + 服务器）

### 本地脚本（deploy-all.bat）：

```batch
@echo off
chcp 65001 > nul
echo ========================================
echo   毕业论文检查系统 - 一键部署
echo ========================================
echo.

echo [1/5] 添加文件到暂存区...
git add .

echo.
echo [2/5] 提交代码...
set /p message="请输入提交信息: "
git commit -m "%message%"

echo.
echo [3/5] 推送到远程仓库...
git push origin main

echo.
echo [4/5] 通知服务器更新...
echo 正在通知服务器更新代码...
plink -batch root@***.***.***.*** "/root/update-thesis-checker.sh"

echo.
echo [5/5] 验证部署状态...
echo 服务状态：
plink -batch root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose ps"

echo.
echo ========================================
echo   ✅ 部署完成！
echo ========================================
echo.
echo 🌐 访问地址：
echo   - 前端：http://***.***.***.***:8000
echo   - API文档：http://***.***.***.***:8000/docs
echo.

pause
```

---

## 常用 Git 命令

### 本地命令：

```bash
# 查看状态
git status

# 查看修改内容
git diff

# 查看提交历史
git log --oneline

# 撤销修改
git checkout -- file.txt

# 回退到上一个版本
git reset --hard HEAD^

# 创建新分支
git checkout -b feature/new-feature

# 合并分支
git merge feature/new-feature
```

### 服务器命令：

```bash
# 拉取最新代码
git pull origin main

# 查看远程仓库
git remote -v

# 更新远程仓库地址
git remote set-url origin https://new-url.git
```

---

## 部署检查清单

部署前确认：
- [ ] 前端已构建（frontend/dist 目录存在）
- [ ] 后端依赖文件完整（requirements.txt）
- [ ] Dockerfile 配置正确
- [ ] docker-compose.yml 配置正确
- [ ] Git 仓库已推送到远程

部署后验证：
- [ ] MongoDB 容器运行正常
- [ ] 后端服务运行正常
- [ ] 前端页面可以访问
- [ ] API 文档可以访问
- [ ] 数据库连接正常

---

## 故障排查

### 1. Git 推送失败

```bash
# 检查远程仓库配置
git remote -v

# 重新配置远程仓库
git remote set-url origin https://correct-url.git

# 强制推送（谨慎使用）
git push -f origin main
```

### 2. 服务器拉取失败

```bash
# 检查服务器上的 Git 配置
git config --list

# 清除凭据缓存
git credential-manager uninstall

# 重新拉取
git pull origin main
```

### 3. Docker 容器启动失败

```bash
# 查看容器日志
docker logs thesis-checker-backend
docker logs thesis-checker-mongodb

# 重新构建镜像
docker-compose up -d --build

# 清理并重启
docker-compose down
docker system prune -f
docker-compose up -d
```

---

## 下一步

1. ✅ 在本地初始化 Git 仓库
2. ✅ 将代码推送到远程仓库
3. ✅ 在服务器上克隆项目
4. ✅ 使用 Docker Compose 启动服务
5. ✅ 配置自动化部署脚本

需要我帮您创建具体的脚本文件吗？
