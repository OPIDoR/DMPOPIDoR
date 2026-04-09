import { createContext, useCallback, useMemo, useState } from "react";

/* It's getting the form from localStorage. */
// const formLocalState = JSON.parse(localStorage.getItem('formData'));
// const researchOutputsLocalState = JSON.parse(sessionStorage.getItem("researchOutputs"));
export const SectionsContext = createContext();

/**
 * It's a function that takes a prop called children and returns a GlobalContext.Provider
 * component that has a value prop that is an object with two
 * properties: form and setform.
 * @returns The GlobalContext.Provider is being returned.
 */
function SectionsProvider({ children }) {
  const [openedQuestions, setOpenedQuestions] = useState(null);
  const [savedGuidances, setSavedGuidances] = useState([]);
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

  const contextValue = useMemo(
    () => ({
      openedQuestions,
      setOpenedQuestions,
      savedGuidances,
      setSavedGuidances,
      researchOutputs,
      setResearchOutputs,
      displayedResearchOutput,
      setDisplayedResearchOutput,
      updateResearchOutputAnswer,
    }),
    [openedQuestions, savedGuidances, researchOutputs, displayedResearchOutput],
  );

  return (
    <SectionsContext.Provider value={contextValue}>
      {children}
    </SectionsContext.Provider>
  );
}

export default SectionsProvider;
