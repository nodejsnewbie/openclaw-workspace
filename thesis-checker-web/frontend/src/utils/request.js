import axios from 'axios'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'
import router from '@/router'

// API 地址配置 (Cloud Studio生产环境)
const baseURL = 'https://6be1b975cf624542ac1ac5c18f7fe421.codebuddy.cloudstudio.run/api'
console.log('API Base URL:', baseURL)

const service = axios.create({
  baseURL: baseURL,
  timeout: 30000
})

service.interceptors.request.use(
  config => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    console.log('Request:', config.baseURL + config.url, config.data)
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

service.interceptors.response.use(
  response => {
    console.log('Response:', response.data)
    return response.data
  },
  error => {
    console.error('Error:', error)
    if (error.response) {
      console.error('Response error:', error.response.data)
      switch (error.response.status) {
        case 401:
          ElMessage.error('登录已过期，请重新登录')
          const userStore = useUserStore()
          userStore.logout()
          router.push('/login')
          break
        case 403:
          ElMessage.error('权限不足，无法访问')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error('服务器错误，请稍后重试')
          break
        default:
          ElMessage.error(error.response.data?.detail || '请求失败')
      }
    } else {
      console.error('Network error:', error.message)
      ElMessage.error('网络连接失败，请检查网络')
    }
    return Promise.reject(error)
  }
)

export default service
