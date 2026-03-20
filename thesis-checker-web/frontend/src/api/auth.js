import request from '@/utils/request'

export function login(username, password) {
  const formData = new FormData()
  formData.append('username', username)
  formData.append('password', password)
  formData.append('grant_type', 'password')
  return request({
    url: '/token',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  })
}

export function register(data) {
  return request({
    url: '/auth/register',
    method: 'post',
    data
  })
}

export function getUserProfile() {
  return request({
    url: '/auth/profile',
    method: 'get'
  })
}
