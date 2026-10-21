import Global from "../../../components/context/GlobalContext";
import CommentModal from "../../../components/Question/CommentModal";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

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

vi.mock("../../../components/Comments/CommentsList.jsx", () => ({
  default: ({ setCommentsNumber }) => (
    <button onClick={() => setCommentsNumber(5)}>setCommentsNumber</button>
  ),
}));

const props = {
  shown: true,
  hide: vi.fn(),
  setAnswer: vi.fn(),
  answerId: 1,
  researchOutputId: 1,
  planId: 1,
  questionId: 1,
  commentable: true,
};
describe("CommentModal component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  test("component renders properly", async () => {
    render(
      <Global>
        <CommentModal {...props} />
      </Global>,
    );
    expect(screen.getByTestId("inner-modal-header")).toBeInTheDocument();
    expect(
      screen.getByTestId("inner-modal-header-actions"),
    ).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toHaveTextContent(
      "comments (0)",
    );
  });
  test("component should update comment number when state changes", async () => {
    render(
      <Global>
        <CommentModal {...props} />
      </Global>,
    );
    const user = userEvent.setup();
    expect(screen.getByTestId("inner-modal-title")).toBeInTheDocument();
    expect(screen.getByTestId("inner-modal-title")).toHaveTextContent(
      "comments (0)",
    );
    await user.click(
      screen.getByRole("button", { name: /setCommentsNumber/i }),
    );
    expect(screen.getByTestId("inner-modal-title")).toHaveTextContent(
      "comments (5)",
    );
  });
});
