import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchResearchOutputsData(
  planId,
  dataType = null,
  className = null,
) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!planId) return;

    researchOutput
      .getResearchOutputs(planId, className, dataType)
      .then(({ data }) => {
        setData(data.research_outputs);
        setLoading(false);
      });
  }, [planId, dataType, className]);

  return { data, loading };
}
export default useFetchResearchOutputsData;
