import React, { useEffect, useState, useContext } from 'react';
import { useTranslation } from 'react-i18next';
import Swal from 'sweetalert2';

import { service } from '../../services';
import CustomButton from '../Styled/CustomButton';
import ContributorsList from './ContributorsList';
import ModalForm from '../Forms/ModalForm';
import { GlobalContext } from '../context/Global';
import swalUtils from '../../utils/swalUtils';
import CustomSpinner from '../Shared/CustomSpinner';
import * as styles from '../assets/css/form.module.css';
import { checkFragmentExists } from '../../utils/JsonFragmentsUtils';

function ContributorsTab({ planId, locale, readonly }) {
  const { t, i18n } = useTranslation();
  const {
    setLocale,
    dmpId, setDmpId,
  } = useContext(GlobalContext);
  const [show, setShow] = useState(false);
  const [index, setIndex] = useState(null);
  const [template, setTemplate] = useState(null);
  const [contributors, setContributors] = useState([]);
  const [fragmentId, setFragmentId] = useState(null);
  const [editedPerson, setEditedPerson] = useState({});
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    service.getContributors(planId).then((res) => {
      setContributors(res.data.contributors);
      setTemplate(res.data.template);
      setDmpId(res.data.dmp_id);
    })
      .catch((error) => setError(error))
      .finally(() => setLoading(false));
  }, [planId]);

  useEffect(() => {
    setLocale(locale);
    i18n.changeLanguage(locale.substring(0, 2));
  }, [planId, locale]);

  const handleSave = async (data) => {
    const newContributorsList = [...contributors];
    setLoading(true);
    if (checkFragmentExists(contributors.map((c) => c.data), data, template.schema.unicity)) {
      setError(t('recordAlreadyExists'));
    } else if (index !== null && fragmentId) {
      service.saveFragment(fragmentId, data)
        .then((res) => {
          newContributorsList[index].data = res.data.fragment;
          setContributors(newContributorsList);
        }).catch((error) => {
          setError(error);
        });
    } else {
      service.createFragment(data, template.id, dmpId)
        .then((res) => {
          newContributorsList.unshift({
            id: res.data.fragment.id,
            data: res.data.fragment,
            roles: [],
          });
          setContributors(newContributorsList);
        }).catch((error) => {
          setError(error);
        });
    }
    document.querySelector('#plan-title').scrollIntoView({ behavior: 'smooth', block: 'start' });
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
        service.destroyContributor(fragmentId).then(() => {
          newContributorsList.splice(idx, 1);
          setContributors(newContributorsList);
        }).catch(() => {
          Swal.fire(swalUtils.defaultDeleteErrorConfig(t, 'contributor'));
        });
      }
    });
  };

  return (
    <div style={{ position: 'relative' }}>
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
          mainFormDataType={'none'}
          mainFormTopic={'generic'}
          label={t('editPersonOrOrg')}
          readonly={readonly}
          show={show}
          handleSave={handleSave}
          handleClose={handleClose}
        />)}
      {!readonly && (
        <CustomButton
          handleClick={() => {
            setShow(true);
            setIndex(null);
          }}
          title={t('addPersonOrOrg')}
          buttonColor="rust"
          position="start"
        ></CustomButton>
      )}
    </div>
  );
}

export default ContributorsTab;
