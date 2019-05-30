<script>
import { GlBadge } from '@gitlab/ui';
import { GlTooltipDirective } from '@gitlab/ui';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { getIconName } from '../../utils/icon';
import getRefMixin from '../../mixins/get_ref';

export default {
  components: {
    GlBadge,
  },
  directives: { GlTooltip: GlTooltipDirective },
  mixins: [timeagoMixin, getRefMixin],
  props: {
    id: {
      type: String,
      required: true,
    },
    currentPath: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    url: {
      type: String,
      required: false,
      default: null,
    },
    lfsOid: {
      type: String,
      required: false,
      default: null,
    commit: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    routerLinkTo() {
      return this.isFolder ? { path: `/tree/${this.ref}/${this.path}` } : null;
    },
    iconName() {
      return `fa-${getIconName(this.type, this.path)}`;
    },
    isFolder() {
      return this.type === 'tree';
    },
    isSubmodule() {
      return this.type === 'commit';
    },
    linkComponent() {
      return this.isFolder ? 'router-link' : 'a';
    },
    fullPath() {
      return this.path.replace(new RegExp(`^${this.currentPath}/`), '');
    },
    shortSha() {
      return this.id.slice(0, 8);
    },
  },
  methods: {
    openRow() {
      if (this.isFolder) {
        this.$router.push(this.routerLinkTo);
      }
    },
  },
};
</script>

<template>
  <tr v-once :class="`file_${id}`" class="tree-item" @click="openRow">
    <td class="tree-item-file-name">
      <i :aria-label="type" role="img" :class="iconName" class="fa fa-fw"></i>
      <component :is="linkComponent" :to="routerLinkTo" :href="url" class="str-truncated">
        {{ fullPath }}
      </component>
      <gl-badge v-if="lfsOid" variant="default" class="label-lfs ml-1">
        LFS
      </gl-badge>
      <template v-if="isSubmodule">
        @ <a href="#" class="commit-sha">{{ shortSha }}</a>
      </template>
    </td>
    <td class="d-none d-sm-table-cell tree-commit">
      <span class="str-truncated">{{ commit.message }}</span>
    </td>
    <td class="tree-time-ago text-right">
      <time v-gl-tooltip.top.viewport :datetime="commit.committedDate" :title="tooltipTitle(commit.committedDate)">
        {{ timeFormated(commit.committedDate) }}
      </time>
    </td>
  </tr>
</template>
