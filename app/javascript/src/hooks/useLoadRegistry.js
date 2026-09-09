import { useContext, useEffect, useRef } from "react";
import { FormsContext } from "../components/context/FormsContext";
import { madmpFragment } from "../services";

function useLoadRegistry(registryName) {
  const { loadedRegistries, setLoadedRegistries } = useContext(FormsContext);
  const loadingRef = useRef(new Set());
  useEffect(() => {
    if (
      !registryName ||
      loadedRegistries[registryName] ||
      loadingRef.current.has(registryName)
    ) {
      return;
    }

    loadingRef.current.add(registryName);

    madmpFragment
      .getRegistryByName(registryName)
      .then((res) => {
        setLoadedRegistries((prev) =>
          prev[registryName] ? prev : { ...prev, [registryName]: res.data },
        );
      })
      .finally(() => {
        loadingRef.current.delete(registryName);
      });
  }, [registryName, loadedRegistries]);

  return loadedRegistries[registryName] || [];
}

export default useLoadRegistry;
