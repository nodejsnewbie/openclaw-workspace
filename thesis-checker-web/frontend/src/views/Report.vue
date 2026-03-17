<template>
  <div class="report-container">
    <el-card class="report-header">
      <div class="header-content">
        <div>
          <h1>论文检查报告</h1>
          <p class="sub-title">论文标题：{{ thesisInfo?.title }} | 文件名：{{ thesisInfo?.filename }}</p>
        </div>
        <div class="header-actions">
          <el-tag v-if="thesisInfo?.status === 'checking'" type="warning" class="status-tag">
            <el-icon class="is-loading"><Loading /></el-icon> 检查中...
          </el-tag>
          <el-tag v-else-if="thesisInfo?.status === 'failed'" type="danger" class="status-tag">检查失败</el-tag>
          
          <el-button v-if="thesisInfo?.status !== 'checking'" type="warning" :loading="checking" @click="handleRecheck">
            <el-icon><Refresh /></el-icon>
            重新检查
          </el-button>
          <el-button v-if="thesisInfo?.status === 'completed'" type="primary" @click="downloadReport">
            <el-icon><Download /></el-icon>
            下载报告
          </el-button>
          <el-button @click="$router.go(-1)">返回</el-button>
        </div>
      </div>
    </el-card>

    <el-card v-if="thesisInfo?.status === 'checking'" class="checking-card">
      <el-result title="论文检查中" sub-title="Kimi k2.5 正在深度解析您的论文，请稍候...">
        <template #icon>
          <el-icon :size="60" class="is-loading"><Loading /></el-icon>
        </template>
        <template #extra>
          <p>预计需要 1-2 分钟，页面会自动刷新结果</p>
        </template>
      </el-result>
    </el-card>

    <div v-else-if="thesisInfo?.status === 'completed'">
      <el-row :gutter="20" class="summary-row">
        <!-- ... 原有的综合评分和摘要统计 ... -->
        <el-col :span="6">
          <el-card class="score-card">
            <div class="score-circle" :style="scoreStyle">
              <div class="score-number">{{ reportData?.score || 0 }}</div>
              <div class="score-label">综合评分</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="18">
          <el-card class="stats-card">
            <el-row :gutter="20">
              <el-col :span="8">
                <div class="stat-item">
                  <div class="stat-number danger">{{ issueStats.total || 0 }}</div>
                  <div class="stat-label">总问题数</div>
                </div>
              </el-col>
              <el-col :span="8">
                <div class="stat-item">
                  <div class="stat-number warning">{{ issueStats.high || 0 }}</div>
                  <div class="stat-label">高优先级问题</div>
                </div>
              </el-col>
              <el-col :span="8">
                <div class="stat-item">
                  <div class="stat-number info">{{ issueStats.low || 0 }}</div>
                  <div class="stat-label">优化建议</div>
                </div>
              </el-col>
            </el-row>
            <div class="summary-text" style="margin-top: 20px">
              <strong>检查摘要：</strong>{{ reportData?.summary || '暂无摘要' }}
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-card class="issues-card">
        <h3>问题详情</h3>
        <el-tabs v-model="activeTab" type="border-card">
          <el-tab-pane label="全部问题" name="all">
            <issue-list :issues="reportData?.issues || []" />
          </el-tab-pane>
          <el-tab-pane label="格式问题" name="format">
            <issue-list :issues="formatIssues" />
          </el-tab-pane>
          <el-tab-pane label="内容建议" name="content">
            <issue-list :issues="contentIssues" />
          </el-tab-pane>
        </el-tabs>
      </el-card>

      <el-card class="suggestions-card">
        <h3>修改建议</h3>
        <div class="suggestion-content">
          <ul>
            <li>🔴 请优先修改高优先级问题，这些问题可能直接影响论文评审结果</li>
            <li>🟡 格式问题请对照学校发布的《毕业论文格式要求》逐一核对修改</li>
            <li>🟢 内容优化建议仅供参考，请根据实际研究内容进行调整</li>
            <li>修改完成后可以重新上传论文进行二次检查，确保所有问题都已解决</li>
          </ul>
        </div>
      </el-card>
    </div>

    <el-card v-else-if="thesisInfo?.status === 'failed'" class="failed-card">
      <el-result icon="error" title="检查失败" sub-title="可能由于文件损坏或 AI 服务超时导致。">
        <template #extra>
          <el-button type="primary" @click="handleRecheck">尝试重新检查</el-button>
        </template>
      </el-result>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { getThesisReport, downloadThesisReport, checkThesis, getThesisInfo } from '@/api/thesis'
