import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchPlansData(
  dataType = null,
  className = null,
  shown = true,
  topic = null,
) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!shouldFetch) return;

    researchOutput.getPlans(className, dataType, topic).then(({ data }) => {
      setData(data.plans);
      setLoading(false);
    });
  }, [shown, dataType, className, topic]);

  return { data, loading };
}
export default useFetchPlansData;
