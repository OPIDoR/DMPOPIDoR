import { act, render, screen } from "@testing-library/react";

import Global from "../../../components/context/GlobalContext";
import { SectionsContext } from "../../../components/context/SectionsContext";
import SavedGuidances from "../../../components/GuidanceSelection/SavedGuidances";

const baseSectionsContextData = {
  savedGuidances: [{ id: 1, name: "Guidance 1", orgName: "Org 1" }],
};

describe("SavedGuidances component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  test("component rendering with saved guidances", async () => {
    await act(async () =>
      render(
        <Global>
          <SectionsContext.Provider value={baseSectionsContextData}>
            <SavedGuidances />
          </SectionsContext.Provider>
        </Global>,
      ),
    );
    expect(
      screen.getByText("followingGuidancesApplyToThisResearchOutput"),
    ).toBeInTheDocument();
    expect(
      screen.getByText("Guidance 1 (providedBy Org 1)"),
    ).toBeInTheDocument();
    const link = screen.getByRole("link");
    expect(link).toBeInTheDocument();
    expect(link).toHaveAttribute("href", "/guidance_group_export/1.pdf");
  });

  test("component rendering without saved guidances", async () => {
    await act(async () =>
      render(
        <Global>
          <SectionsContext.Provider value={{ savedGuidances: [] }}>
            <SavedGuidances />
          </SectionsContext.Provider>
        </Global>,
      ),
    );
    expect(screen.getByText("noGuidanceSelected")).toBeInTheDocument();
  });
});
