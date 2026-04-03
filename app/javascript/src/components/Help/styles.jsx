import styled from 'styled-components';

export const FaqContainer = styled.div`
  color: var(--dark-blue);
  width: 100%;
  display: flex;
  align-items: flex-start;
`;

export const FaqCategories = styled.div`
  width: 350px;
  color: var(--dark-blue);
`;

export const StyledUl = styled.ul`
  list-style-type: none;
`;

export const StyledLi = styled.li`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  color: var(--white);
  background-color: ${({ $active }) => ($active === 'true' ? 'var(--dark-blue)' : 'var(--blue)')};
  cursor: pointer;
  margin: 0 4px 4px 0;
  border-radius: ${({ $onlyChild }) => ($onlyChild === 'true' ? '10px 0 0 10px' : '0')};

  &:hover {
    background-color: var(--dark-blue);
  }

  &:first-child {
    border-radius: ${({ $onlyChild }) => ($onlyChild === 'true' ? '10px 0 0 10px' : '10px 0 0 0')};
  }

  &:last-child {
    border-radius: ${({ $onlyChild }) => ($onlyChild === 'true' ? '10px 0 0 10px' : '0 0 0 10px')};
  }

  img {
    flex: 1;
    margin-right: 20px;
    max-width: 50px;
    filter: grayscale(1) invert(1);
  }

  .text {
    flex-grow: 1;
    margin: 0 10px;
    font-weight: 700;
  }
`;

export const FaqContent = styled.div`
  max-width: 100%;
  padding: 20px;
  box-sizing: border-box;
  flex: 1;
  border: 1px solid var(--dark-blue);
  color: var(--dark-blue);
  min-height: 300px;
  border-radius: 0 10px 10px 10px;
  position: relative;
  z-index: 1;

  p:has(img) {
    text-align: center;
  }

  img {
    max-width: 100%;
    border: 1px solid var(--dark-blue);
    border-radius: 8px;
  }

  video {
    width: 100%;
    height: 450px;
    object-fit: cover;
    border: 1px solid var(--dark-blue);
    border-radius: 8px;
  }
`;

export const FaqContentBottom = styled.div`
  position: relative;
  display: block;
  float: right;
  border: none;
  bottom: 20px;
  right: 20px;
  width: 200px;
  height: 200px;
  pointer-events: none;
  opacity: 0.4;

  img {
    border: none;
  }
`;
