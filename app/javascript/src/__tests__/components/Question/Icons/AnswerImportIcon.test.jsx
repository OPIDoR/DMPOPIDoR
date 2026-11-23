import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import AnswerImportIcon from "../../../../components/Question/Icons/AnswerImportIcon";

const props = {
  isQuestionOpened: true,
  fillColor: "#ffc0cb",
  setModalOpened: vi.fn(),
};

describe("AnswerImportIcon component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component renders properly when question is opened", () => {
    render(<AnswerImportIcon {...props} />);
    expect(screen.getByTestId("answer-import-icon")).toBeInTheDocument();
    expect(screen.getByTestId("answer-import-icon")).toHaveStyle({
      color: "#ffc0cb",
    });
  });
  test("component rendering nothing when question is closed", () => {
    render(<AnswerImportIcon {...props} isQuestionOpened={false} />);
    expect(screen.queryByTestId("answer-import-icon")).not.toBeInTheDocument();
  });
  test("tooltip is rendered when hovering over the icon", async () => {
    const { findByText } = render(<AnswerImportIcon {...props} />);
    const icon = screen.getByTestId("answer-import-icon");
    fireEvent.mouseOver(icon);

    const tooltip = await findByText("importAnswer");
    await waitFor(() => {
      expect(tooltip).toBeInTheDocument();
    });
  });
  test("clicking the icon calls setModalOpened with correct arguments", () => {
    render(<AnswerImportIcon {...props} />);
    const icon = screen.getByTestId("answer-import-icon");
    fireEvent.click(icon);
    expect(props.setModalOpened).toHaveBeenCalledWith(
      expect.anything(),
      "import",
      true,
    );
  });
});
