import styled from 'styled-components';

export const NavBodyText = styled.div`
  background: var(--white);
  padding: 5px 18px 5px 18px;
  border-radius: 10px;
  margin: 0 10px 10px 0;
  font-family: "Helvetica Neue", sans-serif;
  color: var(--dark-blue);
  border: 1px solid var(--dark-blue);
`;

export const ScrollNav = styled.div`
  max-height: 210px;
  overflow: auto;
  overflow-anchor: none;
  scrollbar-width: bold;
  scrollbar-color: var(--dark-blue) transparent;
  &::-webkit-scrollbar {
    width: 16px;
    display: flex;
    justify-content: space-between;
    background: var(--white);
    border-radius: 13px;
  }
  &::-webkit-scrollbar-track {
    background: transparent;
  }
  &::-webkit-scrollbar-thumb {
    background: var(--dark-blue);
    border-radius: 8px;
    border: 3px solid var(--dark-blue);
  }
`;

export const CommentsCard = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 20px 0px 0px 0;
`;
