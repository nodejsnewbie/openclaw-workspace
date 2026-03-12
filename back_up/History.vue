<template>
  <div class="history-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>历史检查记录</span>
        </div>
      </template>
      <el-table :data="historyList" style="width: 100%" v-loading="loading">
        <el-table-column prop="title" label="论文标题" />
        <el-table-column prop="filename" label="文件名" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">{{ getStatusText(scope.row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="时间" width="180" />
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button type="primary" size="small" @click="$router.push(`/report/${scope.row.id}`)" :disabled="scope.row.status !== 'completed'">查看报告</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getThesisHistory } from '@/api/thesis'

const historyList = ref([])
const loading = ref(false)

const getStatusType = (status) => {
  const statusMap = { uploaded: 'info', checking: 'warning', completed: 'success', failed: 'danger' }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = { uploaded: '已上传', checking: '检查中', completed: '已完成', failed: '检查失败' }
  return statusMap[status] || status
}

onMounted(async () => {
  loading.value = true
  try {
    const res = await getThesisHistory()
    historyList.value = res
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.history-container {
  padding: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
