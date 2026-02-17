import { useContext, useEffect, useState } from "react";

import { ResearchOutputsContext } from "../context/ResearchOutputsContext.jsx";
import { researchOutput } from "../../services";
import { setUrlParams } from "../../utils/utils.js";

function ResearchOutputsSidebarItem({ item, setLoading, children }) {
  const { setDisplayedResearchOutput } = useContext(ResearchOutputsContext);
  const [selectedResearchOutputId, setSelectedResearchOutputId] =
    useState(null);

  /**
   * When the user clicks on a tab, the function sets the active index to the index of the tab that was clicked, and sets the research id to the id of the
   * tab that was clicked.
   */
  const handleShowResearchOutputClick = (e, selectedResearchOutput) => {
    e.preventDefault();
    setSelectedResearchOutputId(selectedResearchOutput.id);
    setUrlParams({ research_output: selectedResearchOutput.id });
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (selectedResearchOutputId) {
      setLoading(true);
      researchOutput
        .get(selectedResearchOutputId)
        .then((res) => {
          setDisplayedResearchOutput(res.data);
        })
        .finally(() => setLoading(false));
    }
  }, [selectedResearchOutputId]);

  /**
   * RENDERING
   */

  return (
    <div onClick={(e) => handleShowResearchOutputClick(e, item, item.id)}>
      {children}
    </div>
  );
}

export default ResearchOutputsSidebarItem;
