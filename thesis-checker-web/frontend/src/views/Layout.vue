<template>
  <el-container style="height: 100vh">
    <el-aside width="250px" style="background-color: #2c3e50">
      <div class="logo">
        <h2 style="color: #fff; text-align: center; padding: 20px 0; margin: 0">
          论文检查系统
        </h2>
      </div>
      <el-menu
        :default-active="$route.path"
        class="el-menu-vertical-demo"
        background-color="#2c3e50"
        text-color="#fff"
        active-text-color="#409eff"
        router
      >
        <el-menu-item index="/">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </el-menu-item>
        <el-menu-item index="/upload">
          <el-icon><Upload /></el-icon>
          <span>上传论文</span>
        </el-menu-item>
        <el-menu-item index="/history">
          <el-icon><Document /></el-icon>
          <span>历史记录</span>
        </el-menu-item>
        <el-sub-menu index="/admin" v-if="userStore.isAdmin">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>管理中心</span>
          </template>
          <el-menu-item index="/admin/requirements">格式要求管理</el-menu-item>
          <el-menu-item index="/admin/users">用户管理</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header style="text-align: right; font-size: 12px; background: #fff; border-bottom: 1px solid #eee">
        <div style="line-height: 60px; padding: 0 20px">
          <span style="margin-right: 20px">欢迎，{{ userStore.username }}</span>
          <el-button type="danger" size="small" @click="handleLogout">退出登录</el-button>
        </div>
      </el-header>
      <el-main style="background-color: #f5f7fa; overflow-y: auto">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'
import { HomeFilled, Upload, Document, Setting } from '@element-plus/icons-vue'

const userStore = useUserStore()
const router = useRouter()

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.logo {
  border-bottom: 1px solid #34495e;
}

.el-menu {
  border-right: none;
}
</style>
