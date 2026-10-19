import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import FormSelectorIcon from "../../../../components/Question/Icons/FormSelectorIcon";

const props = {
  isQuestionOpened: true,
  fillColor: "#ffc0cb",
  setModalOpened: vi.fn(),
};

describe("FormSelectorIcon component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component renders properly when question is opened", () => {
    render(<FormSelectorIcon {...props} />);
    expect(screen.getByTestId("form-selector-icon")).toBeInTheDocument();
    expect(screen.getByTestId("form-selector-icon")).toHaveStyle({
      color: "#ffc0cb",
    });
  });
  test("component rendering nothing when question is closed", () => {
    render(<FormSelectorIcon {...props} isQuestionOpened={false} />);
    expect(screen.queryByTestId("form-selector-icon")).not.toBeInTheDocument();
  });
  test("tooltip is rendered when hovering over the icon", async () => {
    const { findByText } = render(<FormSelectorIcon {...props} />);
    const icon = screen.getByTestId("form-selector-icon");
    fireEvent.mouseOver(icon);

    const tooltip = await findByText("listOfCustomizedForms");
    await waitFor(() => {
      expect(tooltip).toBeInTheDocument();
    });
  });
  test("clicking the icon calls setModalOpened with correct arguments", () => {
    render(<FormSelectorIcon {...props} />);
    const icon = screen.getByTestId("form-selector-icon");
    fireEvent.click(icon);
    expect(props.setModalOpened).toHaveBeenCalledWith(
      expect.anything(),
      "formSelector",
      true,
    );
  });
});
