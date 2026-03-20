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
    data: formData
    // NOTE: 不要手动设置 Content-Type，鉴于此为 FormData，
    // axios 会自动添加带 boundary 的 multipart/form-data 头
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

// ── 书写模板 API ──────────────────────────
export function getTemplates() {
  return request({
    url: '/admin/templates',
    method: 'get'
  })
}

export function uploadTemplate(data) {
  const formData = new FormData()
  formData.append('name', data.name)
  formData.append('category', data.category)
  if (data.description) formData.append('description', data.description)
  formData.append('file', data.file)
  return request({
    url: '/admin/templates',
    method: 'post',
    data: formData
    // NOTE: 同上，不要手动设置 Content-Type，防止丢失 boundary
  })
}

export function deleteTemplate(id) {
  return request({
    url: `/admin/templates/${id}`,
    method: 'delete'
  })
}
