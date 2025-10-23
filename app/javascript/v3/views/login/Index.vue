<script>
// utils and composables
import { login } from '../../api/auth';
import { mapGetters } from 'vuex';
import { parseBoolean } from '@chatwoot/utils';
import { useAlert } from 'dashboard/composables';
import { required, email } from '@vuelidate/validators';
import { useVuelidate } from '@vuelidate/core';
import { SESSION_STORAGE_KEYS } from 'dashboard/constants/sessionStorage';
import SessionStorage from 'shared/helpers/sessionStorage';
import { useBranding } from 'shared/composables/useBranding';

// components
import FormInput from '../../components/Form/Input.vue';
import GoogleOAuthButton from '../../components/GoogleOauth/Button.vue';
import Spinner from 'shared/components/Spinner.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import BatAnimation from '../../components/BatAnimation.vue';
import SpaceBackground from '../../components/SpaceBackground.vue';
import FloatingParticles from '../../components/FloatingParticles.vue';

const ERROR_MESSAGES = {
  'no-account-found': 'LOGIN.OAUTH.NO_ACCOUNT_FOUND',
  'business-account-only': 'LOGIN.OAUTH.BUSINESS_ACCOUNTS_ONLY',
};

const IMPERSONATION_URL_SEARCH_KEY = 'impersonation';

export default {
  components: {
    FormInput,
    GoogleOAuthButton,
    Spinner,
    NextButton,
    BatAnimation,
    SpaceBackground,
    FloatingParticles,
  },
  props: {
    ssoAuthToken: { type: String, default: '' },
    ssoAccountId: { type: String, default: '' },
    ssoConversationId: { type: String, default: '' },
    email: { type: String, default: '' },
    authError: { type: String, default: '' },
  },
  setup() {
    const { replaceInstallationName } = useBranding();
    return {
      replaceInstallationName,
      v$: useVuelidate(),
    };
  },
  data() {
    return {
      // We need to initialize the component with any
      // properties that will be used in it
      credentials: {
        email: '',
        password: '',
      },
      loginApi: {
        message: '',
        showLoading: false,
        hasErrored: false,
      },
      error: '',
      showPassword: false,
    };
  },
  validations() {
    return {
      credentials: {
        password: {
          required,
        },
        email: {
          required,
          email,
        },
      },
    };
  },
  computed: {
    ...mapGetters({ globalConfig: 'globalConfig/get' }),
    showGoogleOAuth() {
      return Boolean(window.chatwootConfig.googleOAuthClientId);
    },
    showSignupLink() {
      return parseBoolean(window.chatwootConfig.signupEnabled);
    },
  },
  created() {
    if (this.ssoAuthToken) {
      this.submitLogin();
    }
    if (this.authError) {
      const message = ERROR_MESSAGES[this.authError] ?? 'LOGIN.API.UNAUTH';
      useAlert(this.$t(message));
      // wait for idle state
      this.requestIdleCallbackPolyfill(() => {
        // Remove the error query param from the url
        const { query } = this.$route;
        this.$router.replace({ query: { ...query, error: undefined } });
      });
    }
  },
  methods: {
    // TODO: Remove this when Safari gets wider support
    // Ref: https://caniuse.com/requestidlecallback
    //
    requestIdleCallbackPolyfill(callback) {
      if (window.requestIdleCallback) {
        window.requestIdleCallback(callback);
      } else {
        // Fallback for safari
        // Using a delay of 0 allows the callback to be executed asynchronously
        // in the next available event loop iteration, similar to requestIdleCallback
        setTimeout(callback, 0);
      }
    },
    showAlertMessage(message) {
      // Reset loading, current selected agent
      this.loginApi.showLoading = false;
      this.loginApi.message = message;
      useAlert(this.loginApi.message);
    },
    handleImpersonation() {
      // Detects impersonation mode via URL and sets a session flag to prevent user settings changes during impersonation.
      const urlParams = new URLSearchParams(window.location.search);
      const impersonation = urlParams.get(IMPERSONATION_URL_SEARCH_KEY);
      if (impersonation) {
        SessionStorage.set(SESSION_STORAGE_KEYS.IMPERSONATION_USER, true);
      }
    },
    submitLogin() {
      this.loginApi.hasErrored = false;
      this.loginApi.showLoading = true;

      const credentials = {
        email: this.email
          ? decodeURIComponent(this.email)
          : this.credentials.email,
        password: this.credentials.password,
        sso_auth_token: this.ssoAuthToken,
        ssoAccountId: this.ssoAccountId,
        ssoConversationId: this.ssoConversationId,
      };

      login(credentials)
        .then(() => {
          this.handleImpersonation();
          this.showAlertMessage(this.$t('LOGIN.API.SUCCESS_MESSAGE'));
        })
        .catch(response => {
          // Reset URL Params if the authentication is invalid
          if (this.email) {
            window.location = '/app/login';
          }
          this.loginApi.hasErrored = true;
          this.showAlertMessage(
            response?.message || this.$t('LOGIN.API.UNAUTH')
          );
        });
    },
    submitFormLogin() {
      if (this.v$.credentials.email.$invalid && !this.email) {
        this.showAlertMessage(this.$t('LOGIN.EMAIL.ERROR'));
        return;
      }

      this.submitLogin();
    },
    togglePasswordVisibility() {
      this.showPassword = !this.showPassword;
    },
  },
};
</script>

