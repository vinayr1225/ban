import $ from 'jquery';
import { setHTMLFixture } from './helpers/fixtures';

import EventTracking from '~/event_tracking';

describe('EventTracking', () => {
  let snowplowSpy;

  beforeEach(() => {
    window.snowplow = window.snowplow || (() => {});
    snowplowSpy = jest.spyOn(window, 'snowplow');
  });

  describe('.track', () => {
    afterEach(() => {
      window.doNotTrack = undefined;
      navigator.doNotTrack = undefined;
      navigator.msDoNotTrack = undefined;
    });

    it('tracks to snowplow (our current tracking system)', () => {
      EventTracking.track('_category_', '_action_', { label: '_label_' });

      expect(snowplowSpy).toHaveBeenCalledWith('trackStructEvent', '_category_', '_action_', {
        label: '_label_',
        property: '',
        value: '',
      });
    });

    it('skips tracking if snowplow is unavailable', () => {
      window.snowplow = false;
      EventTracking.track('_category_', '_action_');

      expect(snowplowSpy).not.toHaveBeenCalled();
    });

    it('skips tracking if the user does not want to be tracked (general spec)', () => {
      window.doNotTrack = '1';
      EventTracking.track('_category_', '_action_');

      expect(snowplowSpy).not.toHaveBeenCalled();
    });

    it('skips tracking if the user does not want to be tracked (firefox legacy)', () => {
      navigator.doNotTrack = 'yes';
      EventTracking.track('_category_', '_action_');

      expect(snowplowSpy).not.toHaveBeenCalled();
    });

    it('skips tracking if the user does not want to be tracked (IE legacy)', () => {
      navigator.msDoNotTrack = '1';
      EventTracking.track('_category_', '_action_');

      expect(snowplowSpy).not.toHaveBeenCalled();
    });
  });

  describe('tracking interface events', () => {
    let eventSpy;

    beforeEach(() => {
      eventSpy = jest.spyOn(EventTracking, 'track');
      setHTMLFixture(`
        <input data-track-action="click_input1" data-track-label="_label_" value="_value_"/>
        <input data-track-action="click_input2" data-track-value="_value_override_" value="_value_"/>
        <input data-track-action="click_input3" data-track-context="{foo: 'bar'}"/>
        <input type="checkbox" data-track-action="toggle_checkbox" value="_value_" checked/>
        <input class="dropdown" data-track-action="toggle_dropdown"/>
        <div class="js-projects-list-holder"></div>
      `);
      new EventTracking('_category_').bind();
    });

    it('binds to clicks on elements matching [data-track-action]', () => {
      $('[data-track-action="click_input1"]').click();

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'click_input1', {
        label: '_label_',
        value: '_value_',
        property: '',
        context: undefined,
      });
    });

    it('allows value override with the data-track-value attribute', () => {
      $('[data-track-action="click_input2"]').click();

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'click_input2', {
        label: '',
        value: '_value_override_',
        property: '',
        context: undefined,
      });
    });

    it('allows providing context for the tracking call', () => {
      $('[data-track-action="click_input3"]').click();

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'click_input3', {
        label: '',
        property: '',
        value: '',
        context: "{foo: 'bar'}",
      });
    });

    it('handles checkbox values correctly', () => {
      const $checkbox = $('[data-track-action="toggle_checkbox"]');

      $checkbox.click(); // unchecking

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'toggle_checkbox', {
        label: '',
        property: '',
        value: false,
      });

      $checkbox.click(); // checking

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'toggle_checkbox', {
        label: '',
        property: '',
        value: '_value_',
      });
    });

    it('handles bootstrap dropdowns', () => {
      const $dropdown = $('[data-track-action="toggle_dropdown"]');

      $dropdown.trigger('show.bs.dropdown'); // showing

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'toggle_dropdown_show', {
        label: '',
        property: '',
        value: '',
      });

      $dropdown.trigger('hide.bs.dropdown'); // hiding

      expect(eventSpy).toHaveBeenCalledWith('_category_', 'toggle_dropdown_hide', {
        label: '',
        property: '',
        value: '',
      });
    });
  });
});
