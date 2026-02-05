import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useTranslation } from "react-i18next";
import DOMPurify from "dompurify";
import { Alert } from "react-bootstrap";

import { CustomError, CustomSpinner } from "../Shared";
import { directus } from "../../services/index.js";

import {
  FaqContainer,
  FaqCategories,
  StyledUl,
  StyledLi,
  FaqContent,
  FaqContentBottom,
} from "./styles.jsx";

const languagesCode = {
  fr_FR: "fr",
  en_GB: "en",
};

export default function HelpPage({ locale, directusUrl }) {
  const { t } = useTranslation();
  const [activeFaq, setActiveFaq] = useState(0);

  const { isLoading, error, data } = useQuery({
    queryKey: ["help"],
    queryFn: () => directus.getHelp(directusUrl).then((res) => res),
  });

  if (isLoading) return <CustomSpinner />;

  if (error) return <CustomError error={error} />;

  const reduceTranslations = (translations, field) =>
    translations.reduce(
      (o, translation) => ({
        ...o,
        [languagesCode[
          translation?.languages_code?.code.replace("-", "_") || "fr_FR"
        ]]: translation[field],
      }),
      {},
    );

  const categories = data?.faq_categories.map(
    ({ translations: categTranslations, ...category }) => ({
      ...category,
      title: reduceTranslations(categTranslations, "title"),
      questions: category.questions.map(
        ({ translations: questionTranslations, ...question }) => ({
          ...question,
          question: reduceTranslations(questionTranslations, "question"),
          answer: reduceTranslations(questionTranslations, "answer"),
        }),
      ),
    }),
  );

  if (categories.length === 0) {
    return <Alert variant="warning">{t("helpPageUnderDevelopment")}</Alert>;
  }

  return (
    <FaqContainer>
      <FaqCategories>
        <StyledUl>
          {categories.map(({ title, icon }, index) => (
            <StyledLi
              $onlyChild={(categories.length === 1).toString()}
              $active={(activeFaq === index).toString()}
              key={`faq-category-${index}`}
              onClick={() => setActiveFaq(index)}
            >
              {icon && (
                <img
                  src={`/directus/assets/${icon.id}/${icon.filename_download}`}
                  alt=""
                  key={icon.id}
                />
              )}
              <span className="text" key={`faq-category-title-${index}`}>
                {title[languagesCode[locale]]}
              </span>
            </StyledLi>
          ))}
        </StyledUl>
      </FaqCategories>
      <FaqContent>
        {categories[activeFaq].questions.length === 0 ? (
          <div>{t("noQuestionForCategory")}</div>
        ) : (
          categories[activeFaq].questions.map(({ question, answer }, index) => (
            <div key={`faq-content-${index}`} style={{ marginBottom: "40px" }}>
              <h2 key={`faq-question-${index}`} style={{ marginTop: 0 }}>
                {question[languagesCode[locale]]}
              </h2>
              <div
                key={`faq-answer-${index}`}
                dangerouslySetInnerHTML={{
                  __html: DOMPurify.sanitize(answer[languagesCode[locale]], {
                    ADD_TAGS: ["iframe"],
                    ADD_ATTR: [
                      "allow",
                      "allowfullscreen",
                      "frameborder",
                      "scrolling",
                    ],
                  }),
                }}
              />
            </div>
          ))
        )}
        {categories?.[activeFaq]?.icon && (
          <FaqContentBottom>
            <img
              src={`/directus/assets/${categories?.[activeFaq]?.icon?.id}/${categories?.[activeFaq]?.icon?.filename_download}`}
            />
          </FaqContentBottom>
        )}
      </FaqContent>
    </FaqContainer>
  );
}
