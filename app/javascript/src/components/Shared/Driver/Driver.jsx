import React, { useState, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { driver } from 'driver.js';
import 'driver.js/dist/driver.css';

import { useTour } from './DriverContext.jsx';
import { guidedTour } from '../../../services/index.js';
import './driver.css';

function Driver({
  locale = 'fr_FR', tourName, children, steps,
}) {
  const { t, i18n } = useTranslation();

  const { isOpen, setIsOpen } = useTour();

  const [isEnded, setIsEnded] = useState(false);

  const driverRef = useRef(null);

  useEffect(() => {
    if (!driverRef.current) {
      driverRef.current = driver({
        popoverClass: 'dmp-theme',
        animate: true,
        showProgress: true,
        allowClose: false,
        allowKeyboardControl: true,
        stageRadius: 10,
        stagePadding: 10,
        nextBtnText: t('next'),
        prevBtnText: t('previous'),
        doneBtnText: t('finish'),
        progressText: '{{current}} / {{total}}',
        steps,
        onPopoverRender: (popover) => {
          const ignoreBtn = document.createElement('button');
          ignoreBtn.innerText = t('ignoreGuidedTour');
          popover.footerButtons.prepend(ignoreBtn);
          ignoreBtn.addEventListener('click', () => driverRef?.current.destroy());
        },
        onDestroyed: () => {
          if (!isEnded) {
            guidedTour.endTour(tourName).then(({ data }) => {
              setIsEnded(data?.tour?.ended);
              setIsOpen(!data?.tour?.ended);
            });
          }
        },
      });
    }
  }, [steps]);

  useEffect(() => {
    i18n.changeLanguage(locale.substring(0, 2));
    handleRenderedChildren(steps.map(({ element }) => element));
  }, [isOpen]);

  const handleRenderedChildren = (childrenTags) => {
    const allChildrenRendered = childrenTags.every((tag) => document.querySelector(tag) !== null);

    if (!allChildrenRendered) {
      return setTimeout(() => handleRenderedChildren(childrenTags), 100);
    }

    return guidedTour.getTour(tourName)
      .then(({ data }) => {
        const open = isOpen || !data?.tour?.ended;
        setIsOpen(open);
        setIsEnded(data?.tour?.ended);
        if (open) {
          driverRef?.current.drive();
        }
      });
  };

  return children;
}

export default Driver;
