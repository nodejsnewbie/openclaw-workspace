# 🚀 毕业论文检查系统 - MongoDB 部署指南

## 📊 为什么使用 MongoDB？

MongoDB 非常适合这个场景，因为：

### ✅ 优势
1. **灵活的文档结构** - 论文检查结果是嵌套的 JSON（issues、评分、建议），MongoDB 天然支持
2. **易扩展** - 论文数量增多时，MongoDB 水平扩展能力更强
3. **Schema-less** - 检查结果格式可能变化，MongoDB 更灵活
4. **高性能查询** - 大量论文记录检索性能更优
5. **适合非结构化数据** - 论文内容、检查报告等非结构化数据存储更方便

### 📋 数据模型对比

#### SQLite（关系型）
```sql
CREATE TABLE theses (
  id INTEGER PRIMARY KEY,
  title TEXT,
  check_result TEXT  -- JSON 字符串
);
-- 查询需要解析 JSON，性能差
```

#### MongoDB（文档型）
```javascript
{
  "_id": ObjectId("..."),
  "title": "论文标题",
  "check_result": {
    "issues": [...],
    "score": 85,
    "summary": "..."
  }
}
// 直接查询嵌套字段，性能好
```

---

## 🎯 完整部署步骤

### 步骤 1：上传更新后的配置文件

```bash
# 上传 docker-compose.yml
scp e:/repo/openclaw-workspace/thesis-checker-web/docker-compose.yml root@***.***.***.***:/root/projects/thesis-checker-web/
```

### 步骤 2：停止旧服务

```bash
ssh root@***.***.***.*** "pkill -f 'python3 main.py' && cd /root/projects/thesis-checker-web && docker-compose down"
```

### 步骤 3：启动 MongoDB 和后端服务

```bash
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose up -d --build"
```

### 步骤 4：等待服务启动

```bash
# 等待 30 秒
sleep 30
```

### 步骤 5：检查服务状态

```bash
# 检查容器状态
ssh root@***.***.***.*** "docker ps"

# 检查 MongoDB
ssh root@***.***.***.*** "docker logs thesis-checker-mongodb"

# 检查后端
ssh root@***.***.***.*** "docker logs thesis-checker-backend"
```

### 步骤 6：测试访问

```bash
# 测试本地访问
ssh root@***.***.***.*** "curl http://localhost:8000"

# 测试外部访问
curl http://***.***.***.***:8000
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
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose ps"
```

### 查看日志
```bash
# MongoDB 日志
ssh root@***.***.***.*** "docker logs -f thesis-checker-mongodb"

# 后端日志
ssh root@***.***.***.*** "docker logs -f thesis-checker-backend"

# 所有服务日志
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

### 更新服务
```bash
# 1. 上传修改后的文件
scp e:/repo/openclaw-workspace/thesis-checker-web/backend/main.py root@***.***.***.***:/root/projects/thesis-checker-web/backend/

# 2. 重新部署
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down && docker-compose up -d --build"
```

---

## 🗄️ MongoDB 管理

### 连接到 MongoDB

```bash
# 进入 MongoDB 容器
ssh root@***.***.***.*** "docker exec -it thesis-checker-mongodb mongosh -u admin -p password123"

# 或使用命令行
ssh root@***.***.***.*** "docker exec -it thesis-checker-mongodb mongosh mongodb://admin:password123@localhost:27017"
```

### 常用 MongoDB 命令

```javascript
// 连接到数据库
use thesis_checker

// 查看所有集合
show collections

// 查看论文记录
db.theses.find().pretty()

// 查看用户记录
db.users.find().pretty()

// 统计论文数量
db.theses.countDocuments()

// 删除所有论文
db.theses.deleteMany({})

// 创建索引
db.theses.createIndex({ "owner_id": 1 })
db.theses.createIndex({ "created_at": -1 })
```

### 备份数据库

```bash
# 备份
ssh root@***.***.***.*** "docker exec thesis-checker-mongodb mongodump -u admin -p password123 --db thesis_checker --out /tmp/backup"

