import { render, screen } from "@testing-library/react";
import OrgWithGuidanceGroups from "../../../components/GuidanceSelection/OrgWithGuidanceGroups";

const props = {
  org: {
    id: 1,
    name: "Organization 1",
    guidance_groups: [
      {
        id: 1,
        name: "Guidance Group 1",
        description: "Description for Guidance Group 1",
      },
      {
        id: 2,
        name: "Guidance Group 2",
        description: "Description for Guidance Group 2",
      },
    ],
  },
  isLimitReached: false,
  shouldGuidanceGroupDisplay: vi.fn().mockResolvedValue(true),
  onSelect: vi.fn(),
};
describe("OrgWithGuidanceGroups component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  test("component rendering correctly", async () => {
    render(<OrgWithGuidanceGroups {...props} />);
    expect(
      screen.getByTestId(`org-section-${props.org.id}`),
    ).toBeInTheDocument();
    expect(screen.getByTestId(`org-${props.org.id}-label`)).toBeInTheDocument();
    expect(screen.getByTestId(`org-${props.org.id}-label`)).toHaveTextContent(
      props.org.name,
    );
  });
  test("onSelect function should be called when label is clicked", async () => {
    render(<OrgWithGuidanceGroups {...props} />);
    const label = screen.getByTestId(`org-${props.org.id}-label`);
    label.click();
    expect(props.onSelect).toHaveBeenCalledWith(
      props.org.guidance_groups.map((group) => group.id),
    );
  });
  test("onSelect function should not be called when isLimitReached is true", async () => {
    render(<OrgWithGuidanceGroups {...props} isLimitReached={true} />);
    const label = screen.getByTestId(`org-${props.org.id}-label`);
    label.click();
    expect(props.onSelect).not.toHaveBeenCalled();
  });
  test("shouldGuidanceGroupDisplay function should be called for each guidance group", async () => {
    render(<OrgWithGuidanceGroups {...props} />);
    expect(props.shouldGuidanceGroupDisplay).toHaveBeenCalledTimes(
      props.org.guidance_groups.length,
    );
  });
});
