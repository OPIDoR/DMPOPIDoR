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
function Global({
  children,
  initialLocale = "fr_FR",
  initialDmpId = null,
  initialUserId = -1,
  initialCommentablePlan = false,
}) {
  const locale = initialLocale;
  const dmpId = initialDmpId;
  const userId = initialUserId;
  const commentablePlan = initialCommentablePlan;
  const [persons, setPersons] = useState([]);

  const [openedQuestions, setOpenedQuestions] = useState(null);
  const [configuration, setConfiguration] = useState({});
  const [savedGuidances, setSavedGuidances] = useState([]);

  const contextValue = useMemo(
    () => ({
      locale,
      dmpId,
      persons,
      setPersons,
      openedQuestions,
      setOpenedQuestions,
      userId,
      configuration,
      setConfiguration,
      savedGuidances,
      setSavedGuidances,
      commentablePlan,
    }),
    [
      locale,
      dmpId,
      persons,
      openedQuestions,
      userId,
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
