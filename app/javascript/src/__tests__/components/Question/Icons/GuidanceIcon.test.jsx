import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import GuidanceIcon from "../../../../components/Question/Icons/GuidanceIcon";

const props = {
  isQuestionOpened: true,
  fillColor: "#ffc0cb",
  setModalOpened: vi.fn(),
};

describe("GuidanceIcon component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component renders properly when question is opened", () => {
    render(<GuidanceIcon {...props} />);
    expect(screen.getByTestId("guidance-icon")).toBeInTheDocument();
    expect(screen.getByTestId("guidance-icon")).toHaveStyle({
      color: "#ffc0cb",
    });
  });
  test("component rendering nothing when question is closed", () => {
    render(<GuidanceIcon {...props} isQuestionOpened={false} />);
    expect(screen.queryByTestId("guidance-icon")).not.toBeInTheDocument();
  });
  test("tooltip is rendered when hovering over the icon", async () => {
    const { findByText } = render(<GuidanceIcon {...props} />);
    const icon = screen.getByTestId("guidance-icon");
    fireEvent.mouseOver(icon);

    const tooltip = await findByText("guidance");
    await waitFor(() => {
      expect(tooltip).toBeInTheDocument();
    });
  });
  test("clicking the icon calls setModalOpened with correct arguments", () => {
    render(<GuidanceIcon {...props} />);
    const icon = screen.getByTestId("guidance-icon");
    fireEvent.click(icon);
    expect(props.setModalOpened).toHaveBeenCalledWith(
      expect.anything(),
      "guidance",
      true,
    );
  });
});
