<template>
  <div class="admin-layout">
    <div class="sidebar">
      <h2>管理后台</h2>
      <div class="menu">
        <router-link to="/admin/requirements" class="menu-item">格式要求管理</router-link>
        <router-link to="/admin/users" class="menu-item">用户管理</router-link>
      </div>
    </div>
    <div class="content">
      <router-view />
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
.admin-layout {
  display: flex;
  height: calc(100vh - 64px);
}

.sidebar {
  width: 240px;
  background: #001529;
  color: #fff;
  padding: 20px 0;
}

.sidebar h2 {
  padding: 0 20px;
  margin: 0 0 30px 0;
  font-size: 18px;
}

.menu {
  display: flex;
  flex-direction: column;
}

.menu-item {
  padding: 12px 20px;
  color: rgba(255, 255, 255, 0.65);
  text-decoration: none;
  transition: all 0.3s;
}

.menu-item:hover,
.menu-item.router-link-active {
  background: #1890ff;
  color: #fff;
}

.content {
  flex: 1;
  padding: 20px;
  background: #f0f2f5;
  overflow: auto;
}
</style>
