# 🚀 毕业论文检查系统 - 最终部署指南

## 📊 部署状态总结

### ✅ 已完成
1. 项目文件已上传到服务器 `/root/projects/thesis-checker-web`
2. docker-compose.yml 已更新（移除 MongoDB，使用 SQLite）
3. 防火墙已停止
4. Python 依赖已安装
5. 启动脚本已创建

### ⚠️ 当前状态
- 服务需要手动启动

---

## 🎯 立即启动服务

请按照以下步骤操作：

### 步骤 1：SSH 连接到服务器

```bash
ssh root@***.***.***.***
```

### 步骤 2：运行启动脚本

```bash
bash /root/start-server.sh
```

或者手动启动：

```bash
cd /root/projects/thesis-checker-web/backend
nohup python3 main.py > /tmp/backend.log 2>&1 &
```

### 步骤 3：验证服务

```bash
# 检查进程
ps aux | grep python3

# 检查端口
netstat -tlnp | grep 8000

# 测试访问
curl http://localhost:8000
```

### 步骤 4：查看日志

```bash
tail -f /tmp/thesis-backend.log
```

---

## 🌐 访问应用

启动成功后，在浏览器中访问：

- **前端应用**: http://***.***.***.***:8000
- **后端API**: http://***.***.***.***:8000/api
- **API文档**: http://***.***.***.***:8000/docs

### 默认账号
- **管理员账号**: admin
- **密码**: admin123

---

## 🔧 管理命令

### 查看服务状态
```bash
ssh root@***.***.***.*** "ps aux | grep python3"
```

### 查看日志
```bash
ssh root@***.***.***.*** "tail -f /tmp/thesis-backend.log"
```

### 重启服务
```bash
ssh root@***.***.***.*** "pkill -f 'python3 main.py' && cd /root/projects/thesis-checker-web/backend && nohup python3 main.py > /tmp/backend.log 2>&1 &"
```

### 停止服务
```bash
ssh root@***.***.***.*** "pkill -f 'python3 main.py'"
```

---

## 🐛 故障排查

### 问题 1：无法访问网站
**检查清单：**
```bash
# 1. 检查服务是否运行
ssh root@***.***.***.*** "ps aux | grep python3"

# 2. 检查端口是否监听
ssh root@***.***.***.*** "netstat -tlnp | grep 8000"

# 3. 查看日志
ssh root@***.***.***.*** "tail -50 /tmp/backend.log"
```

### 问题 2：服务启动失败
**解决方案：**
```bash
# 1. 检查 Python 环境
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web/backend && python3 --version"

# 2. 重新安装依赖
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web/backend && pip3 install -r requirements.txt"

# 3. 手动运行查看错误
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web/backend && python3 main.py"
```

### 问题 3：数据库错误
**解决方案：**
```bash
# 检查数据库文件
ssh root@***.***.***.*** "ls -la /root/projects/thesis-checker-web/backend/thesis_checker.db"

# 如果数据库有问题，删除重建
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web/backend && rm -f thesis_checker.db"
# 然后重启服务
```

---

## 📝 一键命令参考

### 完整部署（首次）
```bash
ssh root@***.***.***.*** "bash /root/start-server.sh"
```

### 更新代码后重启
```powershell
# 1. 上传修改后的文件
scp e:/repo/openclaw-workspace/thesis-checker-web/backend/main.py root@***.***.***.***:/root/projects/thesis-checker-web/backend/

# 2. 重启服务
ssh root@***.***.***.*** "pkill -f 'python3 main.py' && cd /root/projects/thesis-checker-web/backend && nohup python3 main.py > /tmp/backend.log 2>&1 &"
```

### 查看实时日志
```bash
ssh root@***.***.***.*** "tail -f /tmp/backend.log"
```

---

## 📞 技术支持

### 检查清单
- [ ] Python 3 已安装
- [ ] 依赖包已安装
- [ ] 数据库文件已创建
- [ ] 端口 8000 未被占用
- [ ] 防火墙已停止
- [ ] 服务进程正在运行

### 常用调试命令
```bash
# 查看系统资源
ssh root@***.***.***.*** "free -h && df -h"

# 查看端口占用
ssh root@***.***.***.*** "netstat -tlnp"

# 查看系统日志
ssh root@***.***.***.*** "journalctl -xe"
```

---

## 🎉 成功标志

当您看到以下内容时，说明部署成功：

1. ✅ 进程正在运行（`ps aux | grep python3` 显示进程）
2. ✅ 端口 8000 正在监听（`netstat -tlnp | grep 8000`）
3. ✅ 可以访问 http://***.***.***.***:8000
4. ✅ API 文档可以访问：http://***.***.***.***:8000/docs
5. ✅ 日志中没有错误信息

---

## 📦 部署文件位置

- **项目目录**: `/root/projects/thesis-checker-web`
- **后端目录**: `/root/projects/thesis-checker-web/backend`
- **启动脚本**: `/root/start-server.sh`
- **日志文件**: `/tmp/backend.log` 或 `/tmp/thesis-backend.log`
- **数据库**: `/root/projects/thesis-checker-web/backend/thesis_checker.db`

---

**祝您使用愉快！** 🎊
