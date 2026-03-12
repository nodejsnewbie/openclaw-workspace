<template>
  <div class="users-container">
    <el-card>
      <template #header>
        <div class="header">
          <span>用户管理</span>
        </div>
      </template>
      <el-table :data="users" style="width: 100%" v-loading="loading">
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="is_admin" label="管理员">
          <template #default="scope">
            <el-tag :type="scope.row.is_admin ? 'warning' : 'info'">
              {{ scope.row.is_admin ? '管理员' : '普通用户' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="注册时间" width="180" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getUsers } from '@/api/admin'

const users = ref([])
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  try {
    users.value = await getUsers()
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.users-container {
  padding: 20px;
}
</style>
