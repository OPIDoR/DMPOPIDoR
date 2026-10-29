import { render, screen } from "@testing-library/react";
import RunsModal from "../../../components/Question/RunsModal";
import Global, {
  GlobalContext,
} from "../../../components/context/GlobalContext";
import Forms, { FormsContext } from "../../../components/context/FormsContext";
import { test, vi } from "vitest";
import userEvent from "@testing-library/user-event";

const { madmpFragment } = vi.hoisted(() => ({
  madmpFragment: {
    runScript: vi.fn().mockResolvedValue({
      data: {
        fragment: { id: 1 },
        needs_reload: true,
        template_name: "My Template",
        clients: [{ id: 1, name: "My client" }],
      },
    }),
  },
}));

vi.mock("../../../services/index.js", () => ({
  madmpFragment,
}));

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
  shown: true,
  hide: vi.fn(),
  setAnswer: vi.fn(),
  scriptsData: {
    scripts: [
      {
        name: "My Script",
        "label@en_GB": "My English script",
        "tooltip@en_GB": "My English script to be executed",
      },
    ],
  },
  fragmentId: 1,
};

describe("RunsModal component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  test("component renders properly", async () => {
    render(
      <Global initialLocale="en_GB">
        <Forms>
          <RunsModal {...props} />
        </Forms>
      </Global>,
    );
    expect(screen.getByTestId("inner-modal-header")).toBeInTheDocument();
    expect(
      screen.getByTestId("inner-modal-header-actions"),
    ).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toHaveTextContent("tools");

    expect(screen.getByTestId("script-0")).toBeInTheDocument();
    expect(screen.getByTestId("script-0")).toHaveTextContent(
      "My English script",
    );

    expect(screen.getByTestId("script-tooltip-0")).toBeInTheDocument();
    expect(screen.getByTestId("script-tooltip-0")).toHaveTextContent(
      "My English script to be executed",
    );
  });
  test("component correctly execute script call when clicking on button", async () => {
    const propsWithSecondScript = {
      ...props,
      scriptsData: {
        scripts: [
          {
            name: "My Script",
            "label@en_GB": "My script",
            "tooltip@en_GB": "My script to be executed",
          },
          {
            name: "My other Script",
            "label@en_GB": "My other script",
            "tooltip@en_GB": "My other script not to be executed",
          },
        ],
      },
    };
    const globalContextData = { locale: "en_GB", setClients: vi.fn() };
    const formContextData = { setFormData: vi.fn() };
    render(
      <GlobalContext.Provider value={globalContextData}>
        <FormsContext.Provider value={formContextData}>
          <RunsModal {...propsWithSecondScript} />
        </FormsContext.Provider>
      </GlobalContext.Provider>,
    );

    const user = userEvent.setup();
    const runDiv = screen.getByTestId("script-0");
    expect(runDiv).toBeInTheDocument();
    expect(screen.getByTestId("script-1")).toBeInTheDocument();
    expect(screen.getByTestId("script-1")).toHaveTextContent("My other script");

    expect(screen.getByTestId("script-tooltip-1")).toBeInTheDocument();
    expect(screen.getByTestId("script-tooltip-1")).toHaveTextContent(
      "My other script not to be executed",
    );

    const runButton = runDiv.querySelector("button");
    expect(runButton).toBeInTheDocument();
    await user.click(runButton);
    expect(madmpFragment.runScript).toHaveBeenCalledWith(1, "My Script");
    expect(madmpFragment.runScript).not.toHaveBeenCalledWith(
      1,
      "My other Script",
    );
    expect(globalContextData.setClients).toHaveBeenCalledWith([
      { id: 1, name: "My client" },
    ]);
    expect(formContextData.setFormData).toHaveBeenCalledWith({
      1: { id: 1, template_name: "My Template" },
    });
  });
  test("component should not reload form when data doesn't tell it to", async () => {
    madmpFragment.runScript.mockResolvedValue({
      data: {
        needs_reload: false,
      },
    });
    const formContextData = { setFormData: vi.fn() };
    render(
      <Global initialLocale="en_GB">
        <FormsContext.Provider value={formContextData}>
          <RunsModal {...props} />
        </FormsContext.Provider>
      </Global>,
    );

    const user = userEvent.setup();
    const runDiv = screen.getByTestId("script-0");
    expect(runDiv).toBeInTheDocument();

    const runButton = runDiv.querySelector("button");
    expect(runButton).toBeInTheDocument();
    await user.click(runButton);
    expect(madmpFragment.runScript).toHaveBeenCalledWith(1, "My Script");
    expect(formContextData.setFormData).not.toHaveBeenCalledWith();
  });
});
