import os
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime
from typing import Optional, List, Any, Dict
from copy import deepcopy

load_dotenv()

# MongoDB 配置
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "thesis_checker")

# 集合名称
USERS_COLLECTION = "users"
THESES_COLLECTION = "theses"
REQUIREMENTS_COLLECTION = "requirements"
TEMPLATES_COLLECTION = "templates"

# 内存存储类（用于无 MongoDB 环境的后备方案）
class MemoryCollection:
    def __init__(self, name: str):
        self.name = name
        self._data: Dict[str, dict] = {}
        self._id_counter = 0
        self._indexes: Dict[str, bool] = {}  # field -> unique
    
    async def insert_one(self, document: dict) -> Any:
        self._id_counter += 1
        doc_copy = deepcopy(document)
        if "_id" not in doc_copy:
            from bson import ObjectId
            doc_copy["_id"] = ObjectId()
        self._data[str(doc_copy["_id"])] = doc_copy
        class Result:
            inserted_id = doc_copy["_id"]
        return Result()
    
    async def find_one(self, query: dict) -> Optional[dict]:
        for doc in self._data.values():
            if self._match(doc, query):
                return deepcopy(doc)
        return None
    
    async def find(self, query: dict = None) -> "MemoryCursor":
        query = query or {}
        results = [deepcopy(doc) for doc in self._data.values() if self._match(doc, query)]
        return MemoryCursor(results)
    
    async def update_one(self, query: dict, update: dict) -> Any:
        for doc_id, doc in self._data.items():
            if self._match(doc, query):
                if "$set" in update:
                    doc.update(update["$set"])
                class Result:
                    modified_count = 1
                return Result()
        class Result:
            modified_count = 0
        return Result()
    
    async def delete_one(self, query: dict) -> Any:
        for doc_id, doc in list(self._data.items()):
            if self._match(doc, query):
                del self._data[doc_id]
                class Result:
                    deleted_count = 1
                return Result()
        class Result:
            deleted_count = 0
        return Result()
    
    async def create_index(self, field: str, unique: bool = False) -> None:
        self._indexes[field] = unique
    
    def _match(self, doc: dict, query: dict) -> bool:
        for key, value in query.items():
            if key == "_id":
                from bson import ObjectId
                if isinstance(value, ObjectId):
                    if doc.get("_id") != value:
                        return False
                elif isinstance(value, dict) and "$oid" in value:
                    if str(doc.get("_id")) != value["$oid"]:
                        return False
            elif doc.get(key) != value:
                return False
        return True

class MemoryCursor:
    def __init__(self, data: List[dict]):
        self._data = data
        self._sort_key = None
        self._sort_direction = 1
    
    def sort(self, key: str, direction: int = 1) -> "MemoryCursor":
        self._sort_key = key
        self._sort_direction = direction
        return self
    
    async def to_list(self, length: Optional[int] = None) -> List[dict]:
        if self._sort_key:
            self._data.sort(key=lambda x: x.get(self._sort_key, ""), reverse=(self._sort_direction == -1))
        if length is not None:
            return self._data[:length]
        return self._data

class MemoryDatabase:
    def __init__(self):
        self._collections: Dict[str, MemoryCollection] = {}
    
    def __getitem__(self, name: str) -> MemoryCollection:
        if name not in self._collections:
            self._collections[name] = MemoryCollection(name)
        return self._collections[name]

# 全局变量
client = None
database = None
use_memory = False

def get_database():
    return database

async def create_indexes():
    """创建索引"""
    if use_memory:
        # 内存模式不需要实际创建索引
        return
    
    await database[USERS_COLLECTION].create_index("username", unique=True)
    await database[USERS_COLLECTION].create_index("email", unique=True)
    await database[THESES_COLLECTION].create_index("owner_id")
    await database[REQUIREMENTS_COLLECTION].create_index("type")
    await database[TEMPLATES_COLLECTION].create_index("category")

def init_database():
    """初始化数据库连接"""
    global client, database, use_memory
    
    try:
        # 尝试连接 MongoDB
        client = AsyncIOMotorClient(MONGODB_URL, serverSelectionTimeoutMS=2000)
        # 测试连接
        import asyncio
        loop = asyncio.get_event_loop()
        loop.run_until_complete(client.server_info())
        database = client[DATABASE_NAME]
        use_memory = False
        print("✓ Connected to MongoDB")
    except Exception as e:
        print(f"⚠ MongoDB connection failed: {e}")
        print("⚠ Using in-memory storage as fallback")
        database = MemoryDatabase()
        use_memory = True

# 启动时初始化
init_database()
