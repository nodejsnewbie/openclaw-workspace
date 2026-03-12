<template>
  <div class="users">
    <h1>用户管理</h1>
    <div class="user-table">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>用户名</th>
            <th>邮箱</th>
            <th>角色</th>
            <th>注册时间</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in userList" :key="user.id">
            <td>{{ user.id }}</td>
            <td>{{ user.username }}</td>
            <td>{{ user.email }}</td>
            <td>{{ user.role === 'admin' ? '管理员' : '普通用户' }}</td>
            <td>{{ user.createTime }}</td>
            <td>
              <button @click="toggleAdmin(user)" class="btn btn-small">
                {{ user.role === 'admin' ? '取消管理员' : '设为管理员' }}
              </button>
              <button @click="removeUser(user.id)" class="btn btn-small btn-danger">删除</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getUsers, toggleAdminRole, deleteUser } from '@/api/admin'

const userList = ref([])

onMounted(() => {
  fetchUsers()
})

const fetchUsers = async () => {
  try {
    const res = await getUsers()
    userList.value = res.data
  } catch (error) {
    console.error('获取用户列表失败:', error)
  }
}

const toggleAdmin = async (user) => {
  const action = user.role === 'admin' ? '取消管理员' : '设为管理员'
  if (confirm(`确定要${action}吗？`)) {
    try {
      await toggleAdminRole(user.id)
      fetchUsers()
    } catch (error) {
      console.error('操作失败:', error)
    }
  }
}

const removeUser = async (id) => {
  if (confirm('确定要删除这个用户吗？')) {
    try {
      await deleteUser(id)
      fetchUsers()
    } catch (error) {
      console.error('删除失败:', error)
    }
  }
}
</script>

<style scoped>
.users {
  padding: 20px;
}

.users h1 {
  margin-bottom: 20px;
  font-size: 24px;
}

.user-table {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid #f0f0f0;
}

th {
  background: #fafafa;
  font-weight: 500;
}

.btn {
  padding: 4px 8px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  margin-right: 8px;
}

.btn:hover {
  opacity: 0.8;
}

.btn-danger {
  background: #ff4d4f;
  color: #fff;
}
</style>
