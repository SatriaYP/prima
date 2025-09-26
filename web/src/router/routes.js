export default [
  {
    path: "/",
    redirect: "/login",
  },
  {
    path: "/login",
    name: "Login",
    component: () => import("@/views/auth/LoginView.vue"),
    meta: {
      layout: "AuthLayout",
      requiresGuest: true,
    },
  },
  {
    path: "/dashboard",
    name: "Dashboard",
    component: () => import("@/views/DashboardView.vue"),
    meta: {
      layout: "DashboardLayout",
      requiresAuth: true,
    },
  },
  {
    path: "/member",
    name: "Member",
    component: () => import("@/views/MemberView.vue"),
    meta: {
      title: "List Anggota",
      layout: "DashboardLayout",
      requiresAuth: true,
    },
  },
  {
    path: "/member/create-new-member",
    name: "AddMember",
    component: () => import("@/views/AddNewMember.vue"),
    meta: {
      title: "Tambah Anggota Baru",
      layout: "DashboardLayout",
      requiresAuth: true,
    },
  },
  {
    path: "/member/:id/edit",
    name: "EditMember",
    component: () => import("@/views/AddNewMember.vue"), // 👈 gunakan komponen yang sama
    meta: {
      title: "Edit Anggota",
      layout: "DashboardLayout",
      requiresAuth: true,
    },
  },
  {
    path: "/pengurus",
    name: "Official",
    component: () => import("@/views/KepengurusanView.vue"),
    // component: () => import("@/views/OfficialView.vue"),
    meta: {
      layout: "DashboardLayout",
      requiresAuth: true,
    },
  },
  {
    path: "/kesekretariatan",
    name: "Kesekretariatan",
    component: () => import("@/views/KesekretariatanView.vue"),
    meta: {
      title: "Kesekretariatan",
      layout: "DashboardLayout",
      requiresAuth: true,
    },
  },



  //   {
  //     path: "/",
  //     component: () => import("@/layouts/DefaultLayout.vue"),
  //     children: [...userRoutes],
  //   },
  //   {
  //     path: "/:pathMatch(.*)*",
  //     name: "NotFound",
  //     component: () => import("@/views/NotFound.vue"),
  //   },
];
