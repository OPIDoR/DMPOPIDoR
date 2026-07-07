import { useContext, useEffect, useRef } from "react";
import { FormsContext } from "../components/context/FormsContext";
import { madmpFragment } from "../services";

function useLoadTemplate(templateName) {
  const { loadedTemplates, setLoadedTemplates } = useContext(FormsContext);
  const loadingRef = useRef(new Set());

  useEffect(() => {
    if (
      !templateName ||
      loadedTemplates[templateName] ||
      loadingRef.current.has(templateName)
    ) {
      return;
    }

    loadingRef.current.add(templateName);

    madmpFragment
      .getSchemaByName(templateName)
      .then((res) => {
        setLoadedTemplates((prev) =>
          prev[templateName] ? prev : { ...prev, [templateName]: res.data },
        );
      })
      .finally(() => {
        loadingRef.current.delete(templateName);
      });
  }, [templateName, loadedTemplates]);

  return loadedTemplates[templateName] || {};
}

export default useLoadTemplate;
