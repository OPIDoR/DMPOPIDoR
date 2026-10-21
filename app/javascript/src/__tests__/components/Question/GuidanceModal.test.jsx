import { act, render, screen } from "@testing-library/react";
import GuidanceModal from "../../../components/Question/GuidanceModal";

const { guidances } = vi.hoisted(() => ({
  guidances: {
    getGuidances: vi.fn().mockResolvedValue({
      data: { guidances: [] },
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
  });
});
