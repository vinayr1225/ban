import Vue from 'vue';
import '../vue_shared/vue_resource_interceptor';
import GlFeatureFlagsPlugin from '~/vue_shared/gl_feature_flags_plugin';

if (process.env.NODE_ENV !== 'production') {
  Vue.config.productionTip = false;
}

Vue.use(GlFeatureFlagsPlugin);
