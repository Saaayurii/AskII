<script setup>
import { defineProps, defineModel } from 'vue';
import WithLabel from './WithLabel.vue';

defineProps({
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
    <input
      v-bind="$attrs"
      v-model="model"
      :type="type"
      class="block w-full border-none rounded-xl shadow-lg backdrop-blur-md bg-white/10 appearance-none outline-none ring-2 text-white placeholder:text-white/50 sm:text-sm sm:leading-6 px-4 py-3.5 transition-all duration-300 focus:scale-[1.02] animate-scale-in"
      :class="{
        'ring-red-400/50 bg-red-500/10 focus:ring-red-400 animate-shake':
          hasError,
        'ring-white/20 hover:ring-white/40 focus:ring-blue-400/60 focus:bg-white/15 focus:shadow-xl focus:shadow-blue-500/20':
          !hasError,
        'px-4 py-3.5': spacing === 'base',
        'px-4 py-2.5 mb-0': spacing === 'compact',
        'pl-10': icon,
      }"
    />
  </WithLabel>
</template>
