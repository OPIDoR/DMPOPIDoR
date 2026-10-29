import { act, render, screen } from "@testing-library/react";
import GuidanceModal from "../../../components/Question/GuidanceModal";

const { guidances } = vi.hoisted(() => ({
  guidances: {
    getGuidances: vi.fn().mockResolvedValue({
      data: {
        guidances: [
          {
            id: 1,
            name: "My first Org",
            groups: [],
          },
          {
            id: 2,
            name: "My second Org with a long name",
            groups: [],
          },
        ],
      },
    }),
  },
}));
vi.mock("../../../services/index.js", () => ({
  guidances,
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
  questionId: 1,
  researchOutputId: 1,
};
describe("GuidanceModal component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  test("component renders properly", async () => {
    await act(() => render(<GuidanceModal {...props} />));
    expect(screen.getByTestId("inner-modal-header")).toBeInTheDocument();
    expect(
      screen.getByTestId("inner-modal-header-actions"),
    ).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toHaveTextContent(
      "guidance",
    );

    expect(guidances.getGuidances).toHaveBeenCalledWith(
      props.researchOutputId,
      props.questionId,
    );
    expect(screen.getByTestId("guidance-tab-0")).toBeInTheDocument();
    expect(screen.getByTestId("guidance-tab-1")).toBeInTheDocument();
    expect(screen.getByTestId("guidance-tab-title-0")).toBeInTheDocument();
    expect(screen.getByTestId("guidance-tab-title-1")).toBeInTheDocument();
    expect(screen.getByTestId("guidance-tab-title-0")).toHaveTextContent(
      "My first Org",
    );
    expect(screen.getByTestId("guidance-tab-title-1")).toHaveTextContent(
      `${"My second Org with a long name".substring(0, 15)}...`,
    );

    expect(screen.getByTestId("guidances-content")).toBeInTheDocument();
  });
});
