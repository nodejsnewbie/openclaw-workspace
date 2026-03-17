import request from '@/utils/request'

export function login(username, password) {
  const params = new URLSearchParams()
  params.append('username', username)
  params.append('password', password)
  return request({
    url: '/token',
    method: 'post',
    data: params,
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
