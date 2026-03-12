import { defineStore } from 'pinia'
import { login, getUserProfile } from '@/api/auth'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: null,
    isAdmin: false
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
      ElMessage.success('已退出登录')
    }
  }
})
