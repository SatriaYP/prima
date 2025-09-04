<template>
  <div class="step-indicator">
    <div
      v-for="(step, index) in steps"
      :key="index"
      class="step"
      :class="{
        completed: currentStep > index,
        active: currentStep === index,
        pending: currentStep < index,
      }"
      @click="() => emitStep(index)"
    >
      <div class="circle">
        <template v-if="currentStep > index">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="14"
            height="14"
            viewBox="0 0 24 24"
          >
            <path
              fill="black"
              d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"
            />
          </svg>
        </template>
        <template v-else>
          {{ index + 1 }}
        </template>
      </div>
      <div class="label">{{ step }}</div>

      <!-- Line (except after last step) -->
      <div
        v-if="index < steps.length - 1"
        class="line"
        :class="{ active: currentStep > index }"
      ></div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  steps: Array,
  currentStep: Number,
});
const emit = defineEmits(["goToStep"]);
const emitStep = (index) => emit("goToStep", index);
</script>

<style scoped>
.step-indicator {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: nowrap;
  /* gap: 6px; */
  padding: 16px 0;
  overflow-x: auto;
  width: fit-content;
  /* background: #6c63ff; */
  margin: auto;
}

.step {
  display: flex;
  align-items: center;
  position: relative;
  cursor: pointer;
}

.circle {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  font-size: 13px;
  font-weight: bold;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-shrink: 0;
  background-color: #e5e7eb;
  color: #555;
  border: 2px solid #d1d5db;
  z-index: 2;
}

.label {
  margin-left: 8px;
  font-size: 0.85rem;
  color: #999;
  white-space: nowrap;
}

.line {
  height: 2px;
  width: 50px;
  background: #e5e7eb;
  margin-left: 12px;
  margin-right: 12px;
  z-index: 1;
}

.line.active {
  background: #4bee9d;
  /* background: #facc15; */
}

/* === States === */
.step.completed .circle {
  background-color: #4bee9d;
  border-color: #4bee9d;
  /* background-color: #facc15;
  border-color: #facc15; */
  color: #000;
}

.step.completed .label {
  color: #000;
  font-weight: 500;
}

.step.active .circle {
  background-color: #6c63ff;
  border-color: #6c63ff;
  color: white;
}

.step.active .label {
  color: #6c63ff;
  font-weight: 600;
}

.step.pending .circle {
  background-color: #e5e7eb;
  border-color: #d1d5db;
  color: #888;
}

.step.pending .label {
  color: #ccc;
}
</style>
