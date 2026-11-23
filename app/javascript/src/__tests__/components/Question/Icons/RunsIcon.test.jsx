import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import RunsIcon from "../../../../components/Question/Icons/RunsIcon";

const props = {
  isQuestionOpened: true,
  fillColor: "#ffc0cb",
  setModalOpened: vi.fn(),
};

describe("RunsIcon component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component renders properly when question is opened", () => {
    render(<RunsIcon {...props} />);
    expect(screen.getByTestId("runs-icon")).toBeInTheDocument();
    expect(screen.getByTestId("runs-icon")).toHaveStyle({
      color: "#ffc0cb",
    });
  });
  test("component rendering nothing when question is closed", () => {
    render(<RunsIcon {...props} isQuestionOpened={false} />);
    expect(screen.queryByTestId("runs-icon")).not.toBeInTheDocument();
  });
  test("tooltip is rendered when hovering over the icon", async () => {
    const { findByText } = render(<RunsIcon {...props} />);
    const icon = screen.getByTestId("runs-icon");
    fireEvent.mouseOver(icon);

    const tooltip = await findByText("tools");
    await waitFor(() => {
      expect(tooltip).toBeInTheDocument();
    });
  });
  test("clicking the icon calls setModalOpened with correct arguments", () => {
    render(<RunsIcon {...props} />);
    const icon = screen.getByTestId("runs-icon");
    fireEvent.click(icon);
    expect(props.setModalOpened).toHaveBeenCalledWith(
      expect.anything(),
      "runs",
      true,
    );
  });
});
