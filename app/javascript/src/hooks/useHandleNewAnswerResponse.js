import { useCallback, useContext } from "react";
import unionBy from "lodash.unionby";
import { FormsContext } from "../components/context/FormsContext";
import { SectionsContext } from "../components/context/SectionsContext";

function useHandleNewAnswerResponse() {
  const { setFormData, setLoadedTemplates } = useContext(FormsContext);
  const {
    displayedResearchOutput,
    setDisplayedResearchOutput,
    researchOutputs,
    setResearchOutputs,
  } = useContext(SectionsContext);

  const handleNewAnswerResponse = useCallback((data, questionId, setAnswer) => {
    const fragment = data.fragment;
    const tplt = data.template;
    const answerId = data.answer_id;
    setLoadedTemplates((prev) => ({ ...prev, [tplt.name]: tplt }));
    setFormData({ [fragment.id]: fragment });
    setAnswer({
      id: answerId,
      question_id: questionId,
      fragment_id: fragment.id,
      madmp_schema_id: tplt.id,
    });

    const updatedResearchOutput = {
      ...displayedResearchOutput,
      answers: [
        ...displayedResearchOutput.answers,
        {
          answer_id: answerId,
          question_id: questionId,
          fragment_id: fragment.id,
        },
      ],
    };
    setResearchOutputs(unionBy(researchOutputs, [updatedResearchOutput], "id"));
    setDisplayedResearchOutput(updatedResearchOutput);
  });
  return handleNewAnswerResponse;
}

export default useHandleNewAnswerResponse;
