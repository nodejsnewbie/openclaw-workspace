import { defineStore } from 'pinia'
import { login, getUserProfile } from '@/api/auth'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: null,
    // NOTE: isAdmin 同样从 localStorage 恢复，防止页面刷新后状态丢失
    isAdmin: localStorage.getItem('isAdmin') === 'true'
  }),
  
  getters: {
    isLoggedIn: (state) => !!state.token,
    username: (state) => state.userInfo?.username || ''
  },
  
  actions: {
    async login(username, password) {
      try {
        const res = await login(username, password)
        this.token = res.access_token
        this.isAdmin = res.is_admin
        localStorage.setItem('token', res.access_token)
        localStorage.setItem('isAdmin', String(res.is_admin))
        
        await this.getUserInfo()
        ElMessage.success('登录成功')
        return Promise.resolve()
      } catch (error) {
        ElMessage.error(error.response?.data?.detail || '登录失败')
        return Promise.reject(error)
      }
    },
    
    async getUserInfo() {
      try {
        const res = await getUserProfile()
        this.userInfo = res
        this.isAdmin = res.is_admin
        // NOTE: 同步写入 localStorage，确保页面刷新后仍可正确识别管理员身份
        localStorage.setItem('isAdmin', String(res.is_admin))
        return Promise.resolve(res)
      } catch (error) {
        this.logout()
        return Promise.reject(error)
      }
    },
    
    logout() {
      this.token = ''
      this.userInfo = null
      this.isAdmin = false
      localStorage.removeItem('token')
      localStorage.removeItem('isAdmin')
      ElMessage.success('已退出登录')
    }
  }
})
