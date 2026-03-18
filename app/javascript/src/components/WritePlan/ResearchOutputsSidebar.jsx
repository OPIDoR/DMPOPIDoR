import React, { useContext, useState, useEffect } from 'react';
import styled from 'styled-components';
import { MdAddCircleOutline, MdDragIndicator } from 'react-icons/md';
import { useTranslation } from 'react-i18next';
import chunk from 'lodash.chunk';

import { AnimatePresence, motion } from 'motion/react';
import { DndContext } from '@dnd-kit/core';
import { SortableContext, useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

import { GlobalContext } from '../context/Global';
import ResearchOutputModal from '../ResearchOutput/ResearchOutputModal';
import { RESEARCH_OUTPUTS_PER_PAGE } from '../../config';
import * as styles from '../assets/css/sidebar.module.css';
import { researchOutput } from '../../services';
import ResearchOutputsSidebarItem from './ResearchOutputsSidebarItem';

const AccordionContainer = styled.div`
  position: sticky;
  top: 65px;
  height: calc(100% - 65px);
  display: flex;
  flex-direction: column;
  width: 250px;
  margin: -1px 2px 0 0;
`;

const AccordionGroupWrapper = styled.div`
  overflow: hidden;
  border-radius: 8px 0 0 8px;
`;

const AccordionGroup = styled.div`
  width: 250px;
  border-top: 1px solid var(--white);
`;

const AccordionHeader = styled.div`
  font-weight: bold;
  cursor: pointer;
  background-color: var(--dark-blue);
  color: var(--white);
  text-align: center;
  line-height: 50px;
  height: 50px;
`;

const AccordionBody = styled.div`
  width: inherit;
`;

const AccordionItem = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;

  width: 100%;
  height: 50px;
  background-color: var(--blue);
  border-top: 1px solid var(--white);
  padding: 0 10px;
  line-height: 50px;
  color: var(--white);
  cursor: pointer;
  font-weight: bold;

  &.active, &:hover {
    background-color: #2c4473;
    transition: background-color 0.5s linear;
  }

  div {
    cursor: grab;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    padding: 2px;
    border-radius: 4px;

    &:hover {
      background-color: rgba(255, 255, 255, 0.2);
    }
  }
`;

function ResearchOutputsSidebar({ planId, readonly, setLoading }) {
  const { t } = useTranslation();
  const {
    researchOutputs,
    setResearchOutputs,
    displayedResearchOutput,
  } = useContext(GlobalContext);
  const [show, setShow] = useState(false);
  const [isDragging, setIsDragging] = useState(false);

  const orderedResearchOutputs = [...researchOutputs].sort((a, b) => a.order - b.order);

  const groups = orderedResearchOutputs.length > RESEARCH_OUTPUTS_PER_PAGE
    ? chunk(orderedResearchOutputs, RESEARCH_OUTPUTS_PER_PAGE)
    : [orderedResearchOutputs];

  const activeGroupIndex = displayedResearchOutput
    ? groups.findIndex((group) => group.some((item) => item.id === displayedResearchOutput.id))
    : 0;

  const [openGroups, setOpenGroups] = useState(new Set([activeGroupIndex]));

  useEffect(() => {
    if (activeGroupIndex !== -1) {
      setOpenGroups((prev) => new Set([...prev, activeGroupIndex]));
    }
  }, [activeGroupIndex]);

  /**
   * The function handleClose sets the state of setShow to false.
   */
  const handleClose = () => setShow(false);

  /**
   * The function sets the state of "show" to true.
   */
  const handleShow = () => setShow(true);

  const createButton = (
    <AccordionGroup>
      <AccordionBody>
        <button
          className={styles.add_research_output_button}
          onClick={(e) => {
            e.preventDefault();
            handleShow();
          }}
        >
          <div className={styles.nav_title}>
            <MdAddCircleOutline size={18} style={{ marginRight: '5px' }} /> {t('create')}
          </div>
        </button>
      </AccordionBody>
    </AccordionGroup>
  );

  const toggleGroup = (index) => {
    setOpenGroups((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(index)) {
        newSet.delete(index);
      } else {
        newSet.add(index);
      }
      return newSet;
    });
  };

  const itemBody = (group) => (
    <AccordionBody>
      {group.map((item) => (
        <ResearchOutputsSidebarItem key={item.id} item={item} setLoading={setLoading}>
          <SortableItem
            key={item.id}
            item={item}
            readonly={readonly}
          />
        </ResearchOutputsSidebarItem>
      ))}
    </AccordionBody>
  );

  function SortableItem({ item, readonly }) {
    const {
      attributes, listeners, setNodeRef, transform, transition, isDragging,
    } = useSortable({ id: item.id });

    const style = {
      transform: CSS.Transform.toString(transform),
      transition,
      zIndex: isDragging ? 9999 : 'auto',
      opacity: isDragging ? 0.8 : 1,
      width: '250px',
      pointerEvents: isDragging ? 'none' : 'auto',
    };

    return (
      <AccordionItem
        ref={setNodeRef}
        style={style}
        className={[
          isDragging ? 'dragging' : '',
          displayedResearchOutput.id === item.id ? 'active' : '',
        ].filter(Boolean).join(' ')}
      >
        {item.abbreviation.length > 20 ? `${item.abbreviation.slice(0, 17)}...` : item.abbreviation}
        {!readonly && researchOutputs.length > 1 && (
          <div {...attributes} {...listeners}>
            <MdDragIndicator size='18' />
          </div>
        )}
      </AccordionItem>
    );
  }

  const handleDragOver = (event) => {
    const { over } = event;
    if (!over) return;

    const groupIndex = groups.findIndex((group) => group.some((item) => item.id === over.id));

    if (groupIndex !== -1) {
      setOpenGroups((prev) => {
        const newSet = new Set(prev);
        newSet.add(groupIndex);
        return newSet;
      });
    }
  };

  const handleDragEnd = (event) => {
    const { active, over } = event;
    if (!over || active.id === over.id) return;

    const oldIndex = researchOutputs.findIndex((item) => item.id === active.id);
    const newIndex = researchOutputs.findIndex((item) => item.id === over.id);

    const newItems = [...researchOutputs];
    const [movedItem] = newItems.splice(oldIndex, 1);
    newItems.splice(newIndex, 0, movedItem);

    const updatedItems = newItems.map((item, index) => ({
      ...item,
      order: index,
    }));

    try {
      researchOutput.sort(planId, updatedItems.map(({ id }) => id));
    } catch {
      return;
    }

    return setResearchOutputs([...updatedItems]);
  };

  return (
    <>
      <DndContext
        onDragStart={() => setIsDragging(true)}
        onDragOver={handleDragOver}
        onDragEnd={(event) => {
          setIsDragging(false);
          handleDragEnd(event);
        }}
      >
        <AccordionContainer>
          <AccordionGroupWrapper>
            {groups.length > 1 ? (
              <SortableContext items={orderedResearchOutputs.map((item) => item.id)}>
                {groups.map((group, i) => (
                  <AccordionGroup
                    onMouseEnter={() => isDragging && !openGroups.has(i) && toggleGroup(i)}
                    key={i}
                  >
                    <AccordionHeader onClick={() => toggleGroup(i)}>
                      {i * RESEARCH_OUTPUTS_PER_PAGE + 1} -{' '}
                      {(i * RESEARCH_OUTPUTS_PER_PAGE + RESEARCH_OUTPUTS_PER_PAGE)}
                    </AccordionHeader>
                    <AnimatePresence mode="wait" initial={false}>
                      {openGroups.has(i) && (
                        <motion.div
                          initial={{ opacity: 0, y: -10, height: 0 }}
                          animate={{ opacity: 1, y: 0, height: 'auto' }}
                          exit={{ opacity: 0, y: -10, height: 0 }}
                          transition={isDragging ? { duration: 0 } : { duration: 0.3, ease: 'easeInOut' }}
                        >
                          {itemBody(group)}
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </AccordionGroup>
                ))}
              </SortableContext>
            ) : (
              <SortableContext key={'group-1'} items={groups.at(0).map((item) => item.id)}>
                <AccordionGroup>
                  {itemBody(groups.at(0))}
                </AccordionGroup>
              </SortableContext>
            )}
            {!readonly && createButton}
          </AccordionGroupWrapper>
        </AccordionContainer>
      </DndContext>
      {show && <ResearchOutputModal planId={planId} handleClose={handleClose} show={show} edit={false} />}
    </>
  );
}

export default ResearchOutputsSidebar;
