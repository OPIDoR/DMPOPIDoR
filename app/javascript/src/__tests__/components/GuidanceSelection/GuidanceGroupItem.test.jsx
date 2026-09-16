import { render, screen } from "@testing-library/react";
import GuidanceGroupItem from "../../../components/GuidanceSelection/GuidanceGroupItem";

const props = {
  guidance_group_id: 1,
  guidance_group_name: "Guidance Group 1",
  guidance_group_description: "Description for Guidance Group 1",
  level: 1,
  isLimitReached: false,
  status: "saved",
  onSelect: vi.fn(),
};

describe("SavedGuidances component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component rendering correctly", async () => {
    render(<GuidanceGroupItem {...props} />);
    expect(
      screen.getByTestId(`guidance-group-${props.guidance_group_id}-section`),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId(`guidance-group-${props.guidance_group_id}-label`),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId(`guidance-group-${props.guidance_group_id}-label`),
    ).toHaveTextContent(props.guidance_group_name);
  });
  test("onSelect function should be called when label is clicked", async () => {
    render(<GuidanceGroupItem {...props} />);
    const label = screen.getByTestId(
      `guidance-group-${props.guidance_group_id}-label`,
    );
    label.click();
    expect(props.onSelect).toHaveBeenCalledWith(props.guidance_group_id);
  });
  test("onSelect function should not be called when isLimitReached is true", async () => {
    render(<GuidanceGroupItem {...props} isLimitReached={true} />);
    const label = screen.getByTestId(
      `guidance-group-${props.guidance_group_id}-label`,
    );
    label.click();
    expect(props.onSelect).not.toHaveBeenCalled();
  });
});
