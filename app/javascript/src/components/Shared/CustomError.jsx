import React from 'react';
import { useTranslation } from 'react-i18next';
import styled from 'styled-components';

import CustomButton from '../Styled/CustomButton';

const ErrorContainer = styled.div`
  width: 100% !important;
  height: 100% !important;
  font-family: montserrat, sans-serif;
  background-color: white;
`;

const BigText = styled.div`
  font-size: 150px;
  font-weight: 900;
  font-family: sans-serif;
  background: url(https://www.inist.fr/wp-content/uploads/2018/09/012_3132-scaled.jpg) no-repeat;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-size: cover;
  background-position: center;
`;

const SmallText = styled.div`
  font-family: montserrat, sans-serif;
  color: var(--rust);
  font-size: 24px;
  font-weight: 700;
  text-transform: uppercase;
`;

const Button = styled.button`
  color: #fff;
  padding: 12px 36px;
  font-weight: 600;
  border: none;
  position: relative;
  font-family: "Raleway", sans-serif;
  display: inline-block;
  text-transform: uppercase;
  border-radius: 90px;
  margin: 2px;
  margin-top: 2px;
  background-image: linear-gradient(to right, #09b3ef 0%, #1e50e2 51%, #09b3ef 100%);
  background-size: 200% auto;
  flex: 1 1 auto;
  text-decoration: none;

  &:hover,
  &:focus {
    color: #ffffff;
    background-position: right center;
    box-shadow: 0px 5px 15px 0px rgba(0, 0, 0, 0.1);
    text-decoration: none;
  }
`;

/**
 * CustomError component displays an error message and options for handling the error.
 * @param {string} code - The error code to be displayed. Defaults to '404'.
 * @param {string} message - The error message to be displayed. Defaults to a predefined message.
 * @param {any} error - The error object (if available) for further analysis.
 * @returns {JSX.Element} - A JSX component displaying the error message and options.
 */
function CustomError({ error, showWarning = true, handleClose }) {
  const { t } = useTranslation();
  const defaultMessage = t('problemOccurred');
  const errorMessage = error?.message || t('Internal Server Error');
  const errorDescription = error?.error || defaultMessage;
  const home = Object.prototype.hasOwnProperty.call(error, 'home') ? error?.home : true;

  return (
    <ErrorContainer>
      <div className="text-center">
        {showWarning && <BigText>Oops!</BigText>}
        <SmallText>{error?.code || ''} {errorMessage ? `- ${errorMessage}` : ''}</SmallText>
      </div>
      <div
        className="text-center"
        style={{
          width: '100% !important',
          overflowWrap: 'break-word',
          margin: '10px 0 10px 0',
        }}
      >
        <p>{errorDescription}</p>
        {home
          ? (<Button><a href="/">{t('Home page')}</a></Button>)
          : (<CustomButton handleClick={handleClose} title={'Close'} buttonColor={'white'} position="center" />)
        }
      </div>
    </ErrorContainer>
  );
}

export default CustomError;
