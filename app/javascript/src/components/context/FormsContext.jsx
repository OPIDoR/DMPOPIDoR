import { createContext, useMemo, useReducer, useState } from "react";

export const FormsContext = createContext();
const reducer = (formData, incomingFormData) => {
  if (incomingFormData === null) {
    return {};
  }
  return { ...formData, ...incomingFormData };
};

function Forms({ children }) {
  const [formData, setFormData] = useReducer(reducer, {});
  const [loadedRegistries, setLoadedRegistries] = useState({});
  const [loadedTemplates, setLoadedTemplates] = useState({});
  const [formSelectors, setFormSelector] = useState({});
  const [persons, setPersons] = useState([]);

  const contextValue = useMemo(
    () => ({
      formData,
      setFormData,
      loadedRegistries,
      setLoadedRegistries,
      loadedTemplates,
      setLoadedTemplates,
      formSelectors,
      setFormSelector,
      persons,
      setPersons,
    }),
    [formData, loadedRegistries, loadedTemplates, formSelectors, persons],
  );

  return (
    <FormsContext.Provider value={contextValue}>
      {children}
    </FormsContext.Provider>
  );
}

export default Forms;
