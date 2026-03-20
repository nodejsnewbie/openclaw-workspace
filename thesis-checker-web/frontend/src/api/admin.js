import request from '@/utils/request'

export function getRequirements() {
  return request({
    url: '/admin/requirements',
    method: 'get'
  })
}

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

export function deleteRequirement(id) {
  return request({
    url: `/admin/requirements/${id}`,
    method: 'delete'
  })
}

export function getUsers() {
  return request({
    url: '/admin/users',
    method: 'get'
  })
}
