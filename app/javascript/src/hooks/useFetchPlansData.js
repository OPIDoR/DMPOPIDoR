import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchPlansData(
  dataType = null,
  className = null,
  shouldFetch = true,
) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!shouldFetch) return;

    researchOutput.getPlans().then(({ data }) => {
      /* filtering plans and research outputs based on dataType */
      const filteredPlans = filterWithClassName(
        filterWithDataType(data.plans, dataType),
        className,
      );
      setData(filteredPlans);
      setLoading(false);
    });
  }, [shouldFetch]);

  const filterWithDataType = (plans, dataType) => {
    if (!dataType) return plans;
    return plans
      .filter((p) =>
        p.research_outputs.some((pr) => pr.output_type == dataType),
      )
      .map((p) => ({
        ...p,
        research_outputs: p.research_outputs.filter(
          (pr) => pr.output_type == dataType,
        ),
      }));
  };

  const filterWithClassName = (plans, className) => {
    if (!className) return plans;

    return plans
      .filter((p) =>
        p.research_outputs.some((pr) =>
          pr.answers.some((a) => a.classname == className),
        ),
      )
      .map((p) => ({
        ...p,
        research_outputs: p.research_outputs.filter((pr) =>
          pr.answers.some((a) => a.classname == className),
        ),
      }));
  };

  return { data, loading };
}
export default useFetchPlansData;
