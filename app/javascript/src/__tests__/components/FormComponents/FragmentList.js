import React from 'react';
import {
  cleanup, fireEvent, render, screen,
} from '@testing-library/react';
import FragmentList from '../../../components/FormComponents/FragmentList';

const mockHandleEdit = jest.fn();
const mockHandleDelete = jest.fn();

const fragmentListProps = {
  fragmentsList: [{ title: 'First Line' }, { title: 'Second Line' }],
  handleEdit: mockHandleEdit,
  handleDelete: mockHandleDelete,
  tableHeader: 'My Header',
};

afterEach(cleanup);

describe('FragmentList component', () => {
  test('component rendering without lines', async () => {
    const emptyFragmentListProps = { ...fragmentListProps, fragmentsList: [], tableHeader: null };
    render(<FragmentList {...emptyFragmentListProps} />);

    expect(screen.getByTestId('fragment-list-table')).toBeInTheDocument();
    expect(screen.getByTestId('fragment-list-table-body')).toBeInTheDocument();
    expect(screen.queryByTestId(/fragment-list-row-[0-9]+/i)).not.toBeInTheDocument();
    expect(screen.queryByTestId('fragment-list-table-header')).not.toBeInTheDocument();
  });

  test('component rendering with lines', async () => {
    const data = fragmentListProps.fragmentsList;
    render(<FragmentList {...fragmentListProps} />);

    expect(screen.getByTestId('fragment-list-table')).toBeInTheDocument();
    expect(screen.getByTestId('fragment-list-table-header')).toBeInTheDocument();
    expect(screen.getByTestId('fragment-list-table-header')).toHaveTextContent(fragmentListProps.tableHeader);
    expect(screen.getByTestId('fragment-list-table-header')).toHaveTextContent('Actions');
    expect(screen.getByTestId('fragment-list-table-body')).toBeInTheDocument();
    expect(screen.queryAllByTestId(/fragment-list-row-[0-9]+/i)).toHaveLength(data.length);
    expect(screen.queryAllByTestId(/fragment-list-row-edit-btn-[0-9]+/i)).toHaveLength(data.length);
    expect(screen.queryAllByTestId(/fragment-list-row-delete-btn-[0-9]+/i)).toHaveLength(data.length);
    expect(screen.queryAllByTestId(/fragment-list-row-show-btn-[0-9]+/i)).toHaveLength(0);
  });

  test('component not rendering fragment with action=delete', async () => {
    const fragmentListWithDeleteProps = {
      ...fragmentListProps,
      fragmentsList: [{ title: 'First Line' }, { title: 'Second Line', action: 'delete' }],
    };
    render(<FragmentList {...fragmentListWithDeleteProps} />);

    expect(screen.queryAllByTestId(/fragment-list-row-[0-9]+/i)).toHaveLength(1);
    expect(screen.queryAllByTestId(/fragment-list-row-edit-btn-[0-9]+/i)).toHaveLength(1);
    expect(screen.queryAllByTestId(/fragment-list-row-delete-btn-[0-9]+/i)).toHaveLength(1);
  });

  test('component should call handleEdit clicking on button', async () => {
    render(<FragmentList {...fragmentListProps} />);

    const editIcon = screen.getByTestId('fragment-list-row-edit-btn-0');
    expect(editIcon).toBeInTheDocument();
    fireEvent.click(editIcon);
    expect(mockHandleEdit).toHaveBeenCalledWith(0);
  });

  test('component should call handleDelete when clicking on proper button', async () => {
    render(<FragmentList {...fragmentListProps} />);

    const delIcon = screen.getByTestId('fragment-list-row-delete-btn-0');
    expect(delIcon).toBeInTheDocument();
    fireEvent.click(delIcon);
    expect(mockHandleDelete).toHaveBeenCalledWith(0);
  });

  test('component should render as readonly', async () => {
    const readonlyFragmentListProps = { ...fragmentListProps, readonly: true };
    render(<FragmentList {...readonlyFragmentListProps} />);

    expect(screen.queryByTestId(/fragment-list-row-delete-btn-[0-9]+/i)).not.toBeInTheDocument();
    expect(screen.queryByTestId(/fragment-list-row-edit-btn-[0-9]+/i)).not.toBeInTheDocument();
    expect(screen.queryAllByTestId(/fragment-list-row-show-btn-[0-9]+/i)).toHaveLength(2);

    const showIcon = screen.getByTestId('fragment-list-row-show-btn-0');
    expect(showIcon).toBeInTheDocument();
    fireEvent.click(showIcon);
    expect(mockHandleEdit).toHaveBeenCalledWith(0);
  });

  test('component should render with const values', async () => {
    const readonlyFragmentListProps = { ...fragmentListProps, isConst: true };
    render(<FragmentList {...readonlyFragmentListProps} />);

    expect(screen.queryAllByTestId(/fragment-list-row-show-btn-[0-9]+/i)).toHaveLength(2);
    expect(screen.queryAllByTestId(/fragment-list-row-delete-btn-[0-9]+/i)).toHaveLength(2);
  });

  test('component should render fragment value according to templateToString', async () => {
    const toStringFragmentListProps = {
      ...fragmentListProps,
      fragmentsList: [{ name: 'myName', email: 'test@test.fr' }],
      templateToString: ['$.name', ' ( ', '$.email', ' )'],
    };
    render(<FragmentList {...toStringFragmentListProps} />);

    expect(screen.getByTestId('fragment-list-row-value-0')).toBeInTheDocument();
    expect(screen.getByTestId('fragment-list-row-value-0')).toHaveTextContent('myName ( test@test.fr )');
  });
});
