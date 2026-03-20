<template>
  <div class="login-page">
    <div class="login-box">
      <h2 class="title">毕业论文检查系统</h2>

      <div class="form-group">
        <label for="username">用户名</label>
        <input
          id="username"
          v-model="username"
          type="text"
          autocomplete="username"
          placeholder="请输入用户名"
          class="form-input"
        />
      </div>

      <div class="form-group">
        <label for="password">密码</label>
        <input
          id="password"
          v-model="password"
          type="password"
          autocomplete="current-password"
          placeholder="请输入密码"
          class="form-input"
          @keyup.enter="handleLogin"
        />
      </div>

      <button class="btn-login" :disabled="loading" @click="handleLogin">
        {{ loading ? '登录中...' : '登录' }}
      </button>

      <div class="register-link">
        <span @click="showRegisterDialog = true" style="cursor:pointer;color:#667eea;">注册账号</span>
      </div>

      <p v-if="errorMsg" class="error-msg">{{ errorMsg }}</p>
    </div>

    <!-- 注册弹窗 -->
    <div v-if="showRegisterDialog" class="modal-overlay" @click.self="showRegisterDialog = false">
      <div class="modal-box">
        <h3>用户注册</h3>
        <div class="form-group">
          <label>用户名</label>
          <input v-model="reg.username" type="text" class="form-input" placeholder="请输入用户名" />
        </div>
        <div class="form-group">
          <label>邮箱</label>
          <input v-model="reg.email" type="email" class="form-input" placeholder="请输入邮箱" />
        </div>
        <div class="form-group">
          <label>密码</label>
          <input v-model="reg.password" type="password" class="form-input" placeholder="至少6位密码" />
        </div>
        <p v-if="regError" class="error-msg">{{ regError }}</p>
        <div class="modal-footer">
          <button class="btn-cancel" @click="showRegisterDialog = false">取消</button>
          <button class="btn-login" :disabled="regLoading" @click="handleRegister">
            {{ regLoading ? '注册中...' : '注册' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { register } from '@/api/auth'

const router = useRouter()
const userStore = useUserStore()

const username = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')

const showRegisterDialog = ref(false)
const regLoading = ref(false)
const regError = ref('')
const reg = reactive({ username: '', email: '', password: '' })

const handleLogin = async () => {
  errorMsg.value = ''
  if (!username.value || !password.value) {
    errorMsg.value = '请输入用户名和密码'
    return
  }
  loading.value = true
  try {
    await userStore.login(username.value, password.value)
    router.push('/')
  } catch (err) {
    errorMsg.value = '用户名或密码错误，请重试'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  regError.value = ''
  if (!reg.username || !reg.email || !reg.password) {
    regError.value = '请填写所有必填项'
    return
  }
  if (reg.password.length < 6) {
    regError.value = '密码长度不能少于6位'
    return
  }
  regLoading.value = true
  try {
    await register(reg)
    username.value = reg.username
    password.value = reg.password
    showRegisterDialog.value = false
  } catch (err) {
    regError.value = '注册失败，用户名可能已存在'
  } finally {
    regLoading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-box {
  background: #fff;
  padding: 40px;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
  width: 380px;
}

.title {
  text-align: center;
  margin-bottom: 30px;
  color: #303133;
  font-size: 22px;
}

.form-group {
  margin-bottom: 18px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  color: #606266;
  font-size: 14px;
}

.form-input {
  width: 100%;
  height: 40px;
  padding: 0 12px;
  border: 1px solid #dcdfe6;
  border-radius: 6px;
  font-size: 14px;
  color: #303133;
  outline: none;
  box-sizing: border-box;
  transition: border-color 0.2s;
}

.form-input:focus {
  border-color: #667eea;
}

.btn-login {
  width: 100%;
  height: 42px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 15px;
  cursor: pointer;
  margin-top: 8px;
}

.btn-login:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.register-link {
  text-align: center;
  margin-top: 14px;
  font-size: 13px;
}

.error-msg {
  color: #f56c6c;
  font-size: 13px;
  margin-top: 10px;
  text-align: center;
}

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 999;
}

.modal-box {
  background: #fff;
  padding: 32px;
  border-radius: 10px;
  width: 360px;
}

.modal-box h3 {
  margin-bottom: 20px;
  font-size: 18px;
  color: #303133;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 16px;
}

.btn-cancel {
  height: 36px;
  padding: 0 20px;
  background: #f0f0f0;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
}
</style>
