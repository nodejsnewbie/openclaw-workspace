<template>
  <div class="home-container">
    <div class="welcome-card">
      <h1>欢迎使用毕业论文检查系统</h1>
      <p>快速检查论文格式，智能生成修改建议</p>
    </div>

    <el-row :gutter="20" class="stats-row">
      <el-col :span="8">
        <el-card class="stat-card">
          <div class="stat-item">
            <div class="stat-icon upload-icon">
              <el-icon><Upload /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.uploadCount }}</div>
              <div class="stat-label">已上传论文</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="stat-card">
          <div class="stat-item">
            <div class="stat-icon check-icon">
              <el-icon><Check /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.checkCount }}</div>
              <div class="stat-label">已完成检查</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="stat-card">
          <div class="stat-item">
            <div class="stat-icon avg-icon">
              <el-icon><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ stats.avgScore }}分</div>
              <div class="stat-label">平均得分</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="quick-actions">
      <h3>快速操作</h3>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-button type="primary" size="large" @click="$router.push('/upload')" style="width: 100%; height: 100px">
            <el-icon style="font-size: 32px; margin-bottom: 10px; display: block"><Upload /></el-icon>
            <div>上传论文</div>
          </el-button>
        </el-col>
        <el-col :span="6">
          <el-button type="success" size="large" @click="$router.push('/history')" style="width: 100%; height: 100px">
            <el-icon style="font-size: 32px; margin-bottom: 10px; display: block"><Document /></el-icon>
            <div>查看历史</div>
          </el-button>
        </el-col>
        <el-col :span="6" v-if="userStore.isAdmin">
          <el-button type="warning" size="large" @click="$router.push('/admin/requirements')" style="width: 100%; height: 100px">
            <el-icon style="font-size: 32px; margin-bottom: 10px; display: block"><Setting /></el-icon>
            <div>管理规范</div>
          </el-button>
        </el-col>
        <el-col :span="6" v-if="userStore.isAdmin">
          <el-button type="info" size="large" @click="$router.push('/admin/users')" style="width: 100%; height: 100px">
            <el-icon style="font-size: 32px; margin-bottom: 10px; display: block"><User /></el-icon>
            <div>用户管理</div>
          </el-button>
        </el-col>
      </el-row>
    </el-card>

    <el-card class="recent-reports" v-if="recentReports.length > 0">
      <h3>最近检查记录</h3>
      <el-table :data="recentReports" style="width: 100%">
        <el-table-column prop="title" label="论文标题" />
        <el-table-column prop="filename" label="文件名" width="200" />
        <el-table-column prop="status" label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">{{ getStatusText(scope.row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="上传时间" width="180" />
        <el-table-column label="操作" width="150">
          <template #default="scope">
            <el-button 
              type="primary" 
              size="small" 
              @click="$router.push(`/report/${scope.row.id}`)"
              :disabled="scope.row.status !== 'completed'"
            >
              查看报告
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '@/store/user'
import { getHistoryList } from '@/api/thesis'
import { Upload, Check, Star, Setting, User } from '@element-plus/icons-vue'

const userStore = useUserStore()
const stats = ref({
  uploadCount: 0,
  checkCount: 0,
  avgScore: 0
})
const recentReports = ref([])

const getStatusType = (status) => {
  const statusMap = {
    uploaded: 'info',
    checking: 'warning',
    completed: 'success',
    failed: 'danger'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = {
    uploaded: '已上传',
    checking: '检查中',
    completed: '已完成',
    failed: '检查失败'
  }
  return statusMap[status] || status
}

const loadData = async () => {
  try {
    const res = await getHistoryList()
    recentReports.value = res.data.slice(0, 5)
    stats.value.uploadCount = res.data.length
    stats.value.checkCount = res.data.filter(item => item.status === 'completed').length
    
    // 计算平均得分（需要从报告中获取）
    const completed = res.data.filter(item => item.status === 'completed')
    if (completed.length > 0) {
      stats.value.avgScore = 85 // 示例值，实际需要从报告中计算
    }
  } catch (error) {
    console.error('加载数据失败', error)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.home-container {
  padding: 20px;
}

.welcome-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  padding: 40px;
  border-radius: 12px;
  margin-bottom: 20px;
}

.welcome-card h1 {
  margin: 0 0 10px 0;
  font-size: 32px;
}

.welcome-card p {
  margin: 0;
  font-size: 16px;
  opacity: 0.9;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  height: 120px;
  display: flex;
  align-items: center;
}

.stat-item {
  display: flex;
  align-items: center;
  width: 100%;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: #fff;
  margin-right: 20px;
}

.upload-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.check-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.avg-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.quick-actions {
  margin-bottom: 20px;
}

.quick-actions h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  color: #303133;
}

.recent-reports h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  color: #303133;
}
</style>
