import uniqueId from 'lodash.uniqueid';
import React from 'react';
import styled from 'styled-components';

const DefaultButton = styled.button`
  padding: 10px 20px 10px 20px;
  box-sizing: border-box;
  border-radius: 10px;
  font-size: 15px;
  background-color: var(--rust) !important;
  border-color: var(--rust) !important;
  transition: ease-in-out 0.2s;

  &:hover {
    background-color: var(--dark-blue) !important;
    border-color: var(--dark-blue) !important;
  }
`;
const BlueButton = styled(DefaultButton)`
background-color: var(--dark-blue)!important;
border-color: var(--dark-blue) !important;
`;

const WhiteButton = styled(DefaultButton)`
background-color: white !important;
color: var(--blue) !important;
border-color: var(--dark-blue) !important;

&:hover {
  background-color: white !important;
  border-color: var(--dark-blue) !important;
}
`;

const ClassicDivButton = styled.div`
  display: flex;
  justify-content: ${(props) => (props.$position || 'start')};
`;

const StickyDivButton = styled.div`
  display: flex;
  justify-content: ${(props) => (props.$position || 'start')};  position: sticky;
  bottom: 0;
  background-color: white;
  z-index: 10;
`;

const Button = (props) => {
  switch (props.$buttonType) {
  case 'blue':
    return <BlueButton {...props} />;
  case 'white':
    return <WhiteButton {...props} />;
  default:
    return <DefaultButton {...props} />;
  }
};

/**
 * This is a React component that renders a custom button with customizable properties such as title, type, and position.
 * @returns A React functional component that renders a custom button with customizable properties such as handleClick, title, type, and position. The
 * button is styled using CSS-in-JS with the help of the styled-components library. The component returns a div that contains a button element with an
 * onClick event listener that triggers the handleClick function passed as a prop.
 */
function CustomButton({
  handleClick, title, buttonType = 'button', buttonColor, position, sticky = false, disabled,
}) {
  const id = uniqueId('custom_button_');

  const handleButtonAction = (e) => {
    handleClick?.(e);
  };

  const DivButton = sticky ? StickyDivButton : ClassicDivButton;

  return (
    <DivButton $position={position}>
      <Button data-testid={id} type={buttonType} className="btn btn-primary" $buttonType={buttonColor} onClick={handleButtonAction} disabled={disabled}>
        {title}
      </Button>
    </DivButton>
  );
}

export default CustomButton;
