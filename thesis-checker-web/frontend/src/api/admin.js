import request from '@/utils/request'

<<<<<<< HEAD
=======
// 获取格式要求列表
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
export function getRequirements() {
  return request({
    url: '/admin/requirements',
    method: 'get'
  })
}

<<<<<<< HEAD
export function uploadRequirement(data) {
  const formData = new FormData()
  formData.append('name', data.name)
  formData.append('type', data.type)
  if (data.major) {
    formData.append('major', data.major)
  }
  formData.append('file', data.file)
  return request({
    url: '/admin/requirements',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

=======
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
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
export function deleteRequirement(id) {
  return request({
    url: `/admin/requirements/${id}`,
    method: 'delete'
  })
}

<<<<<<< HEAD
=======
// 获取用户列表
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
export function getUsers() {
  return request({
    url: '/admin/users',
    method: 'get'
  })
}
<<<<<<< HEAD
=======

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
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
