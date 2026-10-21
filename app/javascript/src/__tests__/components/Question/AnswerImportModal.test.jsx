import { act, render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

import AnswerImportModal from "../../../components/Question/AnswerImportModal";
import Forms from "../../../components/context/FormsContext";
import { SectionsContext } from "../../../components/context/SectionsContext";
import { vi } from "vitest";

const { researchOutput } = vi.hoisted(() => ({
  researchOutput: {
    getPlans: vi.fn().mockResolvedValue({
      data: { plans: [] },
    }),
    getResearchOutputs: vi.fn().mockResolvedValue({
      data: { research_outputs: [] },
    }),
  },
}));
const { madmpFragment } = vi.hoisted(() => ({
  madmpFragment: {
    getFragmentFromParameters: vi.fn().mockResolvedValue({
      data: { fragment_id: 1, template_name: "My Template" },
    }),
    importFragment: vi.fn().mockResolvedValue({
      data: { fragment: { id: 1 }, template: { name: "My Template" } },
    }),
  },
}));

vi.mock("../../../services/index.js", () => ({
  madmpFragment,
  researchOutput,
}));

vi.mock("react-i18next", () => ({
  // this mock makes sure any components using the translate hook can use it without a warning being shown
  useTranslation: () => ({
    t: (str) => str,
    i18n: {
      changeLanguage: () => new Promise(() => {}),
    },
  }),
  Trans: ({ i18nKey, values }) => (
    <span data-testid="trans" data-values={JSON.stringify(values)}>
      {i18nKey}
    </span>
  ),
  initReactI18next: {
    type: "3rdParty",
    init: () => {},
  },
}));

const selectedResearchOutputMock = { id: 1, title: "My research output" };
vi.mock("../../../components/Shared/Import/ResearchOutputSelector.jsx", () => ({
  default: ({ setSelectedResearchOutput }) => (
    <button
      onClick={() => setSelectedResearchOutput(selectedResearchOutputMock)}
    >
      chooseResearchOutput
    </button>
  ),
}));

const props = {
  shown: true,
  hide: vi.fn(),
  questionId: 1,
  researchOutputId: 1,
  className: "my_classname",
  dataType: "my_datatype",
  topic: "my_topic",
  setAnswer: vi.fn(),
};

const baseSectionsContextData = {
  displayedResearchOutput: { id: 1, answers: [] },
};
describe("AnswerImportModal component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component renders properly", async () => {
    await act(async () =>
      render(
        <Forms>
          <SectionsContext.Provider value={baseSectionsContextData}>
            <AnswerImportModal {...props} />
          </SectionsContext.Provider>
        </Forms>,
      ),
    );
    expect(screen.getByTestId("inner-modal-header")).toBeInTheDocument();
    expect(
      screen.getByTestId("inner-modal-header-actions"),
    ).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toHaveTextContent(
      "importAnswer",
    );
    expect(screen.getByTestId("answer-import-button")).toBeInTheDocument();
    expect(researchOutput.getPlans).toHaveBeenCalledWith(
      props.className,
      props.dataType,
      props.topic,
    );
    expect(madmpFragment.getFragmentFromParameters).not.toHaveBeenCalled();
  });
  test("researchOutput.getPlans not to be called if modal is not shown", async () => {
    await act(async () =>
      render(
        <Forms>
          <SectionsContext.Provider value={baseSectionsContextData}>
            <AnswerImportModal {...props} shown={false} />
          </SectionsContext.Provider>
        </Forms>,
      ),
    );
    expect(researchOutput.getPlans).not.toHaveBeenCalled();
  });
  test("researchOutput.getFragmentFromParameters gets called when selecting a researchOutput", async () => {
    await act(async () =>
      render(
        <Forms>
          <SectionsContext.Provider value={baseSectionsContextData}>
            <AnswerImportModal {...props} />
          </SectionsContext.Provider>
        </Forms>,
      ),
    );
    const user = userEvent.setup();
    expect(researchOutput.getPlans).toHaveBeenCalled();
    await user.click(
      screen.getByRole("button", { name: /chooseResearchOutput/i }),
    );
    expect(madmpFragment.getFragmentFromParameters).toHaveBeenCalledWith(
      selectedResearchOutputMock.id,
      props.className,
    );
    expect(
      screen.getByTestId("answer-import-selected-import-message"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("answer-import-selected-import-message"),
    ).toHaveTextContent("answerImportFormMessage");
    expect(screen.getByTestId("trans")).toHaveAttribute(
      "data-values",
      JSON.stringify({ templateName: "My Template" }),
    );
  });
  test("madmpFragment.importFragment is called when clicking on import button", async () => {
    await act(async () =>
      render(
        <Forms>
          <SectionsContext.Provider value={baseSectionsContextData}>
            <AnswerImportModal {...props} />
          </SectionsContext.Provider>
        </Forms>,
      ),
    );
    const user = userEvent.setup();
    await user.click(
      screen.getByRole("button", { name: /chooseResearchOutput/i }),
    );
    await user.click(screen.getByTestId("answer-import-button"));
    expect(madmpFragment.importFragment).toHaveBeenCalledWith(
      props.researchOutputId,
      props.questionId,
      1,
    );
    expect(props.hide).toHaveBeenCalled();
  });
});
