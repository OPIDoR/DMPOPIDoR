import React from 'react';
import styled from 'styled-components';

const Text = styled.span`
  margin-left: 15px;
  font-size: 16px;
`;

const AlertContainer = styled.div`
  margin: ${(props) => (props.$type === 'info' ? '0px 0px 0px -360px' : '10px 0px 10px 30px')};
  background-color: ${(props) => (props.$type === 'info' ? 'var(--dark-blue)' : 'var(--rust)')};
  padding: 10px;
  border-radius: 8px;
  z-index: 999;
  color: ${(props) => (props.$type === 'info' ? 'var(--white)' : 'unset')};
  text-align: ${(props) => (props.$type === 'info' ? 'unset' : 'start')};
  width: ${(props) => (props.$type === 'info' ? 'unset' : '62%')};
`;

const IconColor = styled.a`
  color: ${(props) => (props.type === 'info' ? 'var(--white)' : 'var(--yellow)')};
  font-size: 20px;
`;

function Info({ text, icon, type }) {
  return (
    <AlertContainer $type={type}>
      <span>
        <IconColor $type={type}>
          <i className={icon} />
        </IconColor>
      </span>
      <Text>{text}</Text>
    </AlertContainer>
  );
}

export default Info;
