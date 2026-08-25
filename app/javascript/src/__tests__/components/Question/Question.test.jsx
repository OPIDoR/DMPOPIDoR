import { act, render } from "@testing-library/react";
import Question from "../../../components/Question/Question";
import Global from "../../../components/context/GlobalContext";
import Forms from "../../../components/context/FormsContext";
import { SectionsContext } from "../../../components/context/SectionsContext";

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

describe("Question component", () => {
  test("component rendering", async () => {
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider
              value={{ displayedResearchOutput: { id: 1, answers: [] } }}
            >
              <Question {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    // expect(screen.getByTestId("question-text")).toBeInTheDocument();
    // expect(screen.getByTestId("question-number")).toBeInTheDocument();
  });
});
