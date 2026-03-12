import request from '@/utils/request'

<<<<<<< HEAD
export function uploadThesis(title, file) {
  const formData = new FormData()
  formData.append('title', title)
  formData.append('file', file)
  return request({
    url: '/thesis/upload',
    method: 'post',
    data: formData,
=======
// 上传论文
export function uploadThesis(data) {
  return request({
    url: '/thesis/upload',
    method: 'post',
    data,
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

<<<<<<< HEAD
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
=======
// 获取历史记录
export function getHistoryList() {
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
  return request({
    url: '/thesis/history',
    method: 'get'
  })
}
<<<<<<< HEAD
=======

// 获取检查报告
export function getReport(id) {
  return request({
    url: `/thesis/report/${id}`,
    method: 'get'
  })
}

// 检查论文
export function checkThesis(id) {
  return request({
    url: `/thesis/check/${id}`,
    method: 'post'
  })
}

// 删除历史记录
export function deleteHistory(id) {
  return request({
    url: `/thesis/history/${id}`,
    method: 'delete'
  })
}
>>>>>>> 680064f55e8c67ce67deed8e9eebceca581a767b
