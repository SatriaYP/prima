export default {
  mounted(el, binding) {
    el.clickOutsideEvent = (event) => {
      // Cek jika klik terjadi di luar elemen
      if (!(el === event.target || el.contains(event.target))) {
        binding.value(event); // Jalankan handler
      }
    };
    document.addEventListener("click", el.clickOutsideEvent);
  },
  unmounted(el) {
    document.removeEventListener("click", el.clickOutsideEvent);
  },
};
