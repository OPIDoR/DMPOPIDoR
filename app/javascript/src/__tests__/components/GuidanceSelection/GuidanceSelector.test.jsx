import { act, render, screen, waitFor } from "@testing-library/react";
import { SectionsContext } from "../../../components/context/SectionsContext";
import GuidanceSelector from "../../../components/GuidanceSelection/GuidanceSelector";

const { guidances } = vi.hoisted(() => ({
  guidances: {
    getPlanGuidanceGroups: vi.fn(),
    getResearchOutputGuidanceGroups: vi.fn(),
  },
}));
vi.mock("../../../services/index.js", () => ({ guidances }));

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

vi.mock("../../../components/GuidanceChoice/GuidanceGroupItem.jsx", () => ({
  default: ({ guidance_group_id, onSelect }) => (
    <button onClick={() => onSelect(guidance_group_id)}>
      onSelect GuidanceGroupItem
    </button>
  ),
}));
vi.mock("../../../components/GuidanceChoice/OrgWithGuidanceGroups.jsx", () => ({
  default: ({ guidance_group_id, onSelect }) => (
    <button onClick={() => onSelect(guidance_group_id)}>
      onSelect OrgWithGuidanceGroups
    </button>
  ),
}));
const props = {
  planId: 1,
  researchOutputId: 1,
  context: "research_output",
};

const baseSectionsContextData = {
  savedGuidances: [{ id: 1, name: "Guidance 1", orgName: "Org 1" }],
};

describe("GuidanceSelector component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component rendering correctly without data", async () => {
    guidances.getResearchOutputGuidanceGroups.mockResolvedValue({
      data: [],
    });
    await act(async () =>
      render(
        <SectionsContext.Provider value={baseSectionsContextData}>
          <GuidanceSelector {...props} />
        </SectionsContext.Provider>,
      ),
    );
    expect(
      screen.getByTestId("guidance-selector-no-guidances"),
    ).toBeInTheDocument();
    expect(
      screen.getByTestId("guidance-selector-no-guidances"),
    ).toHaveTextContent("noGuidancesAvailable");
    expect(guidances.getResearchOutputGuidanceGroups).toHaveBeenCalledWith(
      props.researchOutputId,
    );
  });
  test("component rendering correctly with data", async () => {
    guidances.getResearchOutputGuidanceGroups.mockResolvedValue({
      data: [
        {
          id: 1,
          name: "Org 1",
          important: true,
          guidance_groups: [{ id: 1, name: "Guidance 1" }],
        },
      ],
    });
    await act(async () =>
      render(
        <SectionsContext.Provider value={baseSectionsContextData}>
          <GuidanceSelector {...props} />
        </SectionsContext.Provider>,
      ),
    );
    expect(guidances.getResearchOutputGuidanceGroups).toHaveBeenCalledWith(
      props.researchOutputId,
    );
    waitFor(() => {
      expect(
        screen.getByTestId("accordion-guidance-choice"),
      ).toBeInTheDocument();
      expect(
        screen.getByTestId("guidance-choice-collapse-text"),
      ).toBeInTheDocument();
      expect(
        screen.getByTestId("guidance-choice-collapse-text"),
      ).toHaveTextContent("selectGuidanceOutput");
      expect(
        screen.getByTestId("guidance-choice-collapse-content"),
      ).toBeInTheDocument();
      expect(
        screen.getByTestId("guidance-choice-collapse-content"),
      ).toHaveTextContent("guidanceListInfo");
    });
  });
  test("component should call getPlanGuidanceGroups in plan context", async () => {
    guidances.getPlanGuidanceGroups.mockResolvedValue({
      data: [],
    });
    await act(async () =>
      render(
        <SectionsContext.Provider value={baseSectionsContextData}>
          <GuidanceSelector {...{ ...props, context: "plan" }} />
        </SectionsContext.Provider>,
      ),
    );
    expect(guidances.getPlanGuidanceGroups).toHaveBeenCalledWith(props.planId);
  });
});
