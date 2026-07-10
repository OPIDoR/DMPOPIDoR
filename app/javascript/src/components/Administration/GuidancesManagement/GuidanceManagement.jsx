import { useContext, useEffect, useState } from "react";
import toast from "react-hot-toast";
import { useTranslation } from "react-i18next";
import { Col, Form, InputGroup, Row } from "react-bootstrap";
import { useNavigate } from "react-router";
import { FaSearch } from "react-icons/fa";

import * as styles from "../../assets/css/guidance_edition.module.css";
import * as tablesStyles from "../../assets/css/tables.module.css";
import { GlobalContext } from "../../context/GlobalContext";
import GuidanceGroupList from "./GuidanceGroupList";
import CustomSpinner from "../../Shared/CustomSpinner";
import { guidancesManagement } from "../../../services";
import CustomButton from "../../Styled/CustomButton";
import GuidanceList from "./GuidanceList";

function GuidanceManagement() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const { locale } = useContext(GlobalContext);
  const [guidanceGroups, setGuidanceGroups] = useState([]);
  const [guidances, setGuidances] = useState([]);
  const [displayedGuidances, setDisplayedGuidances] = useState([]);
  const [guidanceSearchCriteria, setGuidanceSearchCriteria] = useState("");
  const [loading, setLoading] = useState(true);

  const handleKeyDown = (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      filterGuidances();
    }
  };

  const filterGuidances = () => {
    const filteredGuidances = guidances.filter(
      (guidance) =>
        guidance.text
          .toLowerCase()
          .includes(guidanceSearchCriteria.toLowerCase()) ||
        guidance.guidance_group
          .toLowerCase()
          .includes(guidanceSearchCriteria.toLowerCase()),
    );
    setDisplayedGuidances(filteredGuidances);
  };

  const handleGuidanceGroupEdit = (guidanceGroupId) => {
    navigate(`guidance_groups/${guidanceGroupId}/edit`);
  };
  const handleGuidanceGroupDelete = (guidanceGroupId) => {
    navigate(`guidance_groups/${guidanceGroupId}/delete`);
  };
  const handleGuidanceGroupPublication = (guidanceGroupId, published) => {
    const handlePublicationMethod = published
      ? guidancesManagement.unpublishGuidanceGroup
      : guidancesManagement.publishGuidanceGroup;

    handlePublicationMethod(guidanceGroupId)
      .then((res) => {
        setGuidanceGroups((prevGuidanceGroups) =>
          prevGuidanceGroups.map((guidanceGroup) =>
            guidanceGroup.id == guidanceGroupId
              ? { ...guidanceGroup, published: !published }
              : guidanceGroup,
          ),
        );
        toast.success(res.data.message);
      })
      .catch((error) => {
        console.error(error);
        toast.error(t("publicationError"));
      });
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
  }, [locale]);

  useEffect(() => {
    filterGuidances();
  }, [guidances]);

  useEffect(() => {
    guidancesManagement
      .getGuidanceGroupsData()
      .then((res) => {
        setGuidanceGroups(res.data.guidance_groups);
      })
      .catch((error) => {
        console.error(error);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  useEffect(() => {
    guidancesManagement
      .getGuidancesData()
      .then((res) => {
        setGuidances(res.data.guidances);
      })
      .catch((error) => {
        console.error(error);
      })
      .finally(() => {
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
          <p className={styles.paragraph}>{t("guidanceEditionPageInfo")}</p>
        </Col>
      </Row>
      <Row>
        <Col md={12}>
          <h2>{t("guidanceGroupList")}</h2>
          <GuidanceGroupList
            guidanceGroups={guidanceGroups}
            handleEdit={handleGuidanceGroupEdit}
            handleDelete={handleGuidanceGroupDelete}
            handlePublication={handleGuidanceGroupPublication}
          />
          <CustomButton
            handleClick={() => navigate("guidance_groups/new")}
            title={t("createGuidanceGroup")}
            buttonColor="rust"
            position="start"
          ></CustomButton>
        </Col>
      </Row>
      <Row>
        <Col md={12}>
          <h2>{t("guidanceList")}</h2>
          <p className={styles.paragraph}>{t("writeGuidanceByThemes")}</p>
          <p className={styles.paragraph}>{t("guidanceForFunders")}</p>

          <Row className="mb-3">
            <InputGroup className="col-md-4">
              <InputGroup.Text className={tablesStyles.admin_search_bar}>
                <FaSearch />
              </InputGroup.Text>
              <Form.Control
                value={guidanceSearchCriteria}
                onChange={(e) => setGuidanceSearchCriteria(e.target.value)}
                onKeyDown={(e) => handleKeyDown(e)}
                aria-label="Guidance Search"
                aria-describedby="search-addon"
              />
            </InputGroup>
            <Col md={8} className="text-right">
              <CustomButton
                handleClick={filterGuidances}
                title={t("search")}
                buttonColor="rust"
                position="start"
                style={{ margin: "0", paddingLeft: "10px" }}
              />
            </Col>
          </Row>
          <GuidanceList guidances={displayedGuidances} />
          <CustomButton
            handleClick={() => {}}
            title={t("createGuidance")}
            buttonColor="rust"
            position="start"
          ></CustomButton>
        </Col>
      </Row>
    </div>
  );
}

export default GuidanceManagement;
