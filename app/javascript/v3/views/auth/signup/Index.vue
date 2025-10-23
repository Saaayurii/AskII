<script>
import { mapGetters } from 'vuex';
import { useBranding } from 'shared/composables/useBranding';
import SignupForm from './components/Signup/Form.vue';
import Testimonials from './components/Testimonials/Index.vue';
import Spinner from 'shared/components/Spinner.vue';
import SpaceBackground from '../../../components/SpaceBackground.vue';
import BatAnimation from '../../../components/BatAnimation.vue';
import FloatingParticles from '../../../components/FloatingParticles.vue';

export default {
  components: {
    SignupForm,
    Spinner,
    Testimonials,
    SpaceBackground,
    BatAnimation,
    FloatingParticles,
  },
  setup() {
    const { replaceInstallationName } = useBranding();
    return { replaceInstallationName };
  },
  data() {
    return { isLoading: false };
  },
  computed: {
    ...mapGetters({ globalConfig: 'globalConfig/get' }),
    isAChatwootInstance() {
      return this.globalConfig.installationName === 'Chatwoot';
    },
  },
  beforeMount() {
    this.isLoading = this.isAChatwootInstance;
  },
  methods: {
    resizeContainers() {
      this.isLoading = false;
    },
  },
};
</script>

<template>
  <div class="relative w-full h-full overflow-hidden">
    <SpaceBackground />
    <FloatingParticles />
    <div v-show="!isLoading" class="relative z-10 flex h-full min-h-screen items-center">
      <div
        class="flex-1 min-h-[640px] inline-flex items-center h-full justify-center overflow-auto py-6"
      >
        <div class="px-8 max-w-[560px] w-full overflow-auto">
          <div class="mb-6 backdrop-blur-sm bg-white/5 p-6 rounded-2xl border border-white/20 animate-fade-in-up animation-delay-200 hover:bg-white/10 transition-all duration-300">
            <div class="h-32 flex items-center justify-center mb-4 animate-float">
              <BatAnimation />
            </div>
            <h2
              class="text-4xl font-bold text-center mb-2 text-white drop-shadow-lg bg-gradient-to-r from-blue-200 via-white to-purple-200 bg-clip-text text-transparent animate-fade-in-up animation-delay-400"
            >
              {{ $t('REGISTER.TRY_WOOT') }}
            </h2>
          </div>
          <div class="backdrop-blur-2xl bg-gradient-to-br from-white/15 to-white/5 border border-white/30 shadow-2xl p-8 rounded-3xl before:absolute before:inset-0 before:rounded-3xl before:bg-gradient-to-br before:from-white/10 before:to-transparent before:opacity-50 before:-z-10 relative animate-fade-in-up animation-delay-600 hover:shadow-3xl transition-shadow duration-500">
            <SignupForm />
            <div class="px-1 text-sm text-white/90 text-center mt-4 animate-fade-in-up animation-delay-800">
              <span>{{ $t('REGISTER.HAVE_AN_ACCOUNT') }}</span>
              <router-link class="text-blue-300 hover:text-blue-100 transition-all duration-300 font-medium underline decoration-blue-300/50 hover:decoration-blue-100 underline-offset-4 ml-1 hover:scale-105 inline-block" to="/app/login">
                {{ replaceInstallationName($t('LOGIN.TITLE')) }}
              </router-link>
            </div>
          </div>
        </div>
      </div>
      <Testimonials
        v-if="isAChatwootInstance"
        class="flex-1 animate-fade-in animation-delay-700"
        @resize-containers="resizeContainers"
      />
    </div>
    <div
      v-show="isLoading"
      class="flex items-center min-h-screen justify-center w-full h-full"
    >
      <Spinner color-scheme="primary" size="" />
    </div>
  </div>
</template>
