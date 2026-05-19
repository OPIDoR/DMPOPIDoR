// import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import { Tinymce } from "../../utils/tinymce";
import { isObject, isString } from "../../utils/isType";
import getConstant from "../../utils/constants";
import { addAsterisks } from "../../utils/requiredField";

import onChangeQuestionFormat, {
  onChangeQuestionClassname,
} from "../questions/sharedEventHandlers";
import initQuestionOption from "../questionOptions/index";
import updateConditions from "../conditions/updateConditions";

document.addEventListener("turbo:load", () => {
  const parentSelector = ".section-group";

  const initQuestion = (context) => {
    const target = $(`#${context}`);
    if (isObject(target)) {
      initQuestionOption(context);
      addAsterisks(`#${context}`);
      // Swap in the question_formats when the user selects an option based question type
      $(`#${context} select.question_format`).on("change", (e) => {
        onChangeQuestionFormat(e);
      });
      $(`#${context} select.question_schema_class`).on("change", (e) => {
        onChangeQuestionClassname(e);
      });
    }
  };

  $(".question_container").each((i, element) => {
    const questionId = $(element).attr("id");
    initQuestion(questionId);
  });

  const getQuestionPanel = (target) => {
    let cardBody;
    if (isObject(target)) {
      cardBody = target.closest(".question_container");
      if (!isObject(cardBody) || !isString(cardBody.attr("id"))) {
        cardBody = target.closest(".card-body").find(".new-question");
      }
    }
    return cardBody;
  };
  const initSection = (selector) => {
    if (isString(selector)) {
      const questionForm = $(`#${selector}`).find(".question_form");
      if (questionForm.length > 0) {
        initQuestion(selector);
      }
    }
  };

  // Attach handlers for the Section expansion
  $(parentSelector).on(
    "ajax:before",
    'a.ajaxified-section[data-remote="true"]',
    (e) => {
      const accordionBody = $(e.target)
        .parents(".accordion-item")
        .find(".accordion-collapse")
        .find(".accordion-body");
      return accordionBody.attr("data-loaded") === "false";
    },
  );

  $(parentSelector).on(
    "ajax:success",
    'a.ajaxified-section[data-remote="true"]',
    (e) => {
      const accordionBody = $(e.target)
        .parents(".accordion-item")
        .find(".accordion-collapse")
        .find(".accordion-body");
      const accordionCollapse = accordionBody.parents(".accordion-collapse");
      if (isObject(accordionBody)) {
        // Display the section's html
        accordionBody.attr("data-loaded", "true");
        accordionBody.append(e.detail[0].html);

        // Wire up the section
        initSection(`${accordionCollapse.attr("id")}`);
      }
    },
  );

  // Attach handlers for the Question show/edit/new
  $(parentSelector).on(
    "ajax:before",
    'a.ajaxified-question[data-remote="true"]',
    (e) => {
      const cardBody = getQuestionPanel($(e.target));
      if (isObject(cardBody)) {
        // Release any Tinymce editors that have been loaded
        cardBody.find(".question").each((idx, el) => {
          Tinymce.destroyEditorById($(el).attr("id"));
        });
      }
    },
  );
  $(parentSelector).on(
    "ajax:success",
    'a.ajaxified-question[data-remote="true"]',
    (e) => {
      const target = $(e.target);
      const cardBody = getQuestionPanel(target);
      if (isObject(cardBody)) {
        const id = cardBody.attr("id");
        // Display the section's html
        cardBody.html(e.detail[0].html);
        initQuestion(id);
        updateConditions(id);
        if (cardBody.is(".new-question")) {
          target.hide();
        }
      }
    },
  );
  $(parentSelector).on(
    "ajax:error",
    'a.ajaxified-question[data-remote="true"]',
    (e) => {
      const cardBody = getQuestionPanel($(e.target));
      if (isObject(cardBody)) {
        cardBody.html(
          `<div class="float-end alert alert-warning" role="alert">${getConstant("AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION")}</div>`,
        );
      }
    },
  );
  // When we cancel the new question we just remove the form and its Tinymce editors
  $(parentSelector).on("click", ".cancel-new-question", (e) => {
    e.preventDefault();
    const target = $(e.target);
    const card = target.closest(".question_container");
    card.find(".question").each((idx, el) => {
      Tinymce.destroyEditorById($(el).attr("id"));
    });
    card.html("");
    card
      .closest(".card-body")
      .find('.new-question-button a.ajaxified-question[data-remote="true"]')
      .show();
  });
  // Handle the section that has focus on initial page load
  const currentUpdatedSection = $(".accordion-collapse.collapse.show");
  if (currentUpdatedSection.length > 0) {
    initSection(`${currentUpdatedSection.attr("id")}`);
  }
});
