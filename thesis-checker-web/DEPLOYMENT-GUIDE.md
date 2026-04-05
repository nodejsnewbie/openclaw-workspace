# 🚀 毕业论文检查系统 - 云服务器部署指南

## 服务器信息
- **公网IP**: ***.***.***.***
- **用户**: root
- **系统**: OpenCloudOS (Linux)
- **Docker**: 已安装

---

## 快速部署步骤

### 方法1：使用 SCP 上传（推荐）

#### 步骤1：打开 Git Bash，执行上传命令

```bash
# 上传整个项目到服务器
scp -r /e/repo/openclaw-workspace/thesis-checker-web root@***.***.***.***:/root/projects/
```

#### 步骤2：SSH 连接到服务器

```bash
ssh root@***.***.***.***
```

#### 步骤3：在服务器上创建并执行部署脚本

```bash
# 创建部署脚本
cat > /root/update-thesis-checker.sh << 'EOF'
#!/bin/bash
set -e
cd /root/projects/thesis-checker-web
echo "停止旧容器..."
docker-compose down
echo "构建并启动服务..."
docker-compose up -d --build
echo "等待服务启动..."
sleep 15
echo "服务状态："
docker-compose ps
echo "最新日志："
docker-compose logs --tail=30
echo "✅ 部署完成！"
echo "访问地址：http://***.***.***.***:8000"
EOF

# 添加执行权限
chmod +x /root/update-thesis-checker.sh

# 执行部署
/root/update-thesis-checker.sh
```

---

### 方法2：使用 Git 部署

#### 步骤1：在本地初始化 Git 仓库

```bash
cd e:/repo/openclaw-workspace/thesis-checker-web
git init
git add .
git commit -m "Initial commit"
```

#### 步骤2：推送到远程仓库

```bash
# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://gitee.com/your-username/thesis-checker-web.git
git push -u origin main
```

#### 步骤3：在服务器上克隆并部署

```bash
# SSH 连接到服务器
ssh root@***.***.***.***

# 克隆项目
cd /root/projects
git clone https://gitee.com/your-username/thesis-checker-web.git
cd thesis-checker-web

# 启动服务
docker-compose up -d --build

# 查看服务状态
docker-compose ps
docker-compose logs -f
```

---

### 方法3：使用 FTP 工具上传

#### 步骤1：使用 WinSCP 或 FileZilla 连接服务器

- **主机**: ***.***.***.***
- **用户名**: root
- **密码**: [您的服务器密码]
- **端口**: 22

#### 步骤2：上传项目文件

将 `e:/repo/openclaw-workspace/thesis-checker-web` 目录下的所有文件上传到服务器的 `/root/projects/thesis-checker-web` 目录

#### 步骤3：SSH 连接到服务器并执行部署

```bash
ssh root@***.***.***.***

# 进入项目目录
cd /root/projects/thesis-checker-web

# 启动服务
docker-compose up -d --build

# 查看服务状态
docker-compose ps
```

---

## 验证部署

部署完成后，在浏览器中访问：

- **前端应用**: http://***.***.***.***:8000
- **后端API文档**: http://***.***.***.***:8000/docs

---

## 常用管理命令

### 在服务器上执行：

```bash
# 查看服务状态
cd /root/projects/thesis-checker-web
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新服务（修改代码后）
/root/update-thesis-checker.sh

# 查看容器资源占用
docker stats

# 进入后端容器
docker exec -it thesis-checker-backend bash
```

---

## 快速更新流程

### 本地修改代码后：

1. **更新项目文件**
   ```bash
   # 方式1：使用 SCP 重新上传
   scp -r /e/repo/openclaw-workspace/thesis-checker-web root@***.***.***.***:/root/projects/
   
   # 方式2：使用 Git 推送
   git add .
   git commit -m "update"
   git push origin main
   ```

2. **在服务器上更新**
   ```bash
   ssh root@***.***.***.*** "/root/update-thesis-checker.sh"
   ```

---

## 故障排查

### 问题1：容器无法启动

```bash
# 查看容器日志
docker logs thesis-checker-backend
docker logs thesis-checker-mongodb

# 重新构建镜像
docker-compose down
docker-compose up -d --build
```

### 问题2：端口无法访问

```bash
# 检查防火墙状态
systemctl status firewalld

# 检查端口监听
netstat -tlnp | grep 8000
```

### 问题3：数据库连接失败

```bash
# 检查 MongoDB 容器状态
docker ps | grep mongodb

# 查看 MongoDB 日志
docker logs thesis-checker-mongodb

# 测试数据库连接
docker exec -it thesis-checker-mongodb mongosh -u admin -p password123
```

---

## 安全建议

1. **修改默认密码**
   - MongoDB 默认密码：password123
   - 修改 `docker-compose.yml` 中的环境变量

2. **配置 HTTPS**
   - 使用 Nginx 反向代理
   - 配置 SSL 证书（Let's Encrypt）

3. **限制访问**
   - 配置防火墙规则
   - 限制 API 访问频率

---

## 下一步优化

- [ ] 配置域名解析
- [ ] 配置 SSL 证书（HTTPS）
- [ ] 配置 Nginx 反向代理
- [ ] 配置自动备份
- [ ] 配置监控告警

---

## 技术支持

如遇到问题，请检查：

1. Docker 服务是否正常运行
2. 端口是否正确开放（8000）
3. 防火墙规则是否正确配置
4. 数据库连接是否正常

---

**祝您部署成功！** 🎉
