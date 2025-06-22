import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import DashboardView from '../views/DashboardView.vue';
import MemberListView from '../views/MemberListView.vue';
import MemberDetailView from '../views/MemberDetailView.vue';
import MemberFormView from '../views/MemberFormView.vue';
import PengurusListView from '../views/PengurusListView.vue';
import PengurusDetailView from '../views/PengurusDetailView.vue';
import PengurusFormView from '../views/PengurusFormView.vue';

const routes = [
  {
    path: '/',
    name: 'Login',
    component: LoginView
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: DashboardView
  },
  {
    path: '/members',
    name: 'MemberList',
    component: MemberListView
  },
  {
    path: '/members/add',
    name: 'MemberAdd',
    component: MemberFormView
  },
  {
    path: '/members/:id',
    name: 'MemberDetail',
    component: MemberDetailView
  },
  {
    path: '/members/:id/edit',
    name: 'MemberEdit',
    component: MemberFormView
  },
  {
    path: '/pengurus',
    name: 'PengurusList',
    component: PengurusListView
  },
  {
    path: '/pengurus/add',
    name: 'PengurusAdd',
    component: PengurusFormView
  },
  {
    path: '/pengurus/:id',
    name: 'PengurusDetail',
    component: PengurusDetailView
  },
  {
    path: '/pengurus/:id/edit',
    name: 'PengurusEdit',
    component: PengurusFormView
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
});

// Route guard: hanya izinkan akses jika user sudah login (kecuali Login)
router.beforeEach((to, from, next) => {
  const publicPages = ['Login'];
  const authRequired = !publicPages.includes(to.name);
  const token = localStorage.getItem('token');
  if (authRequired && !token) {
    return next({ name: 'Login' });
  }
  if (to.name === 'Login' && token) {
    return next({ name: 'Dashboard' });
  }
  next();
});

export default router;
