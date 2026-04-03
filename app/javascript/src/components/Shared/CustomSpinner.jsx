import React from 'react';
import { RotatingTriangles } from 'react-loader-spinner';
import { useTranslation } from 'react-i18next';

import * as styles from '../assets/css/overlay.module.css';

function CustomSpinner({ isOverlay = false }) {
  const { t } = useTranslation();
  return (
    <div className={styles.overlay} style={isOverlay ? { position: 'absolute', backgroundColor: 'white' } : null}>
      <RotatingTriangles
        visible={true}
        height="80"
        width="80"
        colors={['#2c7dad', '#c6503d', '#FFCC00']}
        ariaLabel="rotating-triangels-loading"
        wrapperStyle={{}}
        wrapperClass="rotating-triangels-wrapper"
      />
      {t('loading')}
    </div>
  );
}

export default CustomSpinner;
