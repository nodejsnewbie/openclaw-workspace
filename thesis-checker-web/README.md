# 毕业论文检查系统

基于Vue3 + FastAPI的前后端分离毕业论文格式检查平台

## 🚀 技术栈

### 前端
- **Vue 3** - 渐进式JavaScript框架
- **Vite** - 下一代前端构建工具
- **Element Plus** - 基于Vue 3的组件库
- **Axios** - HTTP客户端
- **Vue Router** - 路由管理
- **Pinia** - 状态管理

### 后端
- **FastAPI** - 现代、快速的Python Web框架
- **SQLAlchemy** - ORM框架
- **MySQL** - 关系型数据库
- **python-docx** - Word文档处理
- **PyPDF2** - PDF文档处理
- **Pydantic** - 数据验证
- **Uvicorn** - ASGI服务器

## 📋 功能模块

### 管理员端
- 🔐 管理员登录/权限管理
- 📝 论文格式要求上传和管理
- 📚 专业论文规范配置
- 👥 用户管理
- 📊 检查统计报表

### 用户端
- 👤 用户注册/登录
- 📤 毕业论文上传（支持docx/pdf/md格式）
- 🔍 论文自动格式检查
- 📊 检查报告可视化展示
- 💾 检查报告下载
- 📁 历史检查记录管理

### 核心功能
- 多维度格式检查（页面、字体、段落、引用、图表等）
- 智能问题定位（标注页码、行号、具体位置）
- 个性化修改建议
- 支持多学校/多专业规范配置
- 检查历史追溯

## 🏗️ 项目结构

```
thesis-checker-web/
├── frontend/          # 前端Vue项目
│   ├── src/
│   │   ├── api/       # API接口封装
│   │   ├── components/ # 公共组件
│   │   ├── views/     # 页面组件
│   │   ├── router/    # 路由配置
│   │   ├── store/     # 状态管理
│   │   └── utils/     # 工具函数
│   ├── public/        # 静态资源
│   └── package.json   # 前端依赖
├── backend/           # 后端FastAPI项目
│   ├── app/
│   │   ├── api/       # API路由
│   │   ├── core/      # 核心配置
│   │   ├── models/    # 数据库模型
│   │   ├── schemas/   # Pydantic模型
│   │   ├── services/  # 业务逻辑
│   │   └── utils/     # 工具函数
│   ├── requirements.txt # 后端依赖
│   └── main.py        # 应用入口
├── docs/              # 项目文档
└── docker-compose.yml # Docker部署配置
```

## 🛠️ 快速开始

### 环境要求
- Node.js >= 18.x
- Python >= 3.10
- MySQL >= 8.0

### 前端启动
```bash
cd frontend
npm install
npm run dev
```

### 后端启动
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### 访问地址
- 前端: http://localhost:5173
- 后端API: http://localhost:8000
- API文档: http://localhost:8000/docs

## 📄 API接口

### 用户相关
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/profile` - 获取用户信息

### 论文相关
- `POST /api/thesis/upload` - 上传论文
- `POST /api/thesis/check/{id}` - 执行论文检查
- `GET /api/thesis/report/{id}` - 获取检查报告
- `GET /api/thesis/history` - 获取历史记录

### 管理员相关
- `POST /api/admin/requirements` - 上传格式要求
- `PUT /api/admin/requirements/{id}` - 更新格式要求
- `GET /api/admin/requirements` - 获取格式要求列表
- `POST /api/admin/specs` - 上传专业规范
- `GET /api/admin/users` - 获取用户列表

## 🔧 配置说明

### 数据库配置
在 `backend/app/core/config.py` 中配置数据库连接：
```python
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://user:password@localhost:3306/thesis_checker"
```

### 文件存储配置
支持本地存储和对象存储，在配置文件中设置存储路径：
```python
UPLOAD_DIR = "/path/to/upload/files"
REPORT_DIR = "/path/to/generated/reports"
```

## 🚀 部署指南

### 前端部署 (Cloud Studio)

1. 修改 `frontend/.env.production` 中的API地址
2. 构建前端: `cd frontend && npm install && npm run build`
3. 部署 `dist` 目录

### 后端部署 (Cloud Studio)

1. 安装依赖: `cd backend && pip install -r requirements.txt`
2. 设置环境变量: `SECRET_KEY`, `AI_API_KEY`
3. 启动: `uvicorn main:app --host 0.0.0.0 --port 8000`

### Docker部署
```bash
docker-compose up -d
```

## 🤝 贡献指南
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📝 许可证
本项目采用 MIT 许可证
