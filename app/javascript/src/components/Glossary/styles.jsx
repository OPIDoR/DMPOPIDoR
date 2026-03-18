import styled from 'styled-components';

export const StyledUl = styled.ul`
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0;
  align-items: center;
  list-style-type: none;
  white-space: nowrap;
  margin-bottom: 20px;

  position: -webkit-sticky;
  position: sticky;
  top: 60px;
  z-index: 9;
  width: 100%;
  height: 40px;
  background-color: var(--white);
`;

export const StyledLi = styled.li`
  color: var(--dark-blue);
  cursor: pointer;
  font-weight: 900;

  &:not(:last-child)::after {
    content: '●';
    margin: 0 20px 0 20px;
    display: inline-block;
    vertical-align: middle;
    color: var(--blue);
  }

  &:hover {
    color: var(--rust);
    text-decoration: underline;
  }

  &.active {
    color: var(--rust);
    text-decoration: underline;
  }

  &.disabled {
    color: rgba(0, 0, 0, 0.5);
    font-weight: 400;

    &:hover {
      color: rgba(0, 0, 0, 0.5);
      text-decoration: none;
      cursor: default;
    }
  }
`;

export const GlossaryContent = styled.div`
  margin: 20px 0 0 -35px;

  .letter {
    font-weight: 900;
    font-size: 28px;
    color: var(--dark-blue);

    &.active {
      color: var(--rust);
      font-weight: 900;
    }

    span {
      font-size: 14px;
      font-weight: 400;
      font-style: italic;
      color: grey;
      margin-left: 10px;
    }
  }

  ul {
    display: flex;
    flex-direction: column;
    flex-wrap: wrap;
    justify-content: space-between;
    margin-top: 20px;
    list-style-type: none;
    scroll-margin-top: 110px;

    li {
      margin: 10px 0 10px 20px;

      .term {
        font-weigth: 900;
        font-size: 22px;
      }

      .description {
        color: var(--blue);

        ul {
          list-style-type: disc;
        }
      }
    }
  }
`;
