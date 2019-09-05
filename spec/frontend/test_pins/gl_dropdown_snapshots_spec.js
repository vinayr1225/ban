import $ from 'jquery';
import { GitLabDropdown } from '~/gl_dropdown';

const TEST_FIELD_NAME = 'FIELD';
const TEST_GROUP = 'TEST_GROUP';
const TEST_TEMPLATE = 'TEST_TEMPLATE';
const TEST_SEARCH = 'lor';

const createTestData = () => [
  { type: 'header', content: 'Lorem' },
  { text: 'Any' },
  { id: '1', text: 'Lorem', template: TEST_TEMPLATE, icon: '😀' },
  { id: 2, text: 'Ipsum', template: TEST_TEMPLATE, icon: '' },
  { id: 3, text: 'Dolar', icon: '😀' },
  { id: 4, text: 'Sit Lorrr', icon: '' },
  { id: 5, text: '', template: TEST_TEMPLATE, icon: '😀' },
  { id: 6, text: '', template: TEST_TEMPLATE, icon: '' },
  { id: 7, icon: '😀' },
  { id: 8 },
  { id: 9, text: 'Am\'i"t' },
  { id: 15, text: 'Consecutur', type: 'header', content: 'More things' },
  { type: 'divider' },
  { id: '10', text: 'Nu<strong>n</strong>c', bogus: '123', template: TEST_TEMPLATE, icon: '😀' },
  { id: 11, text: 'Praesent Lorr', bogus: '456', template: TEST_TEMPLATE, icon: '' },
  { id: 12, text: 'Proin', bogus: '789', icon: '😀' },
  { text: 'Sed', bogus: '101', icon: '' },
  { text: 'Fusce' },
  { type: 'separator' },
];

const testRenderRow = (data, instance) => `<div>renderRow: ${data.text} ${instance.bogus}</div>`;
const testId = data => Number(data.id) + 10;
const testHideRow = val => val && Number(val) % 3 === 0;
const testUrl = data => `http://example.com/thing/${data.id}`;
const testText = data => `text: ${data.text}`;

describe('gl_dropdown snapshots', () => {
  let el;
  let instance;

  beforeEach(() => {
    el = $('<div class="root">');

    const dropdown = $('<div class="dropdown">');
    const filterInput = $(`<input type="text" value="${TEST_SEARCH}" />`);

    el.append(dropdown);
    el.append(filterInput);

    instance = {
      ...GitLabDropdown.prototype,
      filterInput,
      dropdown,
      bogus: 'instance',
    };
  });

  afterEach(() => {
    el.remove();
    el = null;

    instance = null;
  });

  describe('renderData', () => {
    describe.each`
      group         | selection
      ${null}       | ${''}
      ${TEST_GROUP} | ${''}
      ${null}       | ${'12'}
      ${TEST_GROUP} | ${'12'}
    `('with group ($group) and selection ("$selection")', ({ group, selection }) => {
      describe.each`
        renderRow        | hideRow        | id        | url        | text        | highlight | icon
        ${testRenderRow} | ${null}        | ${null}   | ${null}    | ${null}     | ${false}  | ${false}
        ${testRenderRow} | ${testHideRow} | ${null}   | ${null}    | ${null}     | ${false}  | ${false}
        ${null}          | ${null}        | ${null}   | ${null}    | ${null}     | ${false}  | ${false}
        ${null}          | ${testHideRow} | ${null}   | ${null}    | ${null}     | ${false}  | ${false}
        ${null}          | ${testHideRow} | ${testId} | ${null}    | ${null}     | ${false}  | ${false}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${null}     | ${false}  | ${false}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${null}     | ${true}   | ${false}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${null}     | ${false}  | ${true}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${testText} | ${false}  | ${false}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${testText} | ${true}   | ${false}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${testText} | ${false}  | ${true}
        ${null}          | ${testHideRow} | ${testId} | ${testUrl} | ${testText} | ${true}   | ${true}
      `(
        'with renderRow ($renderRow) and hideRow ($hideRow) and id ($id) and url ($url) and text ($text) and highlight ($highlight) and icon ($icon)',
        ({ renderRow, hideRow, id, url, text, highlight, icon }) => {
          beforeEach(() => {
            el.append(`<input name="${TEST_FIELD_NAME}" value="${selection}" type="hidden" />`);

            Object.assign(instance, {
              options: {
                fieldName: TEST_FIELD_NAME,
                renderRow,
                hideRow,
                id,
                url,
                text,
              },
              highlight,
              icon,
            });
          });

          it('should match snapshot', () => {
            const result = instance.renderData(createTestData(), group);

            expect(result).toMatchSnapshot();
          });
        },
      );
    });
  });
});
