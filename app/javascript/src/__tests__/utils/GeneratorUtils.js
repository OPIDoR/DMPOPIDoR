import * as utils from '../../utils/GeneratorUtils';

describe('GeneratorUtils.parsePattern', () => {
  const keys = ['$.firstName', ' ', '$.lastName', ' (', '$.mbox', ')'];
  const data = {
    firstName: 'Jean',
    lastName: 'Dupont',
    mbox: 'jean.dupont@cnrs.fr',
  };
  const expectedValue = 'Jean Dupont (jean.dupont@cnrs.fr)';
  test('parsePattern should return stringified data when keys is empty', () => {
    const toStringValue = utils.parsePattern(data, []);
    expect(toStringValue).toBe(JSON.stringify(data));
  });
  test('parsePattern should return expected value when executed', () => {
    const toStringValue = utils.parsePattern(data, keys);
    expect(toStringValue).toBe(expectedValue);
  });
});
describe('GeneratorUtils.createOptions', () => {
  test('createOptions on simple registry', () => {
    const registriesValues = [
      {
        fr_FR: 'Ouvert',
        en_GB: 'Open',
      },
      {
        fr_FR: 'Restreint',
        en_GB: 'Restricted',
      },
    ];
    const expectedOptions = [
      {
        label: 'Ouvert',
        value: 'Ouvert',
        object: {
          fr_FR: 'Ouvert',
          en_GB: 'Open',
        },
      },
      {
        label: 'Restreint',
        value: 'Restreint',
        object: {
          fr_FR: 'Restreint',
          en_GB: 'Restricted',
        },
      },
    ];
    const generatedOptions = utils.createOptions(registriesValues, 'fr_FR');
    expect(generatedOptions).toStrictEqual(expectedOptions);
  });
  test('createOptions on simple registry with value', () => {
    const registriesValues = [{
      label: {
        fr_FR: '1.1 Mathématiques',
        en_GB: '1.1 Mathematics',
      },
      value: '1.1 Mathematics',
    }];
    const expectedOptions = [
      {
        label: '1.1 Mathématiques',
        value: '1.1 Mathematics',
        object: {},
      },
    ];
    const generatedOptions = utils.createOptions(registriesValues, 'fr_FR');
    expect(generatedOptions).toStrictEqual(expectedOptions);
  });
  test('createOptions on complex registry', () => {
    const registriesValues = [{
      label: {
        en_GB: 'CC-BY-4.0',
        fr_FR: 'CC-BY-4.0',
      },
      licenseName: 'Creative Commons Attribution 4.0 International',
      licenseUrl: 'http://spdx.org/licenses/CC-BY-4.0.json',
    }];
    const expectedOptions = [
      {
        label: 'CC-BY-4.0',
        value: 'CC-BY-4.0',
        object: {
          licenseName: 'Creative Commons Attribution 4.0 International',
          licenseUrl: 'http://spdx.org/licenses/CC-BY-4.0.json',
        },
      },
    ];
    const generatedOptions = utils.createOptions(registriesValues, 'fr_FR');
    expect(generatedOptions).toStrictEqual(expectedOptions);
  });
});
describe('GeneratorUtils.createRegistryPlaceholder', () => {
  const mockedT = (str) => str;
  test('createRegistryPlaceholder should generate "Select a value from the list" placeholder', () => {
    const placeholder = utils.createRegistryPlaceholder(1, false, false, 'simple', mockedT);
    expect(placeholder).toBe('Select a value from the list');
  });
  test('createRegistryPlaceholder should generate "Select a value from the list or type a new one" placeholder', () => {
    const placeholder = utils.createRegistryPlaceholder(1, false, true, 'simple', mockedT);
    expect(placeholder).toBe('Select a value from the list or type a new one');
  });
  test('createRegistryPlaceholder should generate "Select a value from the list or create a new one by clicking on +" placeholder', () => {
    const placeholder = utils.createRegistryPlaceholder(1, false, true, 'complex', mockedT);
    expect(placeholder).toBe('Select a value from the list or create a new one by clicking on +');
  });

  test('createRegistryPlaceholder should generate "Select one or multiple values from the list" placeholder', () => {
    const placeholder = utils.createRegistryPlaceholder(1, true, false, 'simple', mockedT);
    expect(placeholder).toBe('Select one or multiple values from the list');
  });
  test('createRegistryPlaceholder should generate "Select one or multiple values from the list or type a new one" placeholder', () => {
    const placeholder = utils.createRegistryPlaceholder(1, true, true, 'simple', mockedT);
    expect(placeholder).toBe('Select one or multiple values from the list or type a new one');
  });
  test('createRegistryPlaceholder should generate "Select one or multiple values from the list or create a new one by clicking on +" placeholder', () => {
    const placeholder = utils.createRegistryPlaceholder(1, true, true, 'complex', mockedT);
    expect(placeholder).toBe('Select one or multiple values from the list or create a new one by clicking on +');
  });
});
describe('GeneratorUtils.createFormLabel', () => {
  const propertyWithFormLabel = {
    'form_label@fr_FR': 'Mon form label en français',
    'form_label@en_GB': 'My form label in english',
    'label@fr_FR': 'Mon label en français',
    'label@en_GB': 'My label in english',
  };
  const propertyWithoutFormLabel = {
    'label@fr_FR': 'Mon label en français',
    'label@en_GB': 'My label in english',
  };
  const propertyWithoutFrenchLabel = {
    'label@en_GB': 'My label in english',
  };
  test('createFormLabel should return expected form label', async () => {
    const generatedFrenchLabel = utils.createFormLabel(propertyWithFormLabel, 'fr_FR');
    const generatedEnglishLabel = utils.createFormLabel(propertyWithFormLabel, 'en_GB');
    expect(generatedFrenchLabel).toBe(propertyWithFormLabel['form_label@fr_FR']);
    expect(generatedEnglishLabel).toBe(propertyWithFormLabel['form_label@en_GB']);
  });
  test('createFormLabel should return expected label', async () => {
    const generatedFrenchLabel = utils.createFormLabel(propertyWithoutFormLabel, 'fr_FR');
    const generatedEnglishLabel = utils.createFormLabel(propertyWithoutFormLabel, 'en_GB');
    expect(generatedFrenchLabel).toBe(propertyWithFormLabel['label@fr_FR']);
    expect(generatedEnglishLabel).toBe(propertyWithFormLabel['label@en_GB']);
  });
  test('createFormLabel should return "No label defined" when there is no available label', async () => {
    const generatedLabel = utils.createFormLabel(propertyWithoutFrenchLabel, 'fr_FR');
    expect(generatedLabel).toBe('No label defined');
  });
});
describe('GeneratorUtils.filterOptions', () => {
  const options = [
    {
      label: 'this value should be kept',
      value: 'this value should be kept',
      object: {
        data: 'data',
      },
    },
    {
      label: 'this value should not be kept',
      value: 'this value should not be kept',
      object: {
        data: 'data',
      },
    },
  ];
  const expectedFilteredOptions = [
    {
      label: 'this value should be kept',
      value: 'this value should be kept',
      object: {
        data: 'data',
      },
    },
  ];
  test('filterOptions should return expected filtered options when executed', async () => {
    const generatedFiltered = await utils.filterOptions(options, 'should be kept');
    expect(generatedFiltered).toStrictEqual(expectedFilteredOptions);
  });
});
describe('GeneratorUtils.formatDefaultValues', () => {
  const defaults = {
    objectProperty: {
      title: 'Title',
    },
    arrayProperty: [
      {
        title: 'First Title',
      },
      {
        title: 'Second Title',
      },
    ],
  };
  const expectedDefaults = {
    objectProperty: {
      title: 'Title',
      action: 'create',
    },
    arrayProperty: [
      {
        title: 'First Title',
        action: 'create',
      },
      {
        title: 'Second Title',
        action: 'create',
      },
    ],
  };
  test('formatDefaultValues return an empty object when properties is undefined', () => {
    expect(utils.formatDefaultValues(undefined)).toStrictEqual({});
  });
  test('formatDefaultValues should add action=create to object properties', () => {
    const generatedDefaults = utils.formatDefaultValues(defaults);
    expect(generatedDefaults.objectProperty).toStrictEqual(expectedDefaults.objectProperty);
  });
  test('formatDefaultValues should add action=create to each object in array of object properties', () => {
    const generatedDefaults = utils.formatDefaultValues(defaults);
    expect(generatedDefaults.arrayProperty).toStrictEqual(expectedDefaults.arrayProperty);
  });
});
describe('GeneratorUtils.generateEmptyDefaults', () => {
  const properties = {
    description: {
      type: 'string',
      description: 'Description du projet',
      inputType: 'textarea',
      'label@fr_FR': 'Résumé',
      'label@en_GB': 'Abstract',
      tooltip: null,
      'form_label@fr_FR': 'Résumé du projet',
      'form_label@en_GB': 'Project abstract',
    },
    funding: {
      type: 'array',
      'table_header@fr_FR': 'Financeur : identifiant du financement',
      'table_header@en_GB': 'Funder: funding identifier',
      items: {
        type: 'object',
        class: 'Funding',
        properties: {
          dbid: {
            type: 'number',
          },
        },
        template_name: 'FundingStandard',
        required: [
          'dbid',
        ],
      },
      minItems: 1,
      description: 'Source(s) de financement d\'un projet ou d\'une activité de recherche',
      'label@fr_FR': 'Sources de financement',
      'label@en_GB': 'Funding',
      tooltip: null,
      'form_label@fr_FR': 'Indiquer les sources de financement du projet',
      'form_label@en_GB': 'Indicate the funding of the project',
    },
  };
  const expectedDefaults = {
    funding: [],
  };
  test('generateEmptyDefaults should return expected defaults when executed', () => {
    const generatedDefaults = utils.generateEmptyDefaults(properties);
    expect(generatedDefaults).toStrictEqual(expectedDefaults);
  });
});
describe('GeneratorUtils.researchOutputTypeToDataType', () => {
  test('researchOutputTypeToDataType should return "software" when "Software" is provided', () => {
    const dataType = utils.researchOutputTypeToDataType('Software');
    expect(dataType).toBe('software');
  });
  test('researchOutputTypeToDataType should return "software" when "Logiciel" is provided', () => {
    const dataType = utils.researchOutputTypeToDataType('Logiciel');
    expect(dataType).toBe('software');
  });
  test('researchOutputTypeToDataType should return "none" when "Something" is provided', () => {
    const dataType = utils.researchOutputTypeToDataType('Something');
    expect(dataType).toBe('none');
  });
});
