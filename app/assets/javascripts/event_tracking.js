import $ from 'jquery';

const extractData = (el, opts = {}) => {
  const { trackAction, trackLabel = '', trackProperty = '', trackContext } = el.dataset;
  let trackValue = el.dataset.trackValue || el.value || '';
  if (el.type === 'checkbox' && !el.checked) trackValue = false;
  return [
    trackAction + (opts.suffix || ''),
    {
      label: trackLabel,
      property: trackProperty,
      value: trackValue,
      context: trackContext,
    },
  ];
};

export default class EventTracking {
  static trackable() {
    return !['1', 'yes'].includes(
      window.doNotTrack || navigator.doNotTrack || navigator.msDoNotTrack,
    );
  }

  static enabled() {
    return typeof window.snowplow === 'function' && this.trackable();
  }

  static track(category = document.body.dataset.page, action = 'generic', data = {}) {
    if (!this.enabled()) return false;
    // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
    if (!category) throw new Error('Tracking: no category provided for tracking.');

    return window.snowplow(
      'trackStructEvent',
      category,
      action,
      Object.assign({}, { label: '', property: '', value: '', context: undefined }, data),
    );
  }

  constructor(category = document.body.dataset.page) {
    this.category = category;
  }

  bind(container = document) {
    if (!this.constructor.enabled()) return;
    container.querySelectorAll(`[data-track-action]`).forEach(el => {
      if (this.customHandlingFor(el)) return;
      // jquery is required for select2, so we use it always
      // see: https://github.com/select2/select2/issues/4686
      $(el).on('click', this.eventHandler(this.category));
    });
  }

  customHandlingFor(el) {
    const classes = el.classList;

    // bootstrap dropdowns
    if (classes.contains('dropdown')) {
      $(el).on('show.bs.dropdown', this.eventHandler(this.category, { suffix: '_show' }));
      $(el).on('hide.bs.dropdown', this.eventHandler(this.category, { suffix: '_hide' }));
      return true;
    }

    return false;
  }

  eventHandler(category = null, opts = {}) {
    return e => {
      this.constructor.track(category || this.category, ...extractData(e.currentTarget, opts));
    };
  }
}
