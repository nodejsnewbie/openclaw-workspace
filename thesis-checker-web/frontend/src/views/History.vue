<template>
  <div class="history">
    <h1>历史记录</h1>
    <div class="history-list">
      <div v-for="item in historyList" :key="item.id" class="history-item">
        <div class="item-info">
          <h3>{{ item.title }}</h3>
          <p>{{ item.created_at }}</p>
          <span :class="['status', item.status]">{{ getStatusText(item.status) }}</span>
        </div>
        <div class="item-actions">
          <el-button @click="viewReport(item.id)" type="primary" :disabled="item.status !== 'completed'">查看报告</el-button>
          <el-button @click="deleteItem(item.id)" type="danger">删除</el-button>
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
import { getThesisHistory, deleteThesis } from '@/api/thesis'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const historyList = ref([])

onMounted(() => {
  fetchHistoryList()
})

const getStatusText = (status) => {
  const statusMap = {
    uploaded: '已上传',
    checking: '检查中',
    completed: '已完成',
    failed: '检查失败'
  }
  return statusMap[status] || status
}

const fetchHistoryList = async () => {
  try {
    const res = await getThesisHistory()
    historyList.value = res
  } catch (error) {
    ElMessage.error('获取历史记录失败')
  }
}

const viewReport = (id) => {
  router.push(`/report/${id}`)
}

const deleteItem = (id) => {
  ElMessageBox.confirm('确定要删除这条检查记录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteThesis(id)
      ElMessage.success('删除成功')
      fetchHistoryList()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  })
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

.status.completed {
  background: #f6ffed;
  color: #52c41a;
}

.status.checking {
  background: #e6f7ff;
  color: #1890ff;
}

.status.failed {
  background: #fff2f0;
  color: #ff4d4f;
}

.status.uploaded {
  background: #f5f5f5;
  color: #8c8c8c;
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
