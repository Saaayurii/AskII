<script>
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import FormInput from '../../../components/Form/Input.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import { DEFAULT_REDIRECT_URL } from 'dashboard/constants/globals';
import { setNewPassword } from '../../../api/auth';
import SpaceBackground from '../../../components/SpaceBackground.vue';

export default {
  components: {
    FormInput,
    NextButton,
    SpaceBackground,
  },
  props: {
    resetPasswordToken: { type: String, default: '' },
  },
  setup() {
    return { v$: useVuelidate() };
  },
  data() {
    return {
      // We need to initialize the component with any
      // properties that will be used in it
      credentials: {
        confirmPassword: '',
        password: '',
      },
      newPasswordAPI: {
        message: '',
        showLoading: false,
      },
      error: '',
    };
  },
  mounted() {
    // If url opened without token
    // redirect to login
    if (!this.resetPasswordToken) {
      window.location = DEFAULT_REDIRECT_URL;
    }
  },
  validations: {
    credentials: {
      password: {
        required,
        minLength: minLength(6),
      },
      confirmPassword: {
        required,
        minLength: minLength(6),
        isEqPassword(value) {
          if (value !== this.credentials.password) {
            return false;
          }
          return true;
        },
      },
    },
  },
  methods: {
    showAlertMessage(message) {
      // Reset loading, current selected agent
      this.newPasswordAPI.showLoading = false;
      useAlert(message);
    },
    submitForm() {
      this.newPasswordAPI.showLoading = true;
      const credentials = {
        confirmPassword: this.credentials.confirmPassword,
        password: this.credentials.password,
        resetPasswordToken: this.resetPasswordToken,
      };
      setNewPassword(credentials)
        .then(() => {
          window.location = DEFAULT_REDIRECT_URL;
        })
        .catch(error => {
          this.showAlertMessage(
            error?.message || this.$t('SET_NEW_PASSWORD.API.ERROR_MESSAGE')
          );
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
    <form
      class="relative z-10 backdrop-blur-2xl bg-gradient-to-br from-white/15 to-white/5 border border-white/30 shadow-2xl sm:mx-auto sm:w-full sm:max-w-lg p-12 sm:rounded-3xl before:absolute before:inset-0 before:rounded-3xl before:bg-gradient-to-br before:from-white/10 before:to-transparent before:opacity-50 before:-z-10"
      @submit.prevent="submitForm"
    >
      <h1
        class="mb-6 text-3xl font-bold tracking-tight text-left text-white drop-shadow-lg"
      >
        {{ $t('SET_NEW_PASSWORD.TITLE') }}
      </h1>

      <div class="space-y-5">
        <FormInput
          v-model="credentials.password"
          name="password"
          type="password"
          :label="$t('SET_NEW_PASSWORD.PASSWORD.LABEL')"
          :has-error="v$.credentials.password.$error"
          :error-message="$t('SET_NEW_PASSWORD.PASSWORD.ERROR')"
          :placeholder="$t('SET_NEW_PASSWORD.PASSWORD.PLACEHOLDER')"
          @blur="v$.credentials.password.$touch"
        />
        <FormInput
          v-model="credentials.confirmPassword"
          name="confirm_password"
          type="password"
          :label="$t('SET_NEW_PASSWORD.CONFIRM_PASSWORD.LABEL')"
          :has-error="v$.credentials.confirmPassword.$error"
          :error-message="$t('SET_NEW_PASSWORD.CONFIRM_PASSWORD.ERROR')"
          :placeholder="$t('SET_NEW_PASSWORD.CONFIRM_PASSWORD.PLACEHOLDER')"
          @blur="v$.credentials.confirmPassword.$touch"
        />
        <NextButton
          lg
          type="submit"
          data-testid="submit_button"
          class="w-full !bg-gradient-to-r !from-blue-500 !to-purple-600 !text-white !font-semibold !rounded-xl !shadow-lg !backdrop-blur-sm hover:!from-blue-600 hover:!to-purple-700 hover:!shadow-xl !transition-all !duration-300 hover:!scale-[1.02] active:!scale-[0.98] disabled:!opacity-50 disabled:!cursor-not-allowed"
          :label="$t('SET_NEW_PASSWORD.SUBMIT')"
          :disabled="
            v$.credentials.password.$invalid ||
            v$.credentials.confirmPassword.$invalid ||
            newPasswordAPI.showLoading
          "
          :is-loading="newPasswordAPI.showLoading"
        />
      </div>
    </form>
  </div>
</template>
