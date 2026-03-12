<template>
  <div class="history">
    <h1>历史记录</h1>
    <div class="history-list">
      <div v-for="item in historyList" :key="item.id" class="history-item">
        <div class="item-info">
          <h3>{{ item.title }}</h3>
          <p>{{ item.createTime }}</p>
          <span :class="['status', item.status]">{{ item.statusText }}</span>
        </div>
        <div class="item-actions">
          <button @click="viewReport(item.id)" class="btn btn-primary">查看报告</button>
          <button @click="deleteItem(item.id)" class="btn btn-danger">删除</button>
        </div>
      </div>
    </div>
    <div v-if="historyList.length === 0" class="empty">
      <p>暂无历史记录</p>
      <router-link to="/upload" class="btn btn-primary">上传论文</router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getHistoryList, deleteHistory } from '@/api/thesis'

const router = useRouter()
const historyList = ref([])

onMounted(() => {
  fetchHistoryList()
})

const fetchHistoryList = async () => {
  try {
    const res = await getHistoryList()
    historyList.value = res.data
  } catch (error) {
    console.error('获取历史记录失败:', error)
  }
}

const viewReport = (id) => {
  router.push(`/report/${id}`)
}

const deleteItem = async (id) => {
  if (confirm('确定要删除这条记录吗？')) {
    try {
      await deleteHistory(id)
      fetchHistoryList()
    } catch (error) {
      console.error('删除失败:', error)
    }
  }
}
</script>

<style scoped>
.history {
  padding: 20px;
}

.history h1 {
  margin-bottom: 20px;
  font-size: 24px;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.item-info h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
}

.item-info p {
  margin: 0 0 8px 0;
  color: #666;
  font-size: 14px;
}

.status {
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.status.success {
  background: #f6ffed;
  color: #52c41a;
}

.status.processing {
  background: #e6f7ff;
  color: #1890ff;
}

.status.failed {
  background: #fff2f0;
  color: #ff4d4f;
}

.item-actions {
  display: flex;
  gap: 12px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.btn-primary {
  background: #1890ff;
  color: #fff;
}

.btn-primary:hover {
  background: #40a9ff;
}

.btn-danger {
  background: #ff4d4f;
  color: #fff;
}

.btn-danger:hover {
  background: #ff7875;
}

.empty {
  text-align: center;
  padding: 60px 0;
}

.empty p {
  margin-bottom: 20px;
  color: #666;
}
</style>
