import { createContext, useMemo, useState } from "react";

/* It's getting the form from localStorage. */
// const formLocalState = JSON.parse(localStorage.getItem('formData'));
// const researchOutputsLocalState = JSON.parse(sessionStorage.getItem("researchOutputs"));
export const GlobalContext = createContext();

/**
 * It's a function that takes a prop called children and returns a GlobalContext.Provider
 * component that has a value prop that is an object with two
 * properties: form and setform.
 * @returns The GlobalContext.Provider is being returned.
 */
function Global({ children }) {
  const [locale, setLocale] = useState("fr_FR");
  const [dmpId, setDmpId] = useState(null);
  const [persons, setPersons] = useState([]);

  const [openedQuestions, setOpenedQuestions] = useState(null);
  const [userId, setUserId] = useState(-1);
  const [formSelectors, setFormSelector] = useState({});
  const [configuration, setConfiguration] = useState({});
  const [savedGuidances, setSavedGuidances] = useState([]);
  const [commentablePlan, setCommentablePlan] = useState(false);

  const setUrlParams = (data = {}) => {
    const currentParams = Object.fromEntries(
      new URLSearchParams(window.location.search),
    );
    const mergedParams = { ...currentParams, ...data };
    Object.keys(mergedParams).forEach((key) => {
      if (!mergedParams[key] || mergedParams[key] === "") {
        delete mergedParams[key];
      }
    });
    const newSearchParams = new URLSearchParams(mergedParams);
    window.history.replaceState(
      null,
      "",
      `${window.location.pathname}?${newSearchParams.toString()}`,
    );
  };

  const contextValue = useMemo(
    () => ({
      locale,
      setLocale,
      dmpId,
      setDmpId,
      persons,
      setPersons,
      openedQuestions,
      setOpenedQuestions,
      userId,
      setUserId,
      setUrlParams,
      formSelectors,
      setFormSelector,
      configuration,
      setConfiguration,
      savedGuidances,
      setSavedGuidances,
      commentablePlan,
      setCommentablePlan,
    }),
    [
      locale,
      dmpId,
      persons,
      openedQuestions,
      userId,
      formSelectors,
      configuration,
      savedGuidances,
      commentablePlan,
    ],
  );

  return (
    <GlobalContext.Provider value={contextValue}>
      {children}
    </GlobalContext.Provider>
  );
}

export default Global;
