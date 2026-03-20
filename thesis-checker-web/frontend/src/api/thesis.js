import request from '@/utils/request'

export function uploadThesis(title, file) {
  const formData = new FormData()
  formData.append('title', title)
  formData.append('file', file)
  return request({
    url: '/thesis/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
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
