import React from 'react';
import { act, render, screen } from '@testing-library/react';
import Question from '../../../components/WritePlan/Question';
import Global from '../../../components/context/Global';

const props = {
  planId: 1,
  question: {
    id: 1,
    text: 'Question text',
    madmp_schema: {
      id: 1,
      classname: 'my_classname',
    },
  },
  questionIdx: 0,
  sectionId: 1,
  sectionNumber: 1,
  readonly: false,
};

describe('Question component', () => {
  test('component rendering', async () => {
    await act(async () => render(
      <Global><Question {...props} /></Global>,
    ));
    // expect(screen.getByTestId("question-text")).toBeInTheDocument();
    // expect(screen.getByTestId("question-number")).toBeInTheDocument();
  });
});
