/* eslint no-param-reassign: [ "error", { "props": true, "ignorePropertyModificationsFor": [ row, element, link ] } ] */

const specialProcessors = new Map([
  [
    'divider',
    row => {
      row.classList.add('divider');

      return row;
    },
  ],
  [
    'separator',
    row => {
      row.classList.add('separator');

      return row;
    },
  ],
  [
    'header',
    (row, chunk) => {
      row.classList.add('dropdown-header');
      row.innerHTML = chunk.content;

      return row;
    },
  ],
]);
let propertyGetters;

function defaultPropertyGetter({ property, chunk, options, defaultValue = '' }) {
  let result;

  if (options[property] != null) {
    result = options[property](chunk);
  } else {
    result = chunk[property] != null ? chunk[property] : defaultValue;
  }

  return result;
}

function resolveMixedPropertyToValue(property, chunk, options) {
  let resultingValue;

  if (propertyGetters.has(property)) {
    resultingValue = propertyGetters.get(property)(chunk, options);
  }

  return resultingValue;
}

propertyGetters = new Map([
  [
    'url',
    (chunk, options) =>
      defaultPropertyGetter({
        property: 'url',
        defaultValue: '#',
        chunk,
        options,
      }),
  ],
  [
    'text',
    (chunk, options) =>
      defaultPropertyGetter({
        property: 'text',
        chunk,
        options,
      }),
  ],
  [
    'highlight',
    (chunk, options) => {
      let text = resolveMixedPropertyToValue('text', chunk, options);

      if (options.highlight) {
        text = chunk.template
          ? options.highlightTemplate(text, chunk.template)
          : options.highlightText(text);
      }

      return text;
    },
  ],
  [
    'icon',
    (chunk, options) => {
      let text = resolveMixedPropertyToValue('highlight', chunk, options);

      if (options.icon) {
        text = `<span>${text}</span>`;
        text = chunk.icon ? `${chunk.icon}${text}` : text;
      }

      return text;
    },
  ],
]);

function escape(text) {
  return text ? String(text).replace(/'/g, "\\'") : text;
}

function getOptionValue(chunk, options) {
  let value;

  if (!options.renderRow) {
    value = escape(options.id ? options.id(chunk) : chunk.id);
  }

  return value;
}

function shouldHide(chunk, options) {
  const value = getOptionValue(chunk, options);

  return options.hideRow && options.hideRow(value);
}

function hideElement(element) {
  element.style.display = 'none';

  return element;
}

function ingestOptions(options, group, index) {
  const ingested = Object.assign({}, options, {
    params: {
      group,
      index,
    },
  });

  if (options.renderRow) {
    ingested.renderRow = options.renderRow.bind(options);
  }

  return ingested;
}

function checkSelected(chunk, options) {
  const value = getOptionValue(chunk, options);
  let selected = !chunk.id;

  if (options.parent) {
    selected = options.parent.querySelector(`input[name='${options.fieldName}']`) == null;

    if (value) {
      selected =
        options.parent.querySelector(`input[name='${options.fieldName}'][value='${value}']`) !=
        null;
    }
  }

  return selected;
}

function createLink(url, selected, options) {
  const link = document.createElement('a');

  link.href = url;
  link.classList.toggle('is-active', selected);

  if (options.icon) {
    link.classList.add('d-flex', 'align-items-center');
  }

  return link;
}

function assignTextToLink(link, chunk, options) {
  const text = resolveMixedPropertyToValue('icon', chunk, options);

  if (options.icon || options.highlight) {
    link.innerHTML = text;
  } else {
    link.textContent = text;
  }

  return link;
}

function generateLink(row, chunk, options) {
  const selected = checkSelected(chunk, options);
  const url = resolveMixedPropertyToValue('url', chunk, options);
  let link = createLink(url, selected, options);

  link = assignTextToLink(link, chunk, options);

  if (options.params.group) {
    link.dataset.group = options.params.group;
    link.dataset.index = options.params.index;
  }

  row.appendChild(link);

  return row;
}

function standardRender(li, chunk, options) {
  let row;

  if (options.renderRow) {
    // Arbitrary consumer override
    row = options.renderRow(chunk);
  } else {
    // Default render logic
    row = generateLink(li, chunk, options);
  }

  return row;
}

export default function item({ data: chunk, options = {}, group = false, index = false }) {
  const opts = ingestOptions(options, group, index);
  let li = document.createElement('li');

  if (shouldHide(chunk, opts)) {
    li = hideElement(li);
  } else if (specialProcessors.has(chunk.type)) {
    li = specialProcessors.get(chunk.type)(li, chunk);
  } else {
    li = standardRender(li, chunk, opts);
  }

  return li;
}