# 导出备份
scp root@***.***.***.***:/tmp/backup ./backup
```

### 恢复数据库

```bash
# 上传备份文件
scp -r ./backup root@***.***.***.***:/tmp/

# 恢复
ssh root@***.***.***.*** "docker exec thesis-checker-mongodb mongorestore -u admin -p password123 --db thesis_checker /tmp/backup/thesis_checker"
```

---

## 🐛 故障排查

### 问题 1：MongoDB 连接失败
```bash
# 检查 MongoDB 容器
ssh root@***.***.***.*** "docker ps | grep mongodb"

# 查看 MongoDB 日志
ssh root@***.***.***.*** "docker logs thesis-checker-mongodb"

# 测试 MongoDB 连接
ssh root@***.***.***.*** "docker exec thesis-checker-mongodb mongosh -u admin -p password123 --eval 'db.runCommand({ping: 1})'"
```

### 问题 2：后端无法连接 MongoDB
```bash
# 检查网络
ssh root@***.***.***.*** "docker network inspect thesis-checker-web_thesis-network"

# 检查后端环境变量
ssh root@***.***.***.*** "docker exec thesis-checker-backend env | grep MONGO"

# 重启后端
ssh root@***.***.***.*** "docker restart thesis-checker-backend"
```

### 问题 3：容器启动失败
```bash
# 查看详细日志
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose logs"

# 重新构建
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down && docker-compose up -d --build"
```

---

## 📊 性能优化

### MongoDB 优化

1. **创建索引**
```bash
ssh root@***.***.***.*** "docker exec thesis-checker-mongodb mongosh -u admin -p password123 --eval 'use thesis_checker; db.theses.createIndex({owner_id: 1}); db.theses.createIndex({created_at: -1});'"
```

2. **调整内存配置**
```yaml
# 在 docker-compose.yml 中添加
mongodb:
  command: mongod --wiredTigerCacheSizeGB 2
```

3. **启用慢查询日志**
```bash
ssh root@***.***.***.*** "docker exec thesis-checker-mongodb mongosh -u admin -p password123 --eval 'db.setProfilingLevel(1, {slowms: 100})'"
```

---

## 📝 一键部署命令

```bash
# 完整部署流程
scp e:/repo/openclaw-workspace/thesis-checker-web/docker-compose.yml root@***.***.***.***:/root/projects/thesis-checker-web/ && \
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose down" && \
ssh root@***.***.***.*** "cd /root/projects/thesis-checker-web && docker-compose up -d --build" && \
sleep 30 && \
ssh root@***.***.***.*** "docker-compose ps" && \
curl http://***.***.***.***:8000
```

---

## 🔐 安全建议

### 1. 修改默认密码

编辑 `docker-compose.yml`：

```yaml
environment:
  MONGO_INITDB_ROOT_PASSWORD: your_strong_password_here
```

### 2. 限制 MongoDB 外部访问

移除 `ports` 配置或限制只监听本地：

```yaml
mongodb:
  ports:
    - "127.0.0.1:27017:27017"  # 只监听本地
```

### 3. 启用认证

确保后端连接字符串包含正确的用户名密码。

---

## 📞 技术支持

### 检查清单
- [ ] MongoDB 容器正在运行
- [ ] 后端容器正在运行
- [ ] 端口 8000 和 27017 正确监听
- [ ] 网络连接正常
- [ ] 数据库连接字符串正确

### 常用调试命令
```bash
# 查看系统资源
ssh root@***.***.***.*** "free -h && df -h"

# 查看端口占用
ssh root@***.***.***.*** "netstat -tlnp"

# 查看容器资源使用
ssh root@***.***.***.*** "docker stats"
```

---

**MongoDB 部署版本更适合您的应用场景！** 🚀
