import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchPlansData(
  dataType = null,
  className = null,
  topic = null,
  shouldFetch = true,
) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!shouldFetch) return;

    researchOutput.getPlans(className, dataType, topic).then(({ data }) => {
      setData(data.plans);
      setLoading(false);
    });
  }, [shouldFetch, dataType, className, topic]);

  return { data, loading };
}
export default useFetchPlansData;
