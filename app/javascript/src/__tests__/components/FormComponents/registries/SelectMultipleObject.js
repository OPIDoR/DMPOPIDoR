import React from 'react';
import {
  cleanup, fireEvent, render, screen, waitFor,
} from '@testing-library/react';
import selectEvent from 'react-select-event';
import SelectMultipleObject from '../../../../components/FormComponents/registries/SelectMultipleObject';

import { Wrapper } from '../../../__utils__/reactHookFormHelpers';
import Global from '../../../../components/context/Global';
import { service } from '../../../../services/index';

jest.mock('react-i18next', () => ({
  // this mock makes sure any components using the translate hook can use it without a warning being shown
  useTranslation: () => ({
    t: (str) => str,
    i18n: {
      changeLanguage: () => new Promise(() => { }),
    },
  }),
  initReactI18next: {
    type: '3rdParty',
    init: () => { },
  },
}));

// Mock out all top level functions, such as get, put, delete and post:
jest.mock('axios');

const props = {
  label: 'Select Multiple Object Label',
  formLabel: 'Select Multiple Object Form Label',
  propName: 'mySelectMultipleObject',
  tooltip: 'my tooltip',
  category: ['MultipleRegistryCategory'],
  topic: 'generic',
};

const mockedRegistriesData = [
  {
    name: 'MultipleRegistry1',
    values: [{
      fr_FR: 'Bonjour',
      en_GB: 'Hello',
    }],
  },
  {
    name: 'MultipleRegistry2',
    values: [{
      fr_FR: 'Bonjour',
      en_GB: 'Hello',
    }],
  },
];

afterEach(() => {
  cleanup();
  // restore the spy created with spyOn
  jest.restoreAllMocks();
});

describe('SelectMultipleObject component', () => {
  test('component rendering', async () => {
    const spy = jest.spyOn(service, 'getAvailableRegistries');
    spy.mockImplementation((category, dataType, topic) => Promise.resolve({ data: [mockedRegistriesData[0]] }));
    const spyGetRegistryByName = jest.spyOn(service, 'getRegistryByName');
    render(
      <Global>
        <Wrapper propName={props.propName}>
          <SelectMultipleObject {...props} />
        </Wrapper>
      </Global>,
    );
    expect(screen.getByTestId('select-multiple-object-label')).toHaveTextContent(props.formLabel);
    expect(screen.queryByTestId('select-multiple-object-registry-selector')).not.toBeInTheDocument();
    expect(screen.getByTestId(/tooltip_info_icon_[0-9]+/i)).toBeInTheDocument();
    expect(screen.getByTestId('select-multiple-object-div')).toBeInTheDocument();
    expect(screen.getByTestId('select-multiple-object-div')).toHaveTextContent('Select one or multiple values from the list');
    expect(spy).toHaveBeenCalledWith(props.category, props.dataType);
    expect(spyGetRegistryByName).not.toHaveBeenCalled();
  });
  test('component rendering with multiple registries', async () => {
    const spy = jest.spyOn(service, 'getAvailableRegistries');
    spy.mockImplementation((category, dataType, topic) => Promise.resolve({ data: mockedRegistriesData })); // replace implementation
    const spyGetRegistryByName = jest.spyOn(service, 'getRegistryByName');
    render(
      <Global>
        <Wrapper propName={props.propName}>
          <SelectMultipleObject {...props} />
        </Wrapper>
      </Global>,
    );
    expect(screen.getByTestId('select-multiple-object-label')).toHaveTextContent(props.formLabel);
    expect(screen.queryByTestId('select-multiple-object-registry-selector')).toBeInTheDocument();
    expect(screen.getByText('Select a registry')).toBeInTheDocument();
    expect(screen.getByTestId(/tooltip_info_icon_[0-9]+/i)).toBeInTheDocument();
    expect(screen.getByTestId('select-multiple-object-div')).toBeInTheDocument();
    expect(screen.getByTestId('select-multiple-object-div')).toHaveTextContent('Then select one or multiple values from the list');
    expect(spy).toHaveBeenCalledWith(props.category, props.dataType);
    expect(spyGetRegistryByName).not.toHaveBeenCalled();
  });
  test('component with multiple registry should call getRegistryByName when choosing a registry', async () => {
    const spy = jest.spyOn(service, 'getAvailableRegistries');
    spy.mockImplementation((category, dataType, topic) => Promise.resolve({ data: mockedRegistriesData }));
    const spyGetRegistryByName = jest.spyOn(service, 'getRegistryByName');
    render(
      <Global>
        <Wrapper propName={props.propName} data={[]}>
          <SelectMultipleObject {...props} />
        </Wrapper>
      </Global>,
    );
    const registrySelector = await screen.getByText('Select a registry');
    expect(registrySelector).toBeInTheDocument();
    selectEvent.openMenu(registrySelector);

    const registry = await findByText('MultipleRegistry1');
    await waitFor(() => expect(registry).toBeInTheDocument());
    fireEvent.click(screen.getByText('MultipleRegistry1'));
    await waitFor(() => expect(spyGetRegistryByName).toHaveBeenCalledWith('MultipleRegistry1'));
  });
});
