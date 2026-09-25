import { act, render, screen } from "@testing-library/react";
import Global from "../../../components/context/GlobalContext";
import Forms from "../../../components/context/FormsContext";
import { SectionsContext } from "../../../components/context/SectionsContext";
import DynamicForm from "../../../components/Forms/DynamicForm";
import { vi } from "vitest";

const { madmpFragment } = vi.hoisted(() => ({
  madmpFragment: {
    getNewForm: vi.fn().mockResolvedValue({
      data: { template: { name: "MyTemplate", schema: { properties: {} } } },
    }),
    getFragment: vi.fn().mockResolvedValue({
      data: {
        answer_id: 1,
        template: {
          id: 1,
          name: "MyTemplate",
          schema: { properties: {} },
        },
        fragment: { id: 1, schema_id: 1, template_name: "MyTemplate" },
      },
    }),
    getSchema: vi.fn().mockResolvedValue({
      data: { name: "MyTemplate", schema: { properties: {} } },
    }),
  },
}));
vi.mock("../../../services/index.js", () => ({ madmpFragment }));

vi.mock("react-i18next", () => ({
  // this mock makes sure any components using the translate hook can use it without a warning being shown
  useTranslation: () => ({
    t: (str) => str,
    i18n: {
      changeLanguage: () => new Promise(() => {}),
    },
  }),
  initReactI18next: {
    type: "3rdParty",
    init: () => {},
  },
}));

const props = {
  fragmentId: null,
  className: "my_classname",
  setScriptsData: null,
  questionId: 1,
  madmpSchemaId: 1,
  setAnswer: vi.fn(),
  formSelector: {},
  readonly: false,
};

const baseSectionsContextData = {
  displayedResearchOutput: { id: 1, answers: [] },
};
describe("DynamicForm component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component render when fragmentId is null and template is not in context", async () => {
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={baseSectionsContextData}>
              <DynamicForm {...props} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    expect(madmpFragment.getNewForm).toHaveBeenCalledWith(
      props.questionId,
      baseSectionsContextData.displayedResearchOutput.id,
    );
    expect(screen.queryByTestId("dynamic-form-tag")).toBeInTheDocument();
  });
  test("component render when fragmentId is present", async () => {
    const propsWithFragmentId = { ...props, fragmentId: 1 };
    await act(async () =>
      render(
        <Global>
          <Forms>
            <SectionsContext.Provider value={baseSectionsContextData}>
              <DynamicForm {...propsWithFragmentId} />
            </SectionsContext.Provider>
          </Forms>
        </Global>,
      ),
    );
    expect(madmpFragment.getFragment).toHaveBeenCalledWith(
      propsWithFragmentId.fragmentId,
    );

    expect(screen.queryByTestId("dynamic-form-tag")).toBeInTheDocument();
  });
});
