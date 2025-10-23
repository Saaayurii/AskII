<script>
import { useVuelidate } from '@vuelidate/core';
import { useAlert } from 'dashboard/composables';
import { required, minLength, email } from '@vuelidate/validators';
import { useBranding } from 'shared/composables/useBranding';
import FormInput from '../../../../components/Form/Input.vue';
import { resetPassword } from '../../../../api/auth';
import NextButton from 'dashboard/components-next/button/Button.vue';
import SpaceBackground from '../../../../components/SpaceBackground.vue';
import FloatingParticles from '../../../../components/FloatingParticles.vue';
import BatAnimation from '../../../../components/BatAnimation.vue';

export default {
  components: { FormInput, NextButton, SpaceBackground, FloatingParticles, BatAnimation },
  setup() {
    const { replaceInstallationName } = useBranding();
    return { v$: useVuelidate(), replaceInstallationName };
  },
  data() {
    return {
      credentials: { email: '' },
      resetPassword: {
        message: '',
        showLoading: false,
      },
      error: '',
    };
  },
  validations() {
    return {
      credentials: {
        email: {
          required,
          email,
          minLength: minLength(4),
        },
      },
    };
  },
  methods: {
    showAlertMessage(message) {
      // Reset loading, current selected agent
      this.resetPassword.showLoading = false;
      useAlert(message);
    },
    submit() {
      this.resetPassword.showLoading = true;
      resetPassword(this.credentials)
        .then(res => {
          let successMessage = this.$t('RESET_PASSWORD.API.SUCCESS_MESSAGE');
          if (res.data && res.data.message) {
            successMessage = res.data.message;
          }
          this.showAlertMessage(successMessage);
        })
        .catch(error => {
          let errorMessage = this.$t('RESET_PASSWORD.API.ERROR_MESSAGE');
          if (error?.response?.data?.message) {
            errorMessage = error.response.data.message;
          }
          this.showAlertMessage(errorMessage);
        });
    },
  },
};
</script>

<template>
  <div
    class="relative flex flex-col justify-center w-full min-h-screen py-12 overflow-hidden sm:px-6 lg:px-8"
  >
    <SpaceBackground />
    <FloatingParticles />
    <div class="relative z-10 sm:mx-auto sm:w-full sm:max-w-lg mb-8 animate-fade-in-up">
      <div class="h-32 flex items-center justify-center animate-float">
        <BatAnimation />
      </div>
      <h1
        class="mt-4 text-4xl font-bold text-center text-white drop-shadow-2xl bg-gradient-to-r from-blue-200 via-white to-purple-200 bg-clip-text text-transparent animate-fade-in-up animation-delay-200"
      >
        {{ $t('RESET_PASSWORD.TITLE') }}
      </h1>
    </div>
    <form
      class="relative z-10 backdrop-blur-2xl bg-gradient-to-br from-white/15 to-white/5 border border-white/30 shadow-2xl sm:mx-auto sm:w-full sm:max-w-lg p-12 sm:rounded-3xl before:absolute before:inset-0 before:rounded-3xl before:bg-gradient-to-br before:from-white/10 before:to-transparent before:opacity-50 before:-z-10 animate-fade-in-up animation-delay-400 hover:shadow-3xl transition-shadow duration-500"
      @submit.prevent="submit"
    >
      <p
        class="mb-6 text-sm font-normal leading-6 tracking-normal text-white/80 text-center"
      >
        {{ replaceInstallationName($t('RESET_PASSWORD.DESCRIPTION')) }}
      </p>
      <div class="space-y-5">
        <FormInput
          v-model="credentials.email"
          name="email_address"
          :label="$t('RESET_PASSWORD.EMAIL.LABEL')"
          :has-error="v$.credentials.email.$error"
          :error-message="$t('RESET_PASSWORD.EMAIL.ERROR')"
          :placeholder="$t('RESET_PASSWORD.EMAIL.PLACEHOLDER')"
          @input="v$.credentials.email.$touch"
        />
        <NextButton
          lg
          type="submit"
          data-testid="submit_button"
          class="w-full !bg-gradient-to-r !from-blue-500 !to-purple-600 !text-white !font-semibold !rounded-xl !shadow-lg !backdrop-blur-sm hover:!from-blue-600 hover:!to-purple-700 hover:!shadow-xl !transition-all !duration-300 hover:!scale-[1.02] active:!scale-[0.98] disabled:!opacity-50 disabled:!cursor-not-allowed"
          :label="$t('RESET_PASSWORD.SUBMIT')"
          :disabled="v$.credentials.email.$invalid || resetPassword.showLoading"
          :is-loading="resetPassword.showLoading"
        />
      </div>
      <p class="mt-6 -mb-1 text-sm text-white/90 text-center animate-fade-in-up animation-delay-600">
        {{ $t('RESET_PASSWORD.GO_BACK_TO_LOGIN') }}
        <router-link to="/auth/login" class="text-blue-300 hover:text-blue-100 transition-all duration-300 font-medium underline decoration-blue-300/50 hover:decoration-blue-100 underline-offset-4 hover:scale-105 inline-block">
          {{ $t('COMMON.CLICK_HERE') }}.
        </router-link>
      </p>
    </form>
  </div>
</template>
