import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchResearchOutputsData(
  planId,
  dataType = null,
  className = null,
  topic = null,
) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!planId) return;

    researchOutput
      .getResearchOutputs(planId, className, dataType, topic)
      .then(({ data }) => {
        setData(data.research_outputs);
        setLoading(false);
      });
  }, [planId, dataType, className, topic]);

  return { data, loading };
}
export default useFetchResearchOutputsData;
