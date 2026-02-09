import { useContext, useEffect, useRef } from "react";
import { GlobalContext } from "../components/context/Global";
import { service } from "../services";

function useLoadRegistry(registryName) {
  const { loadedRegistries, setLoadedRegistries } = useContext(GlobalContext);
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

    service
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
