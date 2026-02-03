import React, { useState, useEffect } from 'react';
import { t } from 'i18next';

const Pagination = ({
  items, onChangePage, initialPage = 1, pageSize = 9,
}) => {
  const [pager, setPager] = useState({});

  useEffect(() => {
    if (items && items.length) {
      setPage(initialPage);
    }
  }, [items, initialPage]);

  const setPage = (page) => {
    if (page < 1 || page > pager.totalPages) {
      return;
    }

    const newPager = getPager(items.length, page, pageSize);
    const pageOfItems = items.slice(newPager.startIndex, newPager.endIndex + 1);

    setPager(newPager);
    onChangePage(pageOfItems, page);
  };

  const getPager = (totalItems, currentPage = 1, pageSize = 10) => {
    const totalPages = Math.ceil(totalItems / pageSize);

    let startPage; let
      endPage;
    if (totalPages <= 10) {
      startPage = 1;
      endPage = totalPages;
    } else if (currentPage <= 6) {
      startPage = 1;
      endPage = 10;
    } else if (currentPage + 4 >= totalPages) {
      startPage = totalPages - 9;
      endPage = totalPages;
    } else {
      startPage = currentPage - 5;
      endPage = currentPage + 4;
    }

    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = Math.min(startIndex + pageSize - 1, totalItems - 1);
    const pages = [...Array(endPage + 1 - startPage).keys()].map((i) => startPage + i);

    return {
      totalItems,
      currentPage,
      pageSize,
      totalPages,
      startPage,
      endPage,
      startIndex,
      endIndex,
      pages,
    };
  };

  if (!pager.pages || pager.pages.length <= 1) {
    return null;
  }

  return (
    <div className="dataTables_paginate paging_simple_numbers" id="hr-table_paginate">
      <ul className="pagination">
        <li className={pager.currentPage === 1 ? 'page-item' : ''}>
          <a className="page-link" onClick={() => setPage(1)}>
            {'<<'}
          </a>
        </li>
        <li className={pager.currentPage === 1 ? 'page-item' : ''}>
          <a className="page-link" onClick={() => setPage(pager.currentPage - 1)}>
            {t('previous')}...
          </a>
        </li>
        {pager.pages.map((page, index) => (
          <li key={index} className={pager.currentPage === page ? 'page-item active' : ''}>
            <a className="page-link" onClick={() => setPage(page)}>
              {page}
            </a>
          </li>
        ))}
        <li className={pager.currentPage === pager.totalPages ? 'page-item' : ''}>
          <a className="page-link" onClick={() => setPage(pager.currentPage + 1)}>
            {t('next')}...
          </a>
        </li>
        <li className={pager.currentPage === pager.totalPages ? 'page-item' : ''}>
          <a className="page-link" onClick={() => setPage(pager.totalPages)}>
            {'>>'}
          </a>
        </li>
      </ul>
    </div>
  );
};

export default Pagination;
