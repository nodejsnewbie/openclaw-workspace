import request from '@/utils/request'

// 获取格式要求列表
export function getRequirements() {
  return request({
    url: '/admin/requirements',
    method: 'get'
  })
}

// 创建格式要求
export function createRequirement(data) {
  return request({
    url: '/admin/requirements',
    method: 'post',
    data
  })
}

// 更新格式要求
export function updateRequirement(id, data) {
  return request({
    url: `/admin/requirements/${id}`,
    method: 'put',
    data
  })
}

// 删除格式要求
export function deleteRequirement(id) {
  return request({
    url: `/admin/requirements/${id}`,
    method: 'delete'
  })
}

// 获取用户列表
export function getUsers() {
  return request({
    url: '/admin/users',
    method: 'get'
  })
}

// 切换用户管理员角色
export function toggleAdminRole(id) {
  return request({
    url: `/admin/users/${id}/toggle-admin`,
    method: 'post'
  })
}

// 删除用户
export function deleteUser(id) {
  return request({
    url: `/admin/users/${id}`,
    method: 'delete'
  })
}
