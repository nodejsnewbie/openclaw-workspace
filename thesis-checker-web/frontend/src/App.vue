<template>
  <div id="app">
    <el-config-provider :locale="zhCn">
      <router-view />
    </el-config-provider>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import { useUserStore } from '@/store/user'

const userStore = useUserStore()

/**
 * 应用启动时，若本地存有 token，立即重新拉取用户信息。
 * 这确保了页面刷新后 isAdmin / userInfo 能正确恢复，
 * 而不依赖 localStorage 中可能过时的缓存值。
 */
onMounted(async () => {
  if (userStore.token && !userStore.userInfo) {
    try {
      await userStore.getUserInfo()
    } catch {
      // token 过期或无效，getUserInfo 内部已处理登出逻辑
    }
  }
})
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background-color: #f5f7fa;
}

#app {
  min-height: 100vh;
}
</style>
