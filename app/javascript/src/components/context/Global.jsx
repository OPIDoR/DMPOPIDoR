import React, {
  createContext, useReducer, useState,
} from 'react';

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
  const [locale, setLocale] = useState('fr_FR');
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
  const [openedQuestions, setOpenedQuestions] = useState(null);
  const [userId, setUserId] = useState(-1);
  const [selectedTemplate, setSelectedTemplate] = useState(null);
  const [formSelectors, setFormSelector] = useState({});
  const [configuration, setConfiguration] = useState({});
  const [savedGuidances, setSavedGuidances] = useState([]);
  const [commentablePlan, setCommentablePlan] = useState(false);

  /* It's setting the formData in sessionStorage. */
  // useEffect(() => {
  //   /* It's setting the form in localStorage. */
  //   localStorage.setItem('formData', JSON.stringify(formData));
  // }, [formData]);

  /* It's setting the researchOutputs in sessionStorage. */
  // useEffect(() => {
  //   sessionStorage.setItem("researchOutputs", JSON.stringify(researchOutputs));
  // }, [researchOutputs]);

  const setUrlParams = (data = {}) => {
    const currentParams = Object.fromEntries(new URLSearchParams(window.location.search));
    const mergedParams = { ...currentParams, ...data };
    Object.keys(mergedParams).forEach((key) => {
      if (!mergedParams[key] || mergedParams[key] === '') {
        delete mergedParams[key];
      }
    });
    const newSearchParams = new URLSearchParams(mergedParams);
    window.history.replaceState(null, '', `${window.location.pathname}?${newSearchParams.toString()}`);
  };

  return (
    <GlobalContext.Provider
      value={{
        locale,
        setLocale,
        dmpId,
        setDmpId,
        persons,
        setPersons,
        researchContext,
        setResearchContext,
        // Dynamic form
        formData,
        setFormData,
        loadedRegistries,
        setLoadedRegistries,
        loadedTemplates,
        setLoadedTemplates,
        // Write Plan
        loadedSectionsData,
        setLoadedSectionsData,
        researchOutputs,
        setResearchOutputs,
        displayedResearchOutput,
        setDisplayedResearchOutput,
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
      }}
    >
      {children}
    </GlobalContext.Provider>
  );
}

export default Global;
