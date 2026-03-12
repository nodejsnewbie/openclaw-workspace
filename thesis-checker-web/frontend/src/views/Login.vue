<template>
  <div class="login-container">
    <div class="login-card">
      <h2 class="login-title">毕业论文检查系统</h2>
      <el-form ref="loginForm" :model="loginForm" label-width="80px" class="login-form">
        <el-form-item label="用户名" prop="username" :rules="[
          { required: true, message: '请输入用户名', trigger: 'blur' }
        ]">
          <el-input v-model="loginForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password" :rules="[
          { required: true, message: '请输入密码', trigger: 'blur' }
        ]">
          <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleLogin" :loading="loading" style="width: 100%">
            登录
          </el-button>
        </el-form-item>
        <el-form-item>
          <div style="text-align: center">
            <el-link type="primary" @click="showRegister = !showRegister">
              {{ showRegister ? '返回登录' : '注册账号' }}
            </el-link>
          </div>
        </el-form-item>
      </el-form>

      <el-dialog v-model="showRegister" title="用户注册" width="400px">
        <el-form ref="registerForm" :model="registerForm" label-width="80px">
          <el-form-item label="用户名" prop="username" :rules="[
            { required: true, message: '请输入用户名', trigger: 'blur' }
          ]">
            <el-input v-model="registerForm.username" placeholder="请输入用户名" />
          </el-form-item>
          <el-form-item label="邮箱" prop="email" :rules="[
            { required: true, message: '请输入邮箱', trigger: 'blur' },
            { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
          ]">
            <el-input v-model="registerForm.email" placeholder="请输入邮箱" />
          </el-form-item>
          <el-form-item label="密码" prop="password" :rules="[
            { required: true, message: '请输入密码', trigger: 'blur' },
            { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
          ]">
            <el-input v-model="registerForm.password" type="password" placeholder="请输入密码" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="showRegister = false">取消</el-button>
          <el-button type="primary" @click="handleRegister" :loading="registerLoading">
            注册
          </el-button>
        </template>
      </el-dialog>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useUserStore } from '@/store/user'
import { useRouter } from 'vue-router'
import { register } from '@/api/auth'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const router = useRouter()

const loading = ref(false)
const registerLoading = ref(false)
const showRegister = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const registerForm = reactive({
  username: '',
  email: '',
  password: ''
})

const handleLogin = async () => {
  loading.value = true
  try {
    await userStore.login(loginForm.username, loginForm.password)
    router.push('/')
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  registerLoading.value = true
  try {
    await register(registerForm)
    ElMessage.success('注册成功，请登录')
    showRegister.value = false
    loginForm.username = registerForm.username
    loginForm.password = registerForm.password
  } finally {
    registerLoading.value = false
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
  background: #fff;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
  width: 400px;
}

.login-title {
  text-align: center;
  margin-bottom: 30px;
  color: #303133;
  font-size: 24px;
  font-weight: bold;
}

.login-form {
  margin-top: 20px;
}
</style>
