from fastapi import FastAPI, File, UploadFile, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import os
import uuid
import json
from docx import Document
import PyPDF2
import markdown

# 配置
SECRET_KEY = "your-secret-key-keep-it-safe-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
UPLOAD_DIR = "./uploads"
REPORT_DIR = "./reports"
REQUIREMENTS_DIR = "./requirements"

# 创建目录
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(REPORT_DIR, exist_ok=True)
os.makedirs(REQUIREMENTS_DIR, exist_ok=True)

# 数据库配置
SQLALCHEMY_DATABASE_URL = "sqlite:///./thesis_checker.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# 密码加密
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI(title="毕业论文检查系统API", version="1.0.0")

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 数据库模型
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True)
    email = Column(String(100), unique=True, index=True)
    hashed_password = Column(String(100))
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    theses = relationship("Thesis", back_populates="owner")

class Thesis(Base):
    __tablename__ = "theses"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200))
    filename = Column(String(200))
    file_path = Column(String(300))
    file_type = Column(String(20))
    status = Column(String(20), default="uploaded")  # uploaded, checking, completed, failed
    report_path = Column(String(300))
    check_result = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    owner_id = Column(Integer, ForeignKey("users.id"))
    owner = relationship("User", back_populates="theses")

class Requirement(Base):
    __tablename__ = "requirements"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    type = Column(String(20))  # school, major
    major = Column(String(100), nullable=True)
    file_path = Column(String(300))
    content = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

Base.metadata.create_all(bind=engine)

# Pydantic模型
class Token(BaseModel):
    access_token: str
    token_type: str
    is_admin: bool
    username: str

class TokenData(BaseModel):
    username: Optional[str] = None

class UserBase(BaseModel):
    username: str
    email: str

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    is_admin: bool
    created_at: datetime
    class Config:
        orm_mode = True

class ThesisBase(BaseModel):
    title: str

class ThesisResponse(ThesisBase):
    id: int
    filename: str
    file_type: str
    status: str
    created_at: datetime
    class Config:
        orm_mode = True

class RequirementBase(BaseModel):
    name: str
    type: str
    major: Optional[str] = None

class RequirementResponse(RequirementBase):
    id: int
    created_at: datetime
    updated_at: datetime
    class Config:
        orm_mode = True

class CheckResult(BaseModel):
    issues: List[dict]
    total_issues: int
    score: int
    summary: str

