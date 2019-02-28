<script>
import Vue from 'vue';
import SuggestionDiff from './suggestion_diff.vue';
// import Flash from '~/flash';

export default {
  components: { SuggestionDiff },
  props: {
    // fromLine: {
    //   type: Number,
    //   required: false,
    //   default: 0,
    // },
    fromContent: {
      type: String,
      required: true,
      default: '',
    },
    toContent: {
      type: String,
      required: true,
      default: '',
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    helpPagePath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isRendered: false,
    };
  },
  watch: {
    suggestions() {
      this.reset();
    },
    noteHtml() {
      this.reset();
    },
  },
  mounted() {
    this.renderSuggestion();
  },
  methods: {
    renderSuggestion() {
      console.log('fromContent', this.fromContent);
      console.log('toContent', this.toContent);
      // swaps out suggestion(s) markdown with rich diff components
      // (while still keeping non-suggestion markdown in place)

      // if (!this.noteHtml) return;
      // const { container } = this.$refs;
      // const suggestionElements = container.querySelectorAll('.js-render-suggestion');
      //
      // if (this.lineType === 'old') {
      //   Flash('Unable to apply suggestions to a deleted line.', 'alert', this.$el);
      // }
      //
      // suggestionElements.forEach((suggestionEl, i) => {
      //   const diffComponent = this.generateDiff();
      //   diffComponent.$mount(suggestionParentEl);
      // });

      this.isRendered = true;
    },
    generateDiff() {
      // generates the diff <suggestion-diff /> component
      // all `suggestion` markdown will be swapped out by this component

      const { suggestions, disabled, helpPagePath } = this;
      const suggestion =
        suggestions && suggestions[suggestionIndex] ? suggestions[suggestionIndex] : {};
      const fromContent = suggestion.from_content || this.fromContent;
      const fromLine = suggestion.from_line || this.fromLine;
      const SuggestionDiffComponent = Vue.extend(SuggestionDiff);
      const suggestionDiff = new SuggestionDiffComponent({
        propsData: { newLines, fromLine, fromContent, disabled, suggestion, helpPagePath },
      });

      suggestionDiff.$on('apply', ({ suggestionId, callback }) => {
        this.$emit('apply', { suggestionId, callback, flashContainer: this.$el });
      });

      return suggestionDiff;
    },
    reset() {
      // resets the container HTML (replaces it with the updated noteHTML)
      // calls `renderSuggestions` once the updated noteHTML is added to the DOM

      this.$refs.container.innerHTML = this.noteHtml;
      this.isRendered = false;
      this.renderSuggestions();
      this.$nextTick(() => this.renderSuggestions());
    },
  },
};
</script>

<template>
  <div>
    <div class="flash-container js-suggestions-flash"></div>
    <div v-show="isRendered" ref="container"></div>
  </div>
</template>
