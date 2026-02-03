import { stringIncludes } from './utils';

/**
 * It takes a JSON object and a list of keys, and returns a string that is the concatenation of the values of the keys in the JSON object
 * @param {Object} data - the data object
 * @param {Array} keys - ["$..name", "$..age", "$..address.street"]
 * @returns {string} The value of the key in the object.
 */
export function parsePattern(data, keys = []) {
  if (keys.length === 0) return JSON.stringify(data);
  const isArrayMatch = /^(.*)\[[0-9]+\]$/gi;

  return keys.map((value) => {
    if (!value.startsWith('$.')) { return value; }

    return value.substr(2).trim().split('.').reduce((acc, cur) => {
      const match = cur.match(isArrayMatch);
      if (match) {
        const [, objeKey, arrIndex] = match;
        return acc?.[objeKey]?.[arrIndex];
      }
      return acc?.[cur];
    }, data) || '';
  }).join('');
}

/**
 * Creates a list of options from registry values.
 *
 * @param {Array} registryValues - The registry values from which to create the options.
 * @param {string} locale - The locale used to retrieve option labels.
 * @returns {Array} - An array of option objects, each object having a `value`, `label`, and `object` property.
 *                   The first option is an empty option with empty value and label.
 */
export function createOptions(registryValues, locale) {
  return [...registryValues.map((option) => {
    let { label, value, ...optionValue } = option;
    label = label ? label[locale] : optionValue[locale];
    if (!value) {
      value = label;
    }

    return {
      value,
      label,
      object: optionValue,
    };
  })];
}

/**
 * Creates a placeholder message for a registry based on certain conditions.
 *
 * @param {number} registriesLength - Registries array length.
 * @param {boolean} multipleRegistry - Can the user select multiple values ?
 * @param {boolean} overridable - Whether the registry is overridable.
 * @param {string} registryType - The type of the registry.
 * @returns {string} - The placeholder message for the registry.
 */
export function createRegistryPlaceholder(registriesLength, multipleRegistry, overridable, registryType, t) {
  let placeholder = '';
  placeholder += registriesLength > 1 ? t('thenSelect') : t('select');
  placeholder += multipleRegistry ? t('selectMultiple') : t('selectOne');
  if (overridable) {
    placeholder += registryType === 'complex' ? t('createNewPlus') : t('createNew');
  }
  return placeholder;
}

/**
 * This function extracts the label from a template property.
 * Returns the form_label if it exists, if not the label, if neither return a 'No label defined' value
 * @param property : the template property to extract the label from
 * @param locale : the locale of the form
 * @returns if it exists a label in the form language
 */
export function createFormLabel(property, locale) {
  return property[`form_label@${locale}`] || property[`label@${locale}`] || 'No label defined';
}

/**
 * This function is used by async selects. It takes an array of select options and filter it based on the value passed as a parameter
 * @param options - options of a select list
 * @param value - value used to search options in a select
 */
export function filterOptions(options, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(options.filter((o) => stringIncludes(o.label, value)));
    }, 500);
  });
}

/**
 * This function is used to add the 'create' action to data in default values
 */
export function formatDefaultValues(defaults) {
  if (defaults === undefined) return {};
  const formatedDefaults = { ...defaults };

  Object.keys(defaults).forEach((prop) => {
    if (Array.isArray(defaults[prop])) {
      formatedDefaults[prop] = defaults[prop].map((d) => ({ ...d, action: 'create' }));
    } else if (typeof defaults[prop] === 'object') {
      formatedDefaults[prop] = { ...defaults[prop], action: 'create' };
    }
  });
  return formatedDefaults;
}

export function generateEmptyDefaults(properties = {}) {
  const emptyDefaults = {};
  for (const [key, prop] of Object.entries(properties)) {
    if (prop.type === 'array' && prop.items?.type === 'object') {
      emptyDefaults[key] = [];
    }
  }
  return emptyDefaults;
}

export function researchOutputTypeToDataType(type) {
  switch (type) {
  case 'Logiciel':
  case 'Software':
    return 'software';
  default:
    return 'none';
  }
}

export function displayPersonalData(researchOutputType) {
  const typesWithoutPersonalData = ['software', 'logiciel'];

  return !typesWithoutPersonalData.includes(researchOutputType?.toLowerCase());
}

export function displayTopics(researchOutputType) {
  const typesWithoutTopics = ['software', 'logiciel'];

  return !typesWithoutTopics.includes(researchOutputType?.toLowerCase());
}
