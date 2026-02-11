import {
  createContext,
  useCallback,
  useMemo,
  useReducer,
  useState,
} from "react";

/**
 * If the incomingFormData is null, remove the formData from localStorage,
 * otherwise return the formData with the incomingFormData.
 * @param formData - the current state of the form
 * @param incomingFormData - This is the object that contains the form data.
 * @returns The reducer is returning a new object that is a combination of the
 * formData object and the incomingFormData object.
 */
const reducer = (formData, incomingFormData) => {
  if (incomingFormData === null) {
    // localStorage.removeItem('formData');
    // sessionStorage.removeItem("researchOutputs");
    return {};
  }
  return { ...formData, ...incomingFormData };
};

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
  // Plan Creation
  const [researchContext, setResearchContext] = useState(null);
  // Dynamic form
  const [formData, setFormData] = useReducer(reducer, {});
  const [loadedRegistries, setLoadedRegistries] = useState({});
  const [loadedTemplates, setLoadedTemplates] = useState({});
  // Write Plan
  const [loadedSectionsData, setLoadedSectionsData] = useState({});
  const [researchOutputs, setResearchOutputs] = useState([]);
  const [displayedResearchOutput, setDisplayedResearchOutput] = useState(null);
  const updateResearchOutputAnswer = useCallback((questionId, newAnswer) => {
    setDisplayedResearchOutput((prev) => ({
      ...prev,
      answers: prev.answers.map((a) =>
        a.question_id === questionId ? newAnswer : a,
      ),
    }));
  }, []);

  const [openedQuestions, setOpenedQuestions] = useState(null);
  const [userId, setUserId] = useState(-1);
  const [selectedTemplate, setSelectedTemplate] = useState(null);
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
      researchContext,
      setResearchContext,
      formData,
      setFormData,
      loadedRegistries,
      setLoadedRegistries,
      loadedTemplates,
      setLoadedTemplates,
      loadedSectionsData,
      setLoadedSectionsData,
      researchOutputs,
      setResearchOutputs,
      displayedResearchOutput,
      setDisplayedResearchOutput,
      updateResearchOutputAnswer,
      openedQuestions,
      setOpenedQuestions,
      userId,
      setUserId,
      setUrlParams,
      selectedTemplate,
      setSelectedTemplate,
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
      researchContext,
      formData,
      loadedRegistries,
      loadedTemplates,
      loadedSectionsData,
      researchOutputs,
      displayedResearchOutput,
      openedQuestions,
      userId,
      selectedTemplate,
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
