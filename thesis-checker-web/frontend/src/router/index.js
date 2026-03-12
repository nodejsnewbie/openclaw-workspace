import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/store/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { guest: true }
  },
  {
    path: '/',
    component: () => import('@/views/Layout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/Home.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'upload',
        name: 'Upload',
        component: () => import('@/views/Upload.vue'),
        meta: { title: '上传论文' }
      },
      {
        path: 'history',
        name: 'History',
        component: () => import('@/views/History.vue'),
        meta: { title: '历史记录' }
      },
      {
        path: 'report/:id',
        name: 'Report',
        component: () => import('@/views/Report.vue'),
        meta: { title: '检查报告' }
      },
      {
        path: 'admin',
        name: 'Admin',
        component: () => import('@/views/admin/Layout.vue'),
        meta: { requiresAdmin: true },
        children: [
          {
            path: 'requirements',
            name: 'AdminRequirements',
            component: () => import('@/views/admin/Requirements.vue'),
            meta: { title: '格式要求管理' }
          },
          {
            path: 'users',
            name: 'AdminUsers',
            component: () => import('@/views/admin/Users.vue'),
            meta: { title: '用户管理' }
          }
        ]
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  if (to.meta.requiresAuth && !userStore.isLoggedIn) {
    next('/login')
  } else if (to.meta.guest && userStore.isLoggedIn) {
    next('/')
  } else if (to.meta.requiresAdmin && !userStore.isAdmin) {
    next('/')
  } else {
    next()
  }
})

export default router
