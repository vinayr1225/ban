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
    boundAlt() {
      return 'Alt text'; // NOTE: this should warn with eslint-plugin-i18n-vanilla
    },
    canEdit() {
      return true;
    },
  },
};
</script>
<template>
  <div>
    <div alt="GOOD">
      <img v-bind:alt="boundAlt">
      <dropdown-title :can-edit="false"/>
    </div>
    <div alt="BAD">
      <p>{{ __('Externalized key that doesnt exist') }}</p>
      <p>{{ ('Non-Externalized key that doesnt exist') }}</p>
      <p>{{ "Bare string" }}</p>
      <p>{{ 'Barely a string' }}</p>
      <p>{{ `WHUT` }}</p>
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
      <p v-once>Static text</p>
      <template>
        <div>Slow down, theres a bare</div>
      </template>
    </div>
  </div>
</template>
