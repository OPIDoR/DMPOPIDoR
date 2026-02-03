import React, { useContext, useEffect, useState } from 'react';

import { GlobalContext } from '../context/Global';
import { researchOutput } from '../../services';

function ResearchOutputsSidebarItem({ item, setLoading, children }) {
  const {
    setDisplayedResearchOutput,
    setUrlParams,
  } = useContext(GlobalContext);
  const [selectedResearchOutputId, setSelectedResearchOutputId] = useState(null);

  useEffect(() => {
    if (selectedResearchOutputId) {
      setLoading(true);
      researchOutput.get(selectedResearchOutputId).then((res) => {
        setDisplayedResearchOutput(res.data);
      }).finally(() => setLoading(false));
    }
  }, [selectedResearchOutputId]);

  /**
   * When the user clicks on a tab, the function sets the active index to the index of the tab that was clicked, and sets the research id to the id of the
   * tab that was clicked.
   */
  const handleShowResearchOutputClick = (e, selectedResearchOutput) => {
    e.preventDefault();
    setSelectedResearchOutputId(selectedResearchOutput.id);
    setUrlParams({ research_output: selectedResearchOutput.id });
  };

  return (
    <div onClick={(e) => handleShowResearchOutputClick(e, item, item.id)}>
      {children}
    </div>
  );
}

export default ResearchOutputsSidebarItem;
