import { useEffect, useState } from "react";
import { researchOutput } from "../services";

function useFetchPlansData() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    researchOutput.getPlans().then(({ data }) => {
      setData(data);
      setLoading(false);
    });
  }, []);

  return { data, loading };
}
export default useFetchPlansData;
