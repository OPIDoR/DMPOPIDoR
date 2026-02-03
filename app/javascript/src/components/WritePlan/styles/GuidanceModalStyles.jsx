import styled from 'styled-components';

export const NavBody = styled.div`
  color: #000;
  padding: 0;
  margin: -1px 0 0 0;
  min-height: 318px;
  max-height: 318px;
  border-radius: 10px;
  border: 1px solid var(--dark-blue);
`;

export const NavBodyText = styled.div`
  box-sizing: border-box;
  font-family: "Helvetica Neue", sans-serif;
  color: var(--dark-blue);
  height: 310px;
  max-height: 310px;
  border-radius: 10px;

  a {
    text-decoration: underline;
  }
`;

export const ScrollNav = styled.div`
  overflow: auto;
  height: 100%;
  scrollbar-width: bold;
  scrollbar-color: var(--dark-blue) transparent;
  padding: 10px;
  &::-webkit-scrollbar {
    width: 16px;
    display: flex;
    justify-content: space-between;
    background: var(--white);
    border-radius: 0 10px 10px 0;
  }
  &::-webkit-scrollbar-track {
    background: transparent;
  }
  &::-webkit-scrollbar-thumb {
    background: var(--dark-blue);
    border-radius: 8px;
    border: 3px solid var(--white);
  }
`;

export const Theme = styled.div`
  font-size: 25px;
  font-family: "Helvetica Neue", sans-serif;
  font-weight: bold;
`;

export const SubTitle = styled.div`
  font-size: 18px;
  font-family: "Helvetica Neue", sans-serif;
  font-weight: bold;
  margin-top: 10px;
`;