<template>
  <main class="relative flex flex-col w-full min-h-screen py-20 overflow-hidden sm:px-6 lg:px-8">
    <SpaceBackground />
    <FloatingParticles />
    <section class="relative z-10 max-w-5xl mx-auto animate-fade-in-up">
      <div class="h-32 flex items-center justify-center animate-float">
        <BatAnimation />
      </div>
      <h2 class="mt-6 text-4xl font-bold text-center text-white drop-shadow-2xl bg-gradient-to-r from-blue-200 via-white to-purple-200 bg-clip-text text-transparent animate-fade-in-up animation-delay-200">
        {{ replaceInstallationName($t('LOGIN.TITLE')) }}
      </h2>
      <p v-if="showSignupLink" class="mt-4 text-base text-center text-white/90 drop-shadow-lg animate-fade-in-up animation-delay-400">
        {{ $t('COMMON.OR') }}
        <router-link to="auth/signup" class="lowercase text-blue-300 hover:text-blue-100 transition-all duration-300 font-medium underline decoration-blue-300/50 hover:decoration-blue-100 underline-offset-4 hover:scale-105 inline-block">
          {{ $t('LOGIN.CREATE_NEW_ACCOUNT') }}
        </router-link>
      </p>
    </section>
    <section
      class="relative z-10 backdrop-blur-2xl bg-gradient-to-br from-white/15 to-white/5 border border-white/30 shadow-2xl sm:mx-auto mt-11 sm:w-full sm:max-w-lg p-12 sm:rounded-3xl before:absolute before:inset-0 before:rounded-3xl before:bg-gradient-to-br before:from-white/10 before:to-transparent before:opacity-50 before:-z-10 animate-fade-in-up animation-delay-600 hover:shadow-3xl transition-shadow duration-500"
      :class="{
        'mb-8 mt-15': !showGoogleOAuth,
        'animate-wiggle': loginApi.hasErrored,
      }"
    >
      <div v-if="!email">
        <GoogleOAuthButton v-if="showGoogleOAuth" />
        <form class="space-y-5" @submit.prevent="submitFormLogin">
          <FormInput
            v-model="credentials.email"
            name="email_address"
            type="text"
            data-testid="email_input"
            :tabindex="1"
            required
            :label="$t('LOGIN.EMAIL.LABEL')"
            :placeholder="$t('LOGIN.EMAIL.PLACEHOLDER')"
            :has-error="v$.credentials.email.$error"
            @input="v$.credentials.email.$touch"
          />
          <div class="relative">
            <FormInput
              v-model="credentials.password"
              :type="showPassword ? 'text' : 'password'"
              name="password"
              data-testid="password_input"
              required
              :tabindex="2"
              :label="$t('LOGIN.PASSWORD.LABEL')"
              :placeholder="$t('LOGIN.PASSWORD.PLACEHOLDER')"
              :has-error="v$.credentials.password.$error"
              class="pr-10"
              @input="v$.credentials.password.$touch"
            >
              <div class="flex items-center justify-between">
                <p v-if="!globalConfig.disableUserProfileUpdate">
                  <router-link
                    to="auth/reset/password"
                    class="text-sm text-blue-300 hover:text-blue-200 transition-colors"
                    tabindex="4"
                  >
                    {{ $t('LOGIN.FORGOT_PASSWORD') }}
                  </router-link>
                </p>
              </div>
            </FormInput>
            <button
              type="button"
              class="absolute right-3 top-[42px] text-white/60 hover:text-white transition-colors"
              @click="togglePasswordVisibility"
              :tabindex="5"
              :aria-label="showPassword ? 'Hide password' : 'Show password'"
            >
              <svg
                v-if="!showPassword"
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                ></path>
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
                ></path>
              </svg>
              <svg
                v-else
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L8.464 8.464M18.535 8.464L15.121 12M18.535 8.464l-1.414-1.414M15.121 12L12 15.121M15.121 12l3.535-3.535M9.878 9.878L12 12"
                ></path>
              </svg>
            </button>
          </div>
          <NextButton
            lg
            type="submit"
            data-testid="submit_button"
            class="w-full !bg-gradient-to-r !from-blue-500 !to-purple-600 !text-white !font-semibold !rounded-xl !shadow-lg !backdrop-blur-sm hover:!from-blue-600 hover:!to-purple-700 hover:!shadow-xl !transition-all !duration-300 hover:!scale-[1.02] active:!scale-[0.98] disabled:!opacity-50 disabled:!cursor-not-allowed"
            :tabindex="3"
            :label="$t('LOGIN.SUBMIT')"
            :disabled="loginApi.showLoading"
            :is-loading="loginApi.showLoading"
          />
        </form>
      </div>
      <div v-else class="flex items-center justify-center">
        <Spinner color-scheme="primary" size="" />
      </div>
    </section>
  </main>
</template>
