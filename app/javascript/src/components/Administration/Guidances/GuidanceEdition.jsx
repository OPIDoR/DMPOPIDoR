import { useContext, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { Col, Row } from "react-bootstrap";

import * as styles from "../../assets/css/guidance_edition.module.css";
import { GlobalContext } from "../../context/GlobalContext";
import GuidanceGroupsList from "./GuidanceGroupsList";
import CustomSpinner from "../../Shared/CustomSpinner";
import { guidancesEdition } from "../../../services";

function GuidanceEdition() {
  const { t, i18n } = useTranslation();
  const { locale } = useContext(GlobalContext);
  const [guidanceGroups, setGuidanceGroups] = useState([]);
  const [loading, setLoading] = useState(true);
  /**
   * USE EFFECTS
   */

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
  }, [locale]);

  useEffect(() => {
    guidancesEdition
      .getGuidancesData()
      .then((res) => {
        setGuidanceGroups(res.data.guidance_groups);
        setLoading(false);
      })
      .catch((error) => {
        console.error(error);
        setLoading(false);
      });
  }, []);

  /**
   * RENDERING
   */

  return (
    <div style={{ position: "relative" }}>
      {loading && <CustomSpinner isOverlay={true} />}
      <Row>
        <Col md={12}>
          <h1>{t("guidance")}</h1>
          <p className={styles.paragraph}>{t("guidanceEditionInfo")}</p>
        </Col>
      </Row>
      <Row>
        <Col md={12}>
          <h2>{t("guidanceGroupList")}</h2>
          <GuidanceGroupsList locale={locale} guidanceGroups={guidanceGroups} />
        </Col>
      </Row>
    </div>
  );
}

export default GuidanceEdition;
