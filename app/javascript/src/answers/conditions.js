import { updateSectionProgress, getQuestionDiv } from "../utils/sectionUpdate";

document.addEventListener("turbo:load", () => {
  if ($(".answering-phase").length > 0) {
    // check phase has (standard) questions
    // hide already removed questions on load
    const removeData = $("#progress-data").data("remove");
    if (removeData) {
      removeData.forEach((id) => {
        getQuestionDiv(id).hide();
      });
    }

    // update progress on section panel on load
    const sectionsInfo = $("#progress-data").data("sections");
    if (sectionsInfo) {
      sectionsInfo.forEach((sectionInfo) => {
        const forms = $(`#collapse-${sectionInfo.id}`).find("form");
        if (forms.length > 0) {
          // ensure current phase
          updateSectionProgress(
            sectionInfo.id,
            sectionInfo.no_ans,
            sectionInfo.no_qns,
          );
        }
      });
    }
  }
});