import { ElMessage } from 'element-plus'
import { Download, Refresh, Loading } from '@element-plus/icons-vue'
import IssueList from '@/components/IssueList.vue'

const route = useRoute()
const thesisId = route.params.id

const thesisInfo = ref(null)
const reportData = ref(null)
const activeTab = ref('all')
const checking = ref(false)

const issueStats = computed(() => {
  if (!reportData.value?.issues) {
    return { total: 0, high: 0, medium: 0, low: 0 }
  }
  const issues = reportData.value.issues
  return {
    total: issues.length,
    high: issues.filter(i => i.severity === 'high').length,
    medium: issues.filter(i => i.severity === 'medium').length,
    low: issues.filter(i => i.severity === 'low').length
  }
})

const scoreStyle = computed(() => {
  const score = reportData.value?.score || 0
  let color = '#67c23a' // 绿色
  if (score < 60) color = '#f56c6c' // 红色
  else if (score < 80) color = '#e6a23c' // 黄色
  return {
    background: `conic-gradient(${color} ${score * 3.6}deg, #ebeef5 0deg)`
  }
})

const formatIssues = computed(() => {
  return reportData.value?.issues?.filter(i => i.type === '格式问题') || []
})

const contentIssues = computed(() => {
  return reportData.value?.issues?.filter(i => i.type === '内容建议') || []
})

let pollTimer = null

const loadReport = async () => {
  try {
    const info = await getThesisInfo(thesisId)
    thesisInfo.value = info
    
    if (info.status === 'completed') {
      const report = await getThesisReport(thesisId)
      reportData.value = report
      if (pollTimer) {
        clearInterval(pollTimer)
        pollTimer = null
      }
    } else if (info.status === 'checking') {
      // 启动轮询
      if (!pollTimer) {
        pollTimer = setInterval(loadReport, 5000)
      }
    } else {
      if (pollTimer) {
        clearInterval(pollTimer)
        pollTimer = null
      }
    }
  } catch (error) {
    console.error('加载详情失败', error)
  }
}

const downloadReport = async () => {
  try {
    const blob = await downloadThesisReport(thesisId)
    const url = window.URL.createObjectURL(new Blob([blob]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', `论文检查报告_${reportData.value?.title || thesisId}.md`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    ElMessage.success('报告下载成功')
  } catch (error) {
    ElMessage.error('下载报告失败')
    console.error(error)
  }
}

const handleRecheck = async () => {
  checking.value = true
  try {
    await checkThesis(thesisId)
    ElMessage.success('重新检查完成')
    await loadReport()
  } catch (error) {
    ElMessage.error('重新检查失败')
  } finally {
    checking.value = false
  }
}

onMounted(() => {
  loadReport()
})
</script>

<style scoped>
.report-container {
  padding: 20px;
}

.report-header {
  margin-bottom: 20px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-content h1 {
  margin: 0 0 10px 0;
  font-size: 28px;
  color: #303133;
}

.sub-title {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.summary-row {
  margin-bottom: 20px;
}

.score-card {
  text-align: center;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.score-circle {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.score-circle::before {
  content: '';
  position: absolute;
  width: 100px;
  height: 100px;
  background: #fff;
  border-radius: 50%;
}

.score-number {
  font-size: 36px;
  font-weight: bold;
  color: #303133;
  z-index: 1;
}

.score-label {
  font-size: 14px;
  color: #909399;
  z-index: 1;
}

.stats-card {
  height: 100%;
}

.stat-item {
  text-align: center;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 5px;
}

.stat-number.danger {
  color: #f56c6c;
}

.stat-number.warning {
  color: #e6a23c;
}

.stat-number.info {
  color: #909399;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.summary-text {
  padding: 15px;
  background: #f5f7fa;
  border-radius: 8px;
  line-height: 1.6;
}

.suggestions-card {
  margin-bottom: 20px;
}

.issues-card h3, .suggestions-card h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  color: #303133;
}

.suggestion-content ul {
  margin: 0;
  padding-left: 20px;
}

.suggestion-content li {
  margin-bottom: 8px;
  line-height: 1.6;
}
.status-tag {
  margin-right: 15px;
  padding: 0 15px;
  height: 32px;
  font-weight: bold;
}

.checking-card, .failed-card {
  height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
