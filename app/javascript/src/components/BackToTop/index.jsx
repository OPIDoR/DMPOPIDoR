import styled from 'styled-components';
import { FaChevronUp } from 'react-icons/fa';
import { useTranslation } from 'react-i18next';
import { Tooltip as ReactTooltip } from 'react-tooltip';

const BackToTopButton = styled.div`
  position: fixed;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  border: 1px solid var(--white);
  right: 3rem;
  bottom: 3rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--white);
  background-color: var(--dark-blue);
  transform: scale(1);
  transition: all 0.3s ease;

  &:hover {
    transform: scale(1.1);
  }
`;

const BackToTop = () => {
  const { t } = useTranslation();

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <>
      <ReactTooltip
        id="back-to-top-button"
        place="left"
        effect="solid"
        variant="info"
        content={t('backToTop')}
      />
      <BackToTopButton
        data-tooltip-id="back-to-top-button"
        onClick={scrollToTop}
      >
        <FaChevronUp size={28} />
      </BackToTopButton>
    </>
  );
};

export default BackToTop;
