<script setup>
import { defineProps, defineModel, ref, computed } from 'vue';
import WithLabel from './WithLabel.vue';

const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    default: 'text',
  },
  icon: {
    type: String,
    default: '',
  },
  name: {
    type: String,
    required: true,
  },
  hasError: Boolean,
  errorMessage: {
    type: String,
    default: '',
  },
  spacing: {
    type: String,
    default: 'base',
    validator: value => ['base', 'compact'].includes(value),
  },
});

defineOptions({
  inheritAttrs: false,
});

const model = defineModel({
  type: [String, Number],
  required: true,
});

const isPasswordVisible = ref(false);

const currentInputType = computed(() => {
  if (props.type === 'password' && isPasswordVisible.value) {
    return 'text';
  }
  return props.type;
});

const togglePasswordVisibility = () => {
  isPasswordVisible.value = !isPasswordVisible.value;
};
</script>

<template>
  <WithLabel
    :label="label"
    :icon="icon"
    :name="name"
    :has-error="hasError"
    :error-message="errorMessage"
  >
    <template #rightOfLabel>
      <slot />
    </template>
    <div class="relative">
      <input
        v-bind="$attrs"
        v-model="model"
        :type="currentInputType"
        class="block w-full border-none rounded-xl shadow-lg backdrop-blur-md bg-white/10 appearance-none outline-none ring-2 text-white placeholder:text-white/50 sm:text-sm sm:leading-6 px-4 py-3.5 transition-all duration-300 focus:scale-[1.02] animate-scale-in"
        :class="{
          'ring-red-400/50 bg-red-500/10 focus:ring-red-400 animate-shake':
            hasError,
          'ring-white/20 hover:ring-white/40 focus:ring-blue-400/60 focus:bg-white/15 focus:shadow-xl focus:shadow-blue-500/20':
            !hasError,
          'px-4 py-3.5': spacing === 'base',
          'px-4 py-2.5 mb-0': spacing === 'compact',
          'pl-10': icon,
          'pr-12': type === 'password',
        }"
      />
      <button
        v-if="type === 'password'"
        type="button"
        class="absolute inset-y-0 right-0 flex items-center pr-4 text-white/60 hover:text-white/90 transition-colors duration-200"
        @click="togglePasswordVisibility"
      >
        <span
          :class="isPasswordVisible ? 'i-lucide-eye-off' : 'i-lucide-eye'"
          class="w-5 h-5"
        />
      </button>
    </div>
  </WithLabel>
</template>
