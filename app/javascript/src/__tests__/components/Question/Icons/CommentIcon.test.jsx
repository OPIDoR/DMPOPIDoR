import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import CommentIcon from "../../../../components/Question/Icons/CommentIcon";

const props = {
  isQuestionOpened: true,
  fillColor: "#ffc0cb",
  setModalOpened: vi.fn(),
  newCommentCount: 0,
};

describe("CommentIcon component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component renders properly when question is opened and comment count is zero", () => {
    render(<CommentIcon {...props} />);
    expect(screen.getByTestId("comment-icon")).toBeInTheDocument();
    expect(screen.getByTestId("comment-icon")).toHaveStyle({
      color: "#ffc0cb",
    });
  });
  test("component rendering nothing when question is closed", () => {
    render(<CommentIcon {...props} isQuestionOpened={false} />);
    expect(screen.queryByTestId("comment-icon")).not.toBeInTheDocument();
  });
  test("component renders properly when question is closed but comment count is superior to zero", () => {
    render(
      <CommentIcon {...props} newCommentCount={5} isQuestionOpened={false} />,
    );
    expect(screen.getByTestId("comment-icon")).toBeInTheDocument();
    expect(screen.getByTestId("comment-icon-count")).toBeInTheDocument();
    expect(screen.getByTestId("comment-icon-count")).toHaveTextContent("5");
  });
  test("tooltip is rendered when hovering over the icon", async () => {
    const { findByText } = render(<CommentIcon {...props} />);
    const icon = screen.getByTestId("comment-icon");
    fireEvent.mouseOver(icon);

    const tooltip = await findByText("comments");
    await waitFor(() => {
      expect(tooltip).toBeInTheDocument();
    });
  });
  test("clicking the icon calls setModalOpened with correct arguments", () => {
    render(<CommentIcon {...props} />);
    const icon = screen.getByTestId("comment-icon");
    fireEvent.click(icon);
    expect(props.setModalOpened).toHaveBeenCalledWith(
      expect.anything(),
      "comment",
      true,
    );
  });
});
