<script>
export default {
  props: {
    label: {
      type: String,
      default: '',
    },
  },
};
</script>

<template>
  <div class="relative my-6 section-separator">
    <div class="absolute inset-0 flex items-center" aria-hidden="true">
      <div class="w-full border-t border-white/30" />
    </div>
    <div v-if="label" class="relative flex justify-center text-sm">
      <span class="bg-transparent backdrop-blur-sm px-3 text-white/70 font-medium">
        {{ label }}
      </span>
    </div>
  </div>
</template>
