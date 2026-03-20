import os
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

# MongoDB 配置
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "thesis_checker")

# 异步客户端 (用于 FastAPI 异步路由)
client = AsyncIOMotorClient(MONGODB_URL)
database = client[DATABASE_NAME]

# 集合名称
USERS_COLLECTION = "users"
THESES_COLLECTION = "theses"
REQUIREMENTS_COLLECTION = "requirements"
TEMPLATES_COLLECTION = "templates"

def get_database():
    return database

async def create_indexes():
    """创建索引"""
    await database[USERS_COLLECTION].create_index("username", unique=True)
    await database[USERS_COLLECTION].create_index("email", unique=True)
    await database[THESES_COLLECTION].create_index("owner_id")
    await database[REQUIREMENTS_COLLECTION].create_index("type")
    await database[TEMPLATES_COLLECTION].create_index("category")
