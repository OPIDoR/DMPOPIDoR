import React from 'react';
import * as styles from '../assets/css/stepper.module.css';

export function Stepper({ activeStep, children }) {
  const steps = React.Children.toArray(children);

  return (
    <div className={styles.stepper_container}>
      {steps.map((step, index) => {
        const isActive = index === activeStep;
        const isCompleted = index < activeStep;

        let circleClass = styles.step_circle;
        if (isCompleted) circleClass += ` ${styles.completed}`;
        else if (isActive) circleClass += ` ${styles.active}`;

        return (
          <div key={index} className={styles.step_item}>
            {index > 0 && (
              <div className={`${styles.connector} ${index <= activeStep ? styles.connector_completed : ''}`}/>
            )}
            <div className={circleClass} onClick={isCompleted ? step.props.onClick : null} style={{ cursor: 'pointer' }} >{index + 1}</div>
            <div className={styles.step_label}> {step.props.label} </div>
          </div>
        );
      })}
    </div>
  );
}

export function Step({ label, onClick }) {
  return (
    <div onClick={onClick}>
      {label}
    </div>
  );
}
