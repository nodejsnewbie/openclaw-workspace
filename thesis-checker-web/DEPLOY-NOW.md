# 🚀 立即执行部署 - 3 步完成

## 步骤 1：上传项目（5 分钟）

打开 **Git Bash**，执行以下命令：

```bash
scp -r /e/repo/openclaw-workspace/thesis-checker-web root@***.***.***.***:/root/projects/
```

等待上传完成...

---

## 步骤 2：上传部署脚本（1 分钟）

在 Git Bash 中执行：

```bash
scp e:/repo/openclaw-workspace/thesis-checker-web/install-tat-and-deploy.sh root@***.***.***.***:/root/
```

---

## 步骤 3：执行部署（5 分钟）

在 Git Bash 中连接到服务器并执行：

```bash
# 连接服务器
ssh root@***.***.***.***

# 执行部署脚本
chmod +x /root/install-tat-and-deploy.sh
/root/install-tat-and-deploy.sh
```

---

## ✅ 部署完成后

访问以下地址验证部署：

- **前端应用**: http://***.***.***.***:8000
- **后端API**: http://***.***.***.***:8000/api
- **API文档**: http://***.***.***.***:8000/docs

---

## 🔧 管理命令

```bash
# 连接服务器
ssh root@***.***.***.***

# 查看服务状态
thesis-checker status

# 查看日志
thesis-checker logs

# 重启服务
thesis-checker restart

# 更新服务（修改代码后）
thesis-checker update
```

---

## 📝 快速复制粘贴

### 完整部署命令（复制粘贴到 Git Bash）

```bash
# 步骤 1：上传项目
scp -r /e/repo/openclaw-workspace/thesis-checker-web root@***.***.***.***:/root/projects/

# 步骤 2：上传部署脚本
scp e:/repo/openclaw-workspace/thesis-checker-web/install-tat-and-deploy.sh root@***.***.***.***:/root/

# 步骤 3：执行部署
ssh root@***.***.***.*** "chmod +x /root/install-tat-and-deploy.sh && /root/install-tat-and-deploy.sh"
```

---

## ⚡ 一键执行（推荐）

直接在 Git Bash 中执行下面这一行命令，自动完成所有步骤：

```bash
scp -r /e/repo/openclaw-workspace/thesis-checker-web root@***.***.***.***:/root/projects/ && scp e:/repo/openclaw-workspace/thesis-checker-web/install-tat-and-deploy.sh root@***.***.***.***:/root/ && ssh root@***.***.***.*** "chmod +x /root/install-tat-and-deploy.sh && /root/install-tat-and-deploy.sh"
```

---

**就这么简单！复制上面的一键命令到 Git Bash 中执行即可完成部署。** 🎉
