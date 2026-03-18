import React from 'react';
import { cleanup, render, screen } from '@testing-library/react';
import PersonsList from '../../../components/FormComponents/PersonsList';

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

const mockHandleEdit = jest.fn();
const mockHandleDelete = jest.fn();

const personsListProps = {
  personsList: [
    { lastName: 'LastName1', firstName: 'FirstName1', mbox: 'f.n@example.fr' },
    { lastName: 'LastName2', firstName: 'FirstName2', mbox: 'f.n2@example.fr' },
  ],
  handleEdit: mockHandleEdit,
  handleDelete: mockHandleDelete,
  tableHeader: 'My Header',
};

afterEach(cleanup);

describe('PersonsList component', () => {
  test('component rendering without lines', async () => {
    const emptyPersonsListProps = { ...personsListProps, personsList: [], tableHeader: null };
    render(<PersonsList {...emptyPersonsListProps} />);

    expect(screen.getByTestId('persons-list-table')).toBeInTheDocument();
    expect(screen.getByTestId('persons-list-table-body')).toBeInTheDocument();
    expect(screen.getByTestId('persons-list-table-header')).toBeInTheDocument();
    expect(screen.queryByTestId(/persons-list-row-[0-9]+/i)).not.toBeInTheDocument();
  });

  test('component rendering with lines', async () => {
    const data = personsListProps.personsList;
    render(<PersonsList {...personsListProps} />);

    expect(screen.getByTestId('persons-list-table-header')).toHaveTextContent(personsListProps.tableHeader);
    expect(screen.getByTestId('persons-list-table-header')).toHaveTextContent('Roles');
    expect(screen.queryAllByTestId(/persons-list-row-[0-9]+/i)).toHaveLength(data.length);
    expect(screen.queryAllByTestId(/persons-list-row-edit-btn-[0-9]+/i)).toHaveLength(data.length);
    expect(screen.queryAllByTestId(/persons-list-row-delete-btn-[0-9]+/i)).toHaveLength(data.length);
    expect(screen.queryAllByTestId(/persons-list-row-show-btn-[0-9]+/i)).toHaveLength(0);
  });
  test('component not rendering edit button if parent is not form', async () => {
    const personsListInModalProps = { ...personsListProps, parent: 'modal' };
    render(<PersonsList {...personsListInModalProps} />);
    expect(screen.queryAllByTestId(/persons-list-row-edit-btn-[0-9]+/i)).toHaveLength(0);
  });
  test('component rendering default role as a string when role is constant', async () => {
    const personsListWithConstantRoleProps = { ...personsListProps, defaultRole: 'Default Role', isRoleConst: true };
    render(<PersonsList {...personsListWithConstantRoleProps} />);
    expect(screen.queryAllByTestId('select-component-role')).toHaveLength(0);
    expect(screen.getByTestId('persons-list-role-0')).toBeInTheDocument();
    expect(screen.getByTestId('persons-list-role-0')).toHaveTextContent(personsListWithConstantRoleProps.defaultRole);
  });
});
