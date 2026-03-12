import request from '@/utils/request'

// 上传论文
export function uploadThesis(data) {
  return request({
    url: '/thesis/upload',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

// 获取历史记录
export function getHistoryList() {
  return request({
    url: '/thesis/history',
    method: 'get'
  })
}

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
