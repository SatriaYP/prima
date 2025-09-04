<script setup>
import { ref } from "vue";
import LoginView from "@/views/auth/LoginView.vue";

// Gambar carousel
const images = [
  "/images/banner-partai-prima.webp",
  "/images/banner-partai-prima.webp",
  "/images/banner-partai-prima.webp",
];

const currentIndex = ref(0);
// let intervalId = null;

setInterval(() => {
  currentIndex.value = (currentIndex.value + 1) % images.length;
}, 3000);

// const nextSlide = () => {
//   currentIndex.value = (currentIndex.value + 1) % images.length;
// };

// onMounted(() => {
//   intervalId = setInterval(nextSlide, 3000); // Ganti setiap 3 detik
// });

// onUnmounted(() => {
//   clearInterval(intervalId);
// });
</script>
<template>
  <div class="login-view">
    <!-- <div class="illustration">
      <img :src="images[currentIndex]" alt="Login Illustration" />
      <img src="@/assets/illustration.svg" alt="Login Illustration" />
      <img src="" alt="Login Illustration" />
      <h1>Looking for new Job?</h1>
      <p>We help in achieving your goals. Let’s get started!</p>
      <div class="indicator">
        <span
          v-for="(img, index) in images"
          :key="index"
          :class="{ active: currentIndex === index }"
        ></span>
      </div>
    </div> -->

    <LoginView />
  </div>
</template>
<style scoped>
.login-view {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background-color: #f3f2ff;
  text-align: center;
}

.illustration {
  margin-bottom: 2rem;
  position: relative;
}

.illustration img {
  width: 100%;
  max-width: 400px;
  height: 400px;
  object-fit: contain;
  transition: opacity 0.5s ease-in-out;
}

.illustration h1 {
  font-size: 1.8rem;
  margin-top: 1.5rem;
  color: #2c2c54;
}

.illustration p {
  font-size: 1rem;
  color: #555;
  max-width: 320px;
  margin: 0 auto;
}

/* Indicator dots */
.indicator {
  margin-top: 0.25rem;
  display: flex;
  justify-content: center;
  gap: 8px;
}

.indicator span {
  display: inline-block;
  width: 30px;
  height: 4px;
  background-color: #ccc;
  border-radius: 2px;
  transition: background-color 0.3s;
}

.indicator span.active {
  background-color: #4f46e5; /* Ungu atau sesuai tema */
}

@media (min-width: 768px) {
  .login-view {
    flex-direction: row;
    justify-content: space-around;
    text-align: left;
  }

  .illustration {
    max-width: 40%;
    text-align: left;
  }
}
</style>
