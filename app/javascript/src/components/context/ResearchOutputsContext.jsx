import { createContext, useCallback, useMemo, useState } from "react";

/* It's getting the form from localStorage. */
// const formLocalState = JSON.parse(localStorage.getItem('formData'));
// const researchOutputsLocalState = JSON.parse(sessionStorage.getItem("researchOutputs"));
export const ResearchOutputsContext = createContext();

/**
 * It's a function that takes a prop called children and returns a GlobalContext.Provider
 * component that has a value prop that is an object with two
 * properties: form and setform.
 * @returns The GlobalContext.Provider is being returned.
 */
function ResearchOutputs({ children }) {
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
      researchOutputs,
      setResearchOutputs,
      displayedResearchOutput,
      setDisplayedResearchOutput,
      updateResearchOutputAnswer,
    }),
    [researchOutputs, displayedResearchOutput],
  );

  return (
    <ResearchOutputsContext.Provider value={contextValue}>
      {children}
    </ResearchOutputsContext.Provider>
  );
}

export default ResearchOutputs;
