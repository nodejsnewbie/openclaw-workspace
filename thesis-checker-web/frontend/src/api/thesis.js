import request from '@/utils/request'

export function uploadThesis(title, file) {
  const formData = new FormData()
  formData.append('title', title)
  formData.append('file', file)
  return request({
    url: '/thesis/upload',
    method: 'post',
    data: formData
    // NOTE: 不手动设置 Content-Type，让 axios 自动带上正确的带 boundary 的值
  })
}

export function getThesisInfo(thesisId) {
  return request({
    url: `/thesis/${thesisId}`,
    method: 'get'
  })
}

export function checkThesis(thesisId) {
  return request({
    url: `/thesis/check/${thesisId}`,
    method: 'post'
  })
}

export function getThesisReport(thesisId) {
  return request({
    url: `/thesis/report/${thesisId}`,
    method: 'get'
  })
}

export function getThesisHistory() {
  return request({
    url: '/thesis/history',
    method: 'get'
  })
}

export function downloadThesisReport(thesisId) {
  return request({
    url: `/thesis/report/${thesisId}/download`,
    method: 'get',
    responseType: 'blob'
  })
}
export function deleteThesis(thesisId) {
  return request({
    url: `/thesis/${thesisId}`,
    method: 'delete'
  })
}
