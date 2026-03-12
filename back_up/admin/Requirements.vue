<template>
  <div class="requirements-container">
    <el-card>
      <template #header>
        <div class="header">
          <span>格式要求管理</span>
        </div>
      </template>
      <el-table :data="requirements" style="width: 100%" v-loading="loading">
        <el-table-column prop="name" label="名称" />
        <el-table-column prop="type" label="类型" />
        <el-table-column prop="major" label="专业" />
        <el-table-column label="操作">
          <template #default="scope">
            <el-button type="danger" size="small" @click="handleDelete(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRequirements, deleteRequirement } from '@/api/admin'
import { ElMessage } from 'element-plus'

const requirements = ref([])
const loading = ref(false)

const loadData = async () => {
  loading.value = true
  try {
    requirements.value = await getRequirements()
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const handleDelete = async (id) => {
  try {
    await deleteRequirement(id)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    ElMessage.error('删除失败')
  }
}

onMounted(loadData)
</script>

<style scoped>
.requirements-container {
  padding: 20px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
