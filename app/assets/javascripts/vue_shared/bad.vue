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
    <div>
      <!-- Good strings -->
      <!-- These should not error -->
      <img v-bind:alt="boundAlt">
      <dropdown-title :can-edit="false"/>
      <span aria-hidden="true">&times;</span>
      <a :class="`js-${scope}-tab-${tab.scope}`" role="button" @click="onTabClick(tab)">
        {{ tab.name }}
        <span
          v-if="shouldRenderBadge(tab.count)"
          class="badge badge-pill"
        >{{ tab.count }}</span>
      </a>
    </div>
    <div alt="BAD">
      <!-- Bad Strings -->
      <!-- Should all error -->
      <p>{{ __('Externalized key that doesnt exist') }}</p>
      <p>{{ ('Non-Externalized key that doesnt exist') }}</p>
      <p>"Bare string"</p>
      <p>'Barely a string'</p>
      <p>{{ "Bare string" }}</p>
      <p>{{ 'Barely a string' }}</p>
      <p>{{ `WHUT` }}</p>
      <p>{{ __(`WHUT`) }}</p>
      <p>{{ __("WHUT") }}</p>
      <p>{{ __('WHUT') }}</p>
      <div data-tooltip="$t('yaml invalid')">
        <h1>{{text}}</h1>
        <span>{{"Well hello there"}}</span>
      </div>
      <div v-text="$t('Data tooltip')">
        <p>{{ `Cool kinda ${text}` }}</p>
      </div>
      <img alt="$t('Image alt text')">
      <div :class="text" v-data-label="wowee">
        <img alt="$t('Image alt text')">
      </div>
      <p v-once>Static text</p>
      <template>
        <div>Slow down, theres a bare</div>
      </template>
      <p>{{ __(`WHUT`) }}</p>
      <p>{{ `WHUT ${text}` }}</p>
    </div>
    <span
      v-if="failurePercent"
      v-tooltip
      :title="failureTooltip"
      :style="failureBarStyle"
      class="status-red"
      data-placement="bottom"
    >{{ "Totally failed" }}%</span>
    <span
      v-if="failurePercent"
      v-tooltip
      :title="failureTooltip"
      :style="failureBarStyle"
      class="status-red"
      data-placement="bottom"
    >{{ failurePercent }}%</span>
  </div>
</template>
