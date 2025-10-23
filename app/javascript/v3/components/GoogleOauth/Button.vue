<script>
import SimpleDivider from '../Divider/SimpleDivider.vue';

export default {
  components: {
    SimpleDivider,
  },
  props: {
    showSeparator: {
      type: Boolean,
      default: true,
    },
  },
  methods: {
    getGoogleAuthUrl() {
      // Ideally a request to /auth/google_oauth2 should be made
      // Creating the URL manually because the devise-token-auth with
      // omniauth has a standing issue on redirecting the post request
      // https://github.com/lynndylanhurley/devise_token_auth/issues/1466
      const baseUrl =
        'https://accounts.google.com/o/oauth2/auth/oauthchooseaccount';
      const clientId = window.chatwootConfig.googleOAuthClientId;
      const redirectUri = window.chatwootConfig.googleOAuthCallbackUrl;
      const responseType = 'code';
      const scope = 'email profile';

      // Build the query string
      const queryString = new URLSearchParams({
        client_id: clientId,
        redirect_uri: redirectUri,
        response_type: responseType,
        scope: scope,
      }).toString();

      // Construct the full URL
      return `${baseUrl}?${queryString}`;
    },
  },
};
</script>

<!-- eslint-disable vue/no-unused-refs -->
<!-- Added ref for writing specs -->
<template>
  <div class="flex flex-col">
    <a
      :href="getGoogleAuthUrl()"
      class="inline-flex justify-center items-center w-full px-4 py-3.5 bg-white/20 backdrop-blur-md rounded-xl shadow-lg ring-2 ring-white/30 focus:outline-none hover:bg-white/25 hover:ring-white/50 hover:shadow-xl transition-all duration-300 hover:scale-[1.02] active:scale-[0.98]"
    >
      <span class="i-logos-google-icon h-6 w-6" />
      <span class="ml-3 text-base font-semibold text-white">
        {{ $t('LOGIN.OAUTH.GOOGLE_LOGIN') }}
      </span>
    </a>
    <SimpleDivider
      v-if="showSeparator"
      ref="divider"
      :label="$t('COMMON.OR')"
      class="uppercase"
    />
  </div>
</template>
