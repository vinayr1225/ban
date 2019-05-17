<script>
import { s__, __ } from '~/locale';

export default {
  computed: {
    text() {
      return s__('Bad|Nonexistent key');
    },
    text2() {
      return __('Bad|Nonexistent key 2');
    },
    canEditBadge() {
      return this.badge.kind === this.kind;
    },
  },
};
</script>
<template>
  <div>
    <p>{{ 'Not correctly externalized' }}</p>
    <p>{{ __('Externalized key that doesnt exist') }}</p>
    <p>{{ ('Non-Externalized key that doesnt exist') }}</p>
    <p>{{ "Bare string" }}</p>
    <!-- supply-chain attack -->
    <div data-tooltip="$t('yaml invalid')">
      <h1>{{text}}</h1>
      <span>{{"Well hello there"}}</span>
    </div>
    <div v-text="$t('Data tooltip')">
      <p>{{`Cool kinda ${text}`}}</p>
    </div>
    <img alt="$t('Image alt text')">
    <div :class="text" v-data-label="wowee">
      <img alt="$t('Image alt text')">
    </div>
    <template>
      <div>Slow down, theres a bare</div>
    </template>
  </div>
</template>
