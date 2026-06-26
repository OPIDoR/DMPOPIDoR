import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchPlansData(dataType = null) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    researchOutput.getPlans().then(({ data }) => {
      /* filtering plans and research outputs based on dataType */
      const filteredPlans = dataType
        ? data.plans
            .filter((p) =>
              p.research_outputs.some((pr) => pr.output_type == dataType),
            )
            .map((p) => ({
              ...p,
              research_outputs: p.research_outputs.filter(
                (pr) => pr.output_type == dataType,
              ),
            }))
        : data.plans;
      setData(filteredPlans);
      setLoading(false);
    });
  }, []);

  return { data, loading };
}
export default useFetchPlansData;
