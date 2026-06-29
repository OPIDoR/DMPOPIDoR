import { useEffect, useState, useContext } from "react";
import { useTranslation } from "react-i18next";
import Swal from "sweetalert2";

import { madmpFragment } from "../../services";
import CustomButton from "../Styled/CustomButton";
import ContributorsList from "./ContributorsList";
import ModalForm from "../Forms/ModalForm";
import { GlobalContext } from "../context/GlobalContext.jsx";
import Forms from "../context/FormsContext.jsx";
import swalUtils from "../../utils/swalUtils";
import CustomSpinner from "../Shared/CustomSpinner";
import * as styles from "../assets/css/form.module.css";
import { checkFragmentExists } from "../../utils/JsonFragmentsUtils";
import { Col, Row } from "react-bootstrap";

function ContributorsTab({ readonly }) {
  const { t, i18n } = useTranslation();
  const { locale, dmpId, planId } = useContext(GlobalContext);
  const [show, setShow] = useState(false);
  const [index, setIndex] = useState(null);
  const [template, setTemplate] = useState(null);
  const [contributors, setContributors] = useState([]);
  const [fragmentId, setFragmentId] = useState(null);
  const [editedPerson, setEditedPerson] = useState({});
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  const handleSave = async (data) => {
    const newContributorsList = [...contributors];
    setLoading(true);
    if (
      checkFragmentExists(
        contributors.map((c) => c.data),
        data,
        template.schema.unicity,
      )
    ) {
      setError(t("recordAlreadyExists"));
    } else if (index !== null && fragmentId) {
      madmpFragment
        .saveFragment(fragmentId, data)
        .then((res) => {
          newContributorsList[index].data = res.data.fragment;
          setContributors(newContributorsList);
        })
        .catch((error) => {
          setError(error);
        });
    } else {
      madmpFragment
        .createFragment(data, template.id, dmpId)
        .then((res) => {
          newContributorsList.unshift({
            id: res.data.fragment.id,
            data: res.data.fragment,
            roles: [],
          });
          setContributors(newContributorsList);
        })
        .catch((error) => {
          setError(error);
        });
    }
    document
      .querySelector("#plan-title")
      .scrollIntoView({ behavior: "smooth", block: "start" });
    handleClose();
    setLoading(false);
  };

  const handleClose = () => {
    setShow(false);
    setIndex(null);
    setEditedPerson({});
    setFragmentId(null);
  };

  const handleEdit = (idx) => {
    setIndex(idx);
    setEditedPerson(contributors[idx].data);
    setFragmentId(contributors[idx].id);
    setShow(true);
  };

  const handleDelete = (idx) => {
    const fragmentId = contributors[idx].id;
    const newContributorsList = [...contributors];

    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        madmpFragment
          .destroyContributor(fragmentId)
          .then(() => {
            newContributorsList.splice(idx, 1);
            setContributors(newContributorsList);
          })
          .catch(() => {
            Swal.fire(swalUtils.defaultDeleteErrorConfig(t, "contributor"));
          });
      }
    });
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    madmpFragment
      .getContributors(planId)
      .then((res) => {
        setContributors(res.data.contributors);
        setTemplate(res.data.template);
      })
      .catch((error) => setError(error))
      .finally(() => setLoading(false));
  }, [planId]);

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
  }, [planId, locale]);

  /**
   * RENDERING
   */

  return (
    <Row>
      <Col md={12}>
        <p>{t("listOfPersons")}</p>
        <p>{t("assigningRoles")}</p>
      </Col>
      <Col md={12}>
        <Forms>
          <div style={{ position: "relative" }}>
            {loading && <CustomSpinner isOverlay={true} />}
            <span className={styles.errorMessage}>{error}</span>
            <ContributorsList
              contributors={contributors}
              template={template}
              handleEdit={handleEdit}
              handleDelete={handleDelete}
              readonly={readonly}
            />
            {template && show && (
              <ModalForm
                fragmentId={fragmentId}
                data={editedPerson}
                template={template}
                mainFormDataType={"dataset"}
                mainFormTopic={"generic"}
                label={t("editPersonOrOrg")}
                readonly={readonly}
                show={show}
                handleSave={handleSave}
                handleClose={handleClose}
              />
            )}
            {!readonly && (
              <CustomButton
                handleClick={() => {
                  setShow(true);
                  setIndex(null);
                }}
                title={t("addPersonOrOrg")}
                buttonColor="rust"
                position="start"
              ></CustomButton>
            )}
          </div>
        </Forms>
      </Col>
    </Row>
  );
}

export default ContributorsTab;