# 工具函数
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def get_user(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def authenticate_user(db: Session, username: str, password: str):
    user = get_user(db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_admin(current_user: User = Depends(get_current_user)):
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Not authorized as admin")
    return current_user

def read_docx(file_path):
    doc = Document(file_path)
    content = []
    for i, para in enumerate(doc.paragraphs):
        content.append({
            'line': i + 1,
            'text': para.text,
            'style': para.style.name,
            'alignment': str(para.alignment) if para.alignment else None,
            'indent': para.paragraph_format.first_line_indent.pt if para.paragraph_format.first_line_indent else None,
            'line_spacing': para.paragraph_format.line_spacing
        })
    return content

def read_pdf(file_path):
    content = []
    with open(file_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        for page_num, page in enumerate(reader.pages):
            text = page.extract_text()
            content.append({
                'page': page_num + 1,
                'text': text
            })
    return content

def read_md(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    return markdown.markdown(content)

def check_thesis(content, requirements):
    issues = []
    
    # 示例检查规则
    for para in content:
        if isinstance(para, dict) and 'text' in para:
            text = para['text'].strip()
            if not text:
                continue
                
            # 检查标题格式
            if 'style' in para and para['style'].startswith('Heading'):
                if len(text) > 30:
                    issues.append({
                        'position': f"第{para['line']}行",
                        'type': '格式问题',
                        'description': f"标题过长：{text[:20]}...",
                        'suggestion': '建议标题长度控制在30字以内',
                        'severity': 'medium'
                    })
            
            # 检查段落长度
            if 'style' in para and para['style'] == 'Normal' and len(text) > 300:
                issues.append({
                    'position': f"第{para['line']}行",
                    'type': '内容建议',
                    'description': '段落过长，建议拆分',
                    'suggestion': '将长段落拆分为多个短段落，提高可读性',
                    'severity': 'low'
                })
            
            # 检查缩进
            if 'style' in para and para['style'] == 'Normal' and 'indent' in para:
                if para['indent'] is None or para['indent'] < 20:
                    issues.append({
                        'position': f"第{para['line']}行",
                        'type': '格式问题',
                        'description': '正文段落未设置首行缩进',
                        'suggestion': '请设置首行缩进2字符（约24-28磅）',
                        'severity': 'medium'
                    })
    
    # 计算分数
    score = max(0, 100 - len(issues) * 5)
    summary = f"共检测到{len(issues)}个问题，综合评分{score}分"
    
    return {
        'issues': issues,
        'total_issues': len(issues),
        'score': score,
        'summary': summary
    }

# 路由
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "is_admin": user.is_admin,
        "username": user.username
    }

@app.post("/api/auth/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = get_user(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = get_password_hash(user.password)
    db_user = User(
        username=user.username,
        email=user.email,
        hashed_password=hashed_password,
        is_admin=False
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.get("/api/auth/profile", response_model=UserResponse)
def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user

# 论文相关接口
@app.post("/api/thesis/upload", response_model=ThesisResponse)
async def upload_thesis(
    title: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    file_ext = os.path.splitext(file.filename)[1].lower()
    allowed_extensions = ['.docx', '.pdf', '.md']
    if file_ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail="Unsupported file type")
    
    file_id = str(uuid.uuid4())
    filename = f"{file_id}{file_ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)
    
    with open(file_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
    
    db_thesis = Thesis(
        title=title,
        filename=file.filename,
        file_path=file_path,
        file_type=file_ext[1:],
        owner_id=current_user.id
    )
    db.add(db_thesis)
    db.commit()
    db.refresh(db_thesis)
    
    return db_thesis

@app.post("/api/thesis/check/{thesis_id}", response_model=CheckResult)
def check_thesis_endpoint(
    thesis_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    thesis = db.query(Thesis).filter(Thesis.id == thesis_id, Thesis.owner_id == current_user.id).first()
    if not thesis:
        raise HTTPException(status_code=404, detail="Thesis not found")
    
    thesis.status = "checking"
    db.commit()
    
    try:
        # 读取文件内容
        content = []
        if thesis.file_type == 'docx':
            content = read_docx(thesis.file_path)
        elif thesis.file_type == 'pdf':
            content = read_pdf(thesis.file_path)
        elif thesis.file_type == 'md':
            content = read_md(thesis.file_path)
        
        # 加载规范要求
        requirements = db.query(Requirement).all()
        req_content = "\n".join([req.content for req in requirements])
        
        # 执行检查
        result = check_thesis(content, req_content)
        
        # 保存结果
        thesis.check_result = json.dumps(result, ensure_ascii=False)
        thesis.status = "completed"
        
        # 生成报告文件
        report_filename = f"report_{thesis_id}.md"
        report_path = os.path.join(REPORT_DIR, report_filename)
        
        report_content = f"# 毕业论文检查报告\n\n"
        report_content += f"## 基本信息\n"
        report_content += f"- 论文标题：{thesis.title}\n"
        report_content += f"- 文件名：{thesis.filename}\n"
        report_content += f"- 检查时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
        report_content += f"- 综合评分：{result['score']}分\n"
        report_content += f"- 问题总数：{result['total_issues']}个\n\n"
        
        report_content += f"## 问题详情\n"
        for i, issue in enumerate(result['issues'], 1):
            report_content += f"### {i}. {issue['position']}\n"
            report_content += f"**类型**：{issue['type']}\n"
            report_content += f"**问题描述**：{issue['description']}\n"
            report_content += f"**修改建议**：{issue['suggestion']}\n\n"
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(report_content)
        
        thesis.report_path = report_path
        db.commit()
        
        return result
        
    except Exception as e:
        thesis.status = "failed"
        db.commit()
        raise HTTPException(status_code=500, detail=f"Check failed: {str(e)}")

@app.get("/api/thesis/report/{thesis_id}")
def get_thesis_report(
    thesis_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    thesis = db.query(Thesis).filter(Thesis.id == thesis_id, Thesis.owner_id == current_user.id).first()
    if not thesis:
        raise HTTPException(status_code=404, detail="Thesis not found")
    
    if thesis.status != "completed":
        raise HTTPException(status_code=400, detail="Check not completed")
    
    if not thesis.check_result:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return json.loads(thesis.check_result)

@app.get("/api/thesis/history", response_model=List[ThesisResponse])
def get_thesis_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    theses = db.query(Thesis).filter(Thesis.owner_id == current_user.id).order_by(Thesis.created_at.desc()).all()
    return theses

# 管理员接口
@app.post("/api/admin/requirements", response_model=RequirementResponse)
def upload_requirement(
    name: str,
    type: str,
    major: Optional[str] = None,
    file: UploadFile = File(...),
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    if type not in ['school', 'major']:
        raise HTTPException(status_code=400, detail="Invalid requirement type")
    
    file_ext = os.path.splitext(file.filename)[1].lower()
    allowed_extensions = ['.md', '.txt', '.docx']
    if file_ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail="Unsupported file type")
    
    file_id = str(uuid.uuid4())
    filename = f"{file_id}{file_ext}"
    file_path = os.path.join(REQUIREMENTS_DIR, filename)
    
    with open(file_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
    
    # 提取文本内容
    content = ""
    if file_ext == '.docx':
        doc = Document(file_path)
        content = "\n".join([para.text for para in doc.paragraphs])
    else:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    
    db_req = Requirement(
        name=name,
        type=type,
        major=major,
        file_path=file_path,
        content=content
    )
    db.add(db_req)
    db.commit()
    db.refresh(db_req)
    
    return db_req

@app.get("/api/admin/requirements", response_model=List[RequirementResponse])
def get_requirements(
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    requirements = db.query(Requirement).order_by(Requirement.created_at.desc()).all()
    return requirements

@app.delete("/api/admin/requirements/{req_id}")
def delete_requirement(
    req_id: int,
    current_admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    req = db.query(Requirement).filter(Requirement.id == req_id).first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
    
    if os.path.exists(req.file_path):
        os.remove(req.file_path)
    
    db.delete(req)
    db.commit()
    
    return {"message": "Requirement deleted successfully"}

# 创建默认管理员账号
def create_default_admin():
    db = SessionLocal()
    admin = get_user(db, username="admin")
    if not admin:
        hashed_password = get_password_hash("admin123")
        admin = User(
            username="admin",
            email="admin@example.com",
            hashed_password=hashed_password,
            is_admin=True
        )
        db.add(admin)
        db.commit()
    db.close()

create_default_admin()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
