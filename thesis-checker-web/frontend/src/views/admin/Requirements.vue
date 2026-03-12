<template>
  <div class="requirements">
    <h1>格式要求管理</h1>
    <div class="actions">
      <button @click="addRequirement" class="btn btn-primary">添加要求</button>
    </div>
    <div class="requirement-list">
      <div v-for="item in requirementList" :key="item.id" class="requirement-item">
        <div class="item-header">
          <h3>{{ item.name }}</h3>
          <div class="item-actions">
            <button @click="editRequirement(item)" class="btn btn-small">编辑</button>
            <button @click="removeRequirement(item.id)" class="btn btn-small btn-danger">删除</button>
          </div>
        </div>
        <div class="item-content">
          <p v-html="item.description"></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRequirements, deleteRequirement } from '@/api/admin'

const requirementList = ref([])

onMounted(() => {
  fetchRequirements()
})

const fetchRequirements = async () => {
  try {
    const res = await getRequirements()
    requirementList.value = res.data
  } catch (error) {
    console.error('获取格式要求失败:', error)
  }
}

const addRequirement = () => {
  // TODO: 实现添加功能
  alert('待实现')
}

const editRequirement = (item) => {
  // TODO: 实现编辑功能
  alert('待实现')
}

const removeRequirement = async (id) => {
  if (confirm('确定要删除这条格式要求吗？')) {
    try {
      await deleteRequirement(id)
      fetchRequirements()
    } catch (error) {
      console.error('删除失败:', error)
    }
  }
}
</script>

<style scoped>
.requirements {
  padding: 20px;
}

.requirements h1 {
  margin-bottom: 20px;
  font-size: 24px;
}

.actions {
  margin-bottom: 20px;
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

.btn-small {
  padding: 4px 8px;
  font-size: 12px;
}

.btn-danger {
  background: #ff4d4f;
  color: #fff;
}

.btn-danger:hover {
  background: #ff7875;
}

.requirement-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.requirement-item {
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.item-header h3 {
  margin: 0;
  font-size: 18px;
}

.item-actions {
  display: flex;
  gap: 8px;
}

.item-content {
  color: #666;
  line-height: 1.6;
}
</style>
