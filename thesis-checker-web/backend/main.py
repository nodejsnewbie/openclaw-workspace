from fastapi import FastAPI, File, UploadFile, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
from dotenv import load_dotenv
from pymongo import MongoClient
import os
import uuid
import shutil
from typing import Optional, List

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "thesis_checker")

client = MongoClient(MONGODB_URL)
db = client[DATABASE_NAME]

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI(title="毕业论文检查系统API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 静态文件服务 - 前端dist目录
app.mount("/", StaticFiles(directory="../frontend/dist", html=True), name="static")

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class User(BaseModel):
    username: str
    email: Optional[str] = None
    role: str = "user"

class UserInDB(User):
    hashed_password: str

class UserCreate(BaseModel):
    username: str
    password: str
    email: Optional[str] = None

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def get_user(username: str):
    user = db.users.find_one({"username": username})
    if user:
        return UserInDB(**user)

def create_user(user: UserCreate):
    hashed_password = get_password_hash(user.password)
    user_dict = user.dict()
    user_dict["hashed_password"] = hashed_password
    user_dict["role"] = "user"
    del user_dict["password"]
    
    # 如果是第一个用户，设为管理员
    if db.users.count_documents({}) == 0:
        user_dict["role"] = "admin"
    
    result = db.users.insert_one(user_dict)
    return user_dict

def authenticate_user(username: str, password: str):
    user = get_user(username)
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

async def get_current_user(token: str = Depends(oauth2_scheme)):
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
    user = get_user(username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    return current_user

async def get_current_admin_user(current_user: User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough permissions"
        )
    return current_user

# 初始化管理员用户
if db.users.count_documents({"username": "admin"}) == 0:
    create_user(UserCreate(
        username="admin",
        password="admin123",
        email="admin@example.com"
    ))

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me/", response_model=User)
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

# 论文相关接口
@app.post("/thesis/upload")
async def upload_thesis(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user)
):
    # 创建上传目录
    os.makedirs("uploads", exist_ok=True)
    
    # 生成唯一文件名
    file_extension = os.path.splitext(file.filename)[1]
    file_id = str(uuid.uuid4())
    file_path = f"uploads/{file_id}{file_extension}"
    
    # 保存文件
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # 保存记录到数据库
    thesis_record = {
        "id": file_id,
        "title": os.path.splitext(file.filename)[0],
        "filename": file.filename,
        "user_id": current_user.username,
        "status": "uploaded",
        "created_at": datetime.utcnow().isoformat(),
        "file_path": file_path
    }
    
    db.theses.insert_one(thesis_record)
    
    return {"id": file_id, "filename": file.filename, "status": "uploaded"}

@app.get("/thesis/history")
async def get_history_list(current_user: User = Depends(get_current_active_user)):
    history = list(db.theses.find({"user_id": current_user.username}).sort("created_at", -1))
    for item in history:
        item["_id"] = str(item["_id"])
    return {"data": history}

@app.get("/thesis/report/{thesis_id}")
async def get_report(
    thesis_id: str,
    current_user: User = Depends(get_current_active_user)
):
    thesis = db.theses.find_one({"id": thesis_id, "user_id": current_user.username})
    if not thesis:
        raise HTTPException(status_code=404, detail="Thesis not found")
    
    # 示例报告数据，实际需要实现检查逻辑
    report = {
        "id": thesis_id,
        "title": thesis["title"],
        "filename": thesis["filename"],
        "score": 85,
        "status": thesis["status"],
        "created_at": thesis["created_at"],
        "issues": [
            {
                "id": 1,
                "type": "format",
                "level": "high",
                "title": "封面格式错误",
                "description": "封面标题字号不符合要求，应为二号黑体",
                "location": "第1页",
                "suggestion": "将封面标题修改为二号黑体，居中对齐"
            },
            {
                "id": 2,
                "type": "content",
                "level": "medium",
                "title": "摘要字数不足",
                "description": "摘要字数应为300-500字，当前为200字",
                "location": "第2页",
                "suggestion": "补充摘要内容，达到300字以上"
            }
        ],
        "stats": {
            "total": 12,
            "high": 3,
            "medium": 5,
            "low": 4
        }
    }
    
    return {"data": report}

@app.post("/thesis/check/{thesis_id}")
async def check_thesis(
    thesis_id: str,
    current_user: User = Depends(get_current_active_user)
):
    thesis = db.theses.find_one({"id": thesis_id, "user_id": current_user.username})
    if not thesis:
        raise HTTPException(status_code=404, detail="Thesis not found")
    
    # 更新状态为检查中
    db.theses.update_one(
        {"id": thesis_id},
        {"$set": {"status": "checking"}}
    )
    
    # 这里需要实现实际的检查逻辑
    # 示例：模拟检查完成
    db.theses.update_one(
        {"id": thesis_id},
        {"$set": {"status": "completed"}}
    )
    
    return {"status": "completed", "message": "检查完成"}

@app.delete("/thesis/history/{thesis_id}")
async def delete_history(
    thesis_id: str,
    current_user: User = Depends(get_current_active_user)
):
    thesis = db.theses.find_one({"id": thesis_id, "user_id": current_user.username})
    if not thesis:
        raise HTTPException(status_code=404, detail="Thesis not found")
    
    # 删除文件
    if os.path.exists(thesis["file_path"]):
        os.remove(thesis["file_path"])
    
    # 删除数据库记录
    db.theses.delete_one({"id": thesis_id})
    
    return {"message": "删除成功"}

# 管理员接口
@app.get("/admin/requirements")
async def get_requirements(
    current_user: User = Depends(get_current_admin_user)
):
    requirements = list(db.requirements.find().sort("created_at", -1))
    for item in requirements:
        item["_id"] = str(item["_id"])
    return {"data": requirements}

@app.get("/admin/users")
async def get_users(
    current_user: User = Depends(get_current_admin_user)
):
    users = list(db.users.find())
    for user in users:
        user["_id"] = str(user["_id"])
        del user["hashed_password"]
    return {"data": users}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
