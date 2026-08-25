import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import Question from "../../../components/Question/Question";
import Global from "../../../components/context/GlobalContext";
import Forms, { FormsContext } from "../../../components/context/FormsContext";
import { SectionsContext } from "../../../components/context/SectionsContext";

const { guidances } = vi.hoisted(() => ({
  guidances: {
    hasQuestionGuidances: vi.fn().mockResolvedValue({
      data: { has_guidances: false },
    }),
  },
}));
const { madmpFragment } = vi.hoisted(() => ({
  madmpFragment: {
    getNewForm: vi.fn().mockResolvedValue({
      data: {},
    }),
    getFragment: vi.fn().mockResolvedValue({
      data: {},
    }),
  },
}));
vi.mock("../../../services/index.js", () => ({ guidances, madmpFragment }));

const props = {
  planId: 1,
  question: {
    id: 1,
    text: "Question text",
    madmp_schema: {
      id: 1,
      classname: "my_classname",
    },
  },
  questionIdx: 0,
  sectionId: 1,
  sectionNumber: 1,
  readonly: false,
};

const baseSectionsContextData = {
  displayedResearchOutput: { id: 1, answers: [] },
};

describe("Question component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component rendering as closed question", async () => {
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={baseSectionsContextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    expect(screen.getByTestId("question-collapse")).toBeInTheDocument();
    expect(screen.getByTestId("question-text")).toBeInTheDocument();
    expect(screen.getByTestId("question-text")).toHaveTextContent(
      props.question.text,
    );
    expect(screen.getByTestId("question-number")).toBeInTheDocument();
    expect(screen.getByTestId("question-number")).toHaveTextContent(
      `${props.sectionNumber}.${props.questionIdx}`,
    );
    expect(screen.getByTestId("question-angle-down")).toBeInTheDocument();
  });

  test("openedQuestions in context should update when clicking on question", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: false,
        },
      },
      setOpenedQuestions: vi.fn(),
    };
    const updatedOpenedQuestion = {
      [baseSectionsContextData.displayedResearchOutput.id]: {
        [props.question.id]: true,
      },
    };
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={contextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    expect(screen.getByTestId("question-collapse")).toBeInTheDocument();
    fireEvent.click(screen.getByTestId("question-collapse"));
    expect(contextData.setOpenedQuestions).toHaveBeenCalledWith(
      updatedOpenedQuestion,
    );
  });

  test("component should properly render when question is opened", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: true,
        },
      },
      setOpenedQuestions: vi.fn(),
    };
    await act(async () =>
      render(
        <Global>
          <FormsContext.Provider
            value={{ formSelectors: { my_classname: false }, formData: {} }}
          >
            <SectionsContext.Provider value={contextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </FormsContext.Provider>
        </Global>,
      ),
    );
    expect(screen.getByTestId("question-angle-up")).toBeInTheDocument();
    expect(screen.getByTestId("comment-icon")).toBeInTheDocument();
    // expect(screen.getByTestId("form-selector-icon")).not.toBeInTheDocument();
    // expect(screen.getByTestId("runs-icon")).not.toBeInTheDocument();
    expect(screen.queryByTestId("guidance-icon")).not.toBeInTheDocument();
  });

  test("component should properly render in readonly when question is opened", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: true,
        },
      },
      setOpenedQuestions: vi.fn(),
    };
    await act(async () =>
      render(
        <Global>
          <FormsContext.Provider
            value={{ formSelectors: { my_classname: false }, formData: {} }}
          >
            <SectionsContext.Provider value={contextData}>
              <Question {...{ ...props, readonly: true }} />
            </SectionsContext.Provider>
          </FormsContext.Provider>
        </Global>,
      ),
    );
    expect(screen.getByTestId("comment-icon")).toBeInTheDocument();
    expect(screen.getByTestId("readonly-question-badge")).toBeInTheDocument();
    expect(screen.getByTestId("readonly-question-badge")).toHaveTextContent(
      "Question not answered",
    );
  });

  test("component should check if question has guidances when question is opened", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: true,
        },
      },
      setOpenedQuestions: vi.fn(),
    };
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={contextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    await waitFor(() => {
      expect(guidances.hasQuestionGuidances).toHaveBeenCalledWith(
        props.question.id,
        baseSectionsContextData.displayedResearchOutput.id,
      );
    });
  });

  test("component should display guidance icon when question has guidance", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: true,
        },
      },
      setOpenedQuestions: vi.fn(),
    };
    guidances.hasQuestionGuidances.mockResolvedValue({
      data: { has_guidances: true },
    });
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={contextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    await waitFor(() => {
      expect(guidances.hasQuestionGuidances).toHaveBeenCalledWith(
        props.question.id,
        baseSectionsContextData.displayedResearchOutput.id,
      );
    });
    expect(screen.queryByTestId("guidance-icon")).toBeInTheDocument();
  });
  test("getNewForm should be called when question is opened and not answered", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: true,
        },
      },
      setOpenedQuestions: vi.fn(),
    };
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={contextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    expect(madmpFragment.getNewForm).toHaveBeenCalledWith(
      props.question.id,
      contextData.displayedResearchOutput.id,
    );
  });
  test("getFragment should be called when question is opened and answered", async () => {
    const contextData = {
      ...baseSectionsContextData,
      openedQuestions: {
        [baseSectionsContextData.displayedResearchOutput.id]: {
          [props.question.id]: true,
        },
      },
      displayedResearchOutput: {
        id: 1,
        answers: [{ question_id: 1, fragment_id: 1 }],
      },
      setOpenedQuestions: vi.fn(),
    };
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={contextData}>
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    expect(madmpFragment.getFragment).toHaveBeenCalledWith(
      contextData.displayedResearchOutput.answers[0].fragment_id,
    );
  });
});
