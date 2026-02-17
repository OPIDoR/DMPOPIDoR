import { useState, useEffect, useContext } from "react";

import Button from "react-bootstrap/Button";
import Card from "react-bootstrap/Card";
import Collapse from "react-bootstrap/Collapse";

import { useTranslation } from "react-i18next";
import { TfiAngleDown, TfiAngleRight } from "react-icons/tfi";
import { toast } from "react-hot-toast";

import * as styles from "../assets/css/general_info.module.css";
import { generalInfo } from "../../services/index.js";
import { GlobalContext } from "../context/GlobalContext.jsx";
import DynamicForm from "../Forms/DynamicForm";
import FunderImport from "./FunderImport.jsx";
import { getErrorMessage } from "../../utils/utils";

function GeneralInfo({
  planId,
  dmpId,
  projectFragmentId,
  metaFragmentId,
  locale = "en_GB",
  researchContext = "research_project",
  isTest = true,
  readonly,
  isClassic = false,
}) {
  const { t, i18n } = useTranslation();
  const { setLocale, setDmpId } = useContext(GlobalContext);

  const [isTestPlan, setIsTestPlan] = useState(isTest);

  const [isOpenProjectForm, setIsOpenProjectForm] = useState(true);

  const [isOpenMetaForm, setIsOpenMetaForm] = useState(true);

  const projectFormLabel =
    researchContext === "research_project"
      ? t("projectDetails")
      : t("entityDetails");

  const handleClickIsTestPlan = async (e) => {
    const checked = e.target.checked;
    setIsTestPlan(checked);

    let response;
    try {
      response = await generalInfo.saveIsTestPlan(planId, checked);
    } catch (error) {
      const errorMessage = getErrorMessage(error) || t("planStatusChangeError");
      return toast.error(errorMessage);
    }

    return toast.success(response?.data?.msg);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    setLocale(locale);
    i18n.changeLanguage(locale.substring(0, 2));

    setDmpId(dmpId);
  }, [dmpId, locale]);

  /**
   * RENDERING
   */

  return (
    <>
      {!readonly && researchContext === "research_project" && (
        <FunderImport
          projectFragmentId={projectFragmentId}
          metaFragmentId={metaFragmentId}
          researchContext={researchContext}
          locale={locale}
          isClassic={isClassic}
        />
      )}
      <Card
        className={styles.card}
        style={{
          borderRadius: "10px",
          borderWidth: "2px",
          borderColor: "var(--dark-blue)",
        }}
      >
        <Card.Header
          style={{
            background: "white",
            borderRadius: "18px",
            borderBottom: "none",
          }}
        >
          <Button
            style={{ backgroundColor: "white", width: "100%", border: "none" }}
            onClick={() => setIsOpenProjectForm(!isOpenProjectForm)}
            aria-controls="project-form-collapse"
            aria-expanded={isOpenProjectForm}
          >
            <Card.Title>
              <div className={styles.question_title}>
                <div className={styles.question_text}>
                  <div className={styles.title}>{projectFormLabel}</div>
                </div>

                <span className={styles.question_icons}>
                  {isOpenProjectForm ? (
                    <TfiAngleDown
                      style={{ minWidth: "35px" }}
                      size={35}
                      className={styles.down_icon}
                    />
                  ) : (
                    <TfiAngleRight
                      style={{ minWidth: "35px" }}
                      size={35}
                      className={styles.down_icon}
                    />
                  )}
                </span>
              </div>
            </Card.Title>
          </Button>
        </Card.Header>
        <Collapse in={isOpenProjectForm}>
          <div id="project-form-collapse">
            <Card.Body className={styles.card_body}>
              {projectFragmentId && (
                <DynamicForm
                  fragmentId={projectFragmentId}
                  readonly={readonly}
                />
              )}
            </Card.Body>
          </div>
        </Collapse>
      </Card>
      <Card
        className={styles.card}
        style={{
          borderRadius: "10px",
          borderWidth: "2px",
          borderColor: "var(--dark-blue)",
        }}
      >
        <Card.Header
          style={{
            background: "white",
            borderRadius: "18px",
            borderBottom: "none",
          }}
        >
          <Button
            style={{ backgroundColor: "white", width: "100%", border: "none" }}
            onClick={() => setIsOpenMetaForm(!isOpenMetaForm)}
            aria-controls="meta-form-collapse"
            aria-expanded={isOpenMetaForm}
          >
            <Card.Title>
              <div className={styles.question_title}>
                <div className={styles.question_text}>
                  <div className={styles.title}>{t("planInformation")}</div>
                </div>

                <span className={styles.question_icons}>
                  {isOpenMetaForm ? (
                    <TfiAngleDown
                      style={{ minWidth: "35px" }}
                      size={35}
                      className={styles.down_icon}
                    />
                  ) : (
                    <TfiAngleRight
                      style={{ minWidth: "35px" }}
                      size={35}
                      className={styles.down_icon}
                    />
                  )}
                </span>
              </div>
            </Card.Title>
          </Button>
        </Card.Header>
        <Collapse in={isOpenMetaForm}>
          <div id="meta-form-collapse">
            <Card.Body className={styles.card_body}>
              <div
                className="form-check form-switch"
                style={{ marginLeft: "15px" }}
              >
                <input
                  type="checkbox"
                  id="is_test"
                  checked={isTestPlan}
                  onClick={() => setIsTestPlan(!isTestPlan)}
                  onChange={(e) => handleClickIsTestPlan(e)}
                  disabled={readonly}
                  style={{ marginRight: "10px" }}
                />
                <label className="form-check-label" htmlFor="is_test">
                  {t("testPlan")}
                </label>
              </div>
              {metaFragmentId && (
                <DynamicForm fragmentId={metaFragmentId} readonly={readonly} />
              )}
            </Card.Body>
          </div>
        </Collapse>
      </Card>
    </>
  );
}

export default GeneralInfo;
