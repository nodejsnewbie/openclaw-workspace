# 🚀 毕业论文检查系统 - 部署总结

## ✅ 已完成的工作

### 1. 项目文件已上传到服务器
- 服务器 IP: ***.***.***.***
- 项目路径: /root/projects/thesis-checker-web

### 2. 配置文件已优化
- 更新了 docker-compose.yml，移除了 MongoDB 依赖
- 使用 SQLite 数据库（更适合轻量部署）

### 3. 部署脚本已创建
- install-tat-and-deploy.sh（服务器端部署脚本）
- 快速管理命令已配置

---

## 🔄 当前状态

项目文件已成功上传到服务器，但服务可能需要手动启动。

---

## 📋 手动启动步骤

### 步骤 1：连接到服务器
```bash
ssh root@***.***.***.***
```

### 步骤 2：进入项目目录
```bash
cd /root/projects/thesis-checker-web
```

### 步骤 3：检查文件
```bash
ls -la
cat docker-compose.yml
```

### 步骤 4：启动服务
```bash
docker-compose up -d --build
```

### 步骤 5：等待服务启动
```bash
sleep 20
```

### 步骤 6：检查服务状态
```bash
docker-compose ps
docker logs thesis-checker-backend
```

### 步骤 7：测试访问
```bash
curl http://localhost:8000
```

---

## 🌐 访问地址

部署成功后，在浏览器中访问：

- **前端应用**: http://***.***.***.***:8000
- **后端API**: http://***.***.***.***:8000/api
- **API文档**: http://***.***.***.***:8000/docs

---

## 🔧 常用管理命令

### 查看服务状态
```bash
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose ps"
```

### 查看日志
```bash
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose logs -f"
```

### 重启服务
```bash
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose restart"
```

### 停止服务
```bash
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down"
```

### 更新服务（修改代码后）
```bash
# 1. 上传修改后的文件
scp e:/repo/openclaw-workspace/thesis-checker-web/* root@***.***.***.***:/root/projects/thesis-checker-web/

# 2. 重新部署
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down && docker-compose up -d --build"
```

---

## 🐛 故障排查

### 问题 1：容器无法启动
```bash
# 查看详细日志
ssh root@***.***.***.*** "docker logs thesis-checker-backend"

# 重新构建
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down && docker-compose up -d --build"
```

### 问题 2：端口无法访问
```bash
# 检查端口监听
ssh root@***.***.***.*** "netstat -tlnp | grep 8000"

# 检查防火墙
ssh root@***.***.***.*** "systemctl status firewalld"
```

### 问题 3：数据库连接失败
```bash
# 检查数据库文件
ssh root@***.***.***.*** "ls -la /root/projects/thesis-checker-web/backend/thesis_checker.db"
```

---

## 📝 快速复制命令

### 一键部署（在本地 PowerShell 执行）
```powershell
# 上传修改后的配置文件
scp e:/repo/openclaw-workspace/thesis-checker-web/docker-compose.yml root@***.***.***.***:/root/projects/thesis-checker-web/

# 部署服务
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down && docker-compose up -d --build"

# 查看日志
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose logs -f"
```

---

## 🎯 下一步

1. 连接到服务器并执行启动命令
2. 等待服务启动（约 1-2 分钟）
3. 在浏览器中访问应用
4. 如有问题，查看日志排查

---

## 📞 技术支持

如遇到问题，请检查：
1. Docker 服务是否正常运行
2. 端口 8000 是否已开放
3. 容器日志中的错误信息
4. 数据库文件是否正常创建

---

**祝您部署成功！** 🎉
