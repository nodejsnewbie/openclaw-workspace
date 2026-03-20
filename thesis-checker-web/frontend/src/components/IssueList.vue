<template>
  <div v-if="issues.length === 0" class="empty-state">
    <el-empty description="该分类下暂无问题" />
  </div>
  <div v-else>
    <div v-for="(issue, index) in issues" :key="index" class="issue-item">
      <div class="issue-header">
        <el-tag :type="getSeverityType(issue.severity)" size="small">
          {{ getSeverityText(issue.severity) }}
        </el-tag>
        <span class="issue-position">{{ issue.position }}</span>
        <span class="issue-type">{{ issue.type }}</span>
      </div>
      <div class="issue-content">
        <p><strong>问题描述：</strong>{{ issue.description }}</p>
        <p><strong>修改建议：</strong>{{ issue.suggestion }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  issues: {
    type: Array,
    required: true
  }
})

const getSeverityType = (severity) => {
  const map = { high: 'danger', medium: 'warning', low: 'info' }
  return map[severity] || 'info'
}

const getSeverityText = (severity) => {
  const map = { high: '高优先级', medium: '中优先级', low: '低优先级' }
  return map[severity] || '低优先级'
}
</script>

<style scoped>
.issue-item {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
}

.issue-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
  gap: 10px;
}

.issue-position {
  font-weight: bold;
  color: #409eff;
}

.issue-type {
  color: #909399;
  margin-left: auto;
}

.issue-content p {
  margin: 5px 0;
  line-height: 1.6;
}

.empty-state {
  padding: 40px 0;
}
</style>
