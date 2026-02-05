import React from 'react';
import styled from 'styled-components';

const CircleContent = styled.div`
  margin: 30px 0 0 10px;
  display: flex;
  align-items: center;
`;

const Circle = styled.div`
  border-radius: 50%;
  width: 55px !important;
  height: 55px;
  padding: 0px;
  background: var(--rust);
  border: 3px solid var(--rust);
  color: var(--white);
  text-align: center;
  margin: 5px;
  font-size: 26px;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-right: 15px;
`;

const CircleText = styled.div`
  color: var(--dark-blue);
  font-size: 25px;
  font-weight: bold;
`;

function CircleTitle({ number, title }) {
  return (
    <div className="row">
      <div className="col-12">
        <CircleContent>
          <Circle>{number}</Circle>
          <CircleText>{title}</CircleText>
        </CircleContent>
      </div>
    </div>
  );
}

export default CircleTitle;
