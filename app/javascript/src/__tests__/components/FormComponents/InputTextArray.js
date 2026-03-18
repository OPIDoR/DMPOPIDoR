import React from 'react';
import {
  cleanup, fireEvent, render, screen, waitFor,
} from '@testing-library/react';

import InputTextArray from '../../../components/FormComponents/InputTextArray';
import { Wrapper } from '../../__utils__/reactHookFormHelpers';

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

const inputTextArrayProps = {
  label: 'Input Text Array Label',
  propName: 'myArrayInput',
  tooltip: 'my tooltip',
  placeholder: 'my placeholder',
};

afterEach(cleanup);

describe('InputTextArray component', () => {
  test('component rendering', async () => {
    render(
      <Wrapper propName={inputTextArrayProps.propName}>
        <InputTextArray {...inputTextArrayProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text-array-label')).toHaveTextContent(inputTextArrayProps.label);
    expect(screen.getByTestId(/custom_button_[0-9]+/i)).toBeInTheDocument();
    expect(screen.queryByTestId(/input-text-array-div-[0-9]+/i)).not.toBeInTheDocument();
    expect(screen.queryByTestId(/input-text-array-[0-9]+/i)).not.toBeInTheDocument();
    expect(screen.getByTestId(/tooltip_info_icon_[0-9]+/i)).toBeInTheDocument();
  });

  test('component rendering input with value', async () => {
    const propName = inputTextArrayProps.propName;
    render(
      <Wrapper propName={propName} data={['myText1']}>
        <InputTextArray {...inputTextArrayProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text-array-div-0')).toBeInTheDocument();
    expect(screen.getByTestId('input-text-array-0')).toBeInTheDocument();
    expect(screen.getByTestId('input-text-array-0').value).toBe('myText1');
  });

  test('component rendering input when clicking on add button', async () => {
    render(
      <Wrapper propName={inputTextArrayProps.propName}>
        <InputTextArray {...inputTextArrayProps} />
      </Wrapper>,
    );
    expect(screen.queryByTestId('input-text-array-div-0')).not.toBeInTheDocument();
    const button = screen.getByTestId(/custom_button_[0-9]+/i);
    fireEvent.click(button);
    await waitFor(() => screen.getByTestId('input-text-array-div-0'));
    expect(screen.getByTestId('input-text-array-div-0')).toBeInTheDocument();
    const delIcon = screen.getByTestId('input-text-array-delete-icon-0');
    expect(delIcon).toBeInTheDocument();
  });

  test('component removing input when clicking on delete button', async () => {
    const propName = inputTextArrayProps.propName;
    const data = ['myText1', 'myText2'];
    render(
      <Wrapper propName={propName} data={data}>
        <InputTextArray {...inputTextArrayProps} />
      </Wrapper>,
    );
    expect(screen.queryAllByTestId(/input-text-array-div-[0-9]+/i)).toHaveLength(data.length);
    const delIcon = screen.getByTestId('input-text-array-delete-icon-0');
    expect(delIcon).toBeInTheDocument();
    fireEvent.click(delIcon);
    await waitFor(() => screen.queryAllByTestId(/input-text-array-div-[0-9]+/i));
    expect(screen.queryAllByTestId(/input-text-array-div-[0-9]+/i)).toHaveLength(data.length - 1);
  });

  test('component rendering as readonly', async () => {
    const inputTextArrayReadonlyProps = { ...inputTextArrayProps, readonly: true };
    render(
      <Wrapper propName={inputTextArrayReadonlyProps.propName} data={['myText1']}>
        <InputTextArray {...inputTextArrayReadonlyProps} />
      </Wrapper>,
    );
    expect(screen.getByTestId('input-text-array-div-0')).toBeInTheDocument();
    expect(screen.getByTestId('input-text-array-0')).toBeInTheDocument();
    expect(screen.getByTestId('input-text-array-0').value).toBe('myText1');
    expect(screen.getByTestId('input-text-array-0')).toHaveAttribute('readonly');
    expect(screen.queryByTestId('input-text-array-delete-icon-0')).not.toBeInTheDocument();
    expect(screen.queryByTestId(/custom_button_[0-9]+/i)).not.toBeInTheDocument();
  });
});
