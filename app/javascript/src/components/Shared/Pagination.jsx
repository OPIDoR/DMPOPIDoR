import { useState, useEffect, useMemo } from "react";
import { t } from "i18next";

const getPager = (totalItems, currentPage = 1, pageSize = 10) => {
  const totalPages = Math.ceil(totalItems / pageSize);

  let startPage;
  let endPage;
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
  const pages = [...Array(endPage + 1 - startPage).keys()].map(
    (i) => startPage + i,
  );

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

const Pagination = ({ items, onChangePage, initialPage = 1, pageSize = 9 }) => {
  const [currentPage, setCurrentPage] = useState(initialPage);

  const pager = useMemo(
    () => getPager(items.length, currentPage, pageSize),
    [items.length, currentPage, pageSize],
  );

  const setPage = (page) => {
    if (page < 1 || page > pager.totalPages) return;
    setCurrentPage(page);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    if (!items?.length) return;
    const pageOfItems = items.slice(pager.startIndex, pager.endIndex + 1);
    onChangePage(pageOfItems, currentPage);
  }, [pager]);

  /**
   * RENDERING
   */

  if (!pager.pages || pager.pages.length <= 1) {
    return null;
  }

  const isFirst = currentPage === 1;
  const isLast = currentPage === pager.totalPages;

  return (
    <div
      className="dataTables_paginate paging_simple_numbers"
      id="hr-table_paginate"
    >
      <ul className="pagination">
        <li className={`page-item ${isFirst ? "disabled" : ""}`}>
          <button
            className="page-link"
            onClick={() => setPage(1)}
            disabled={isFirst}
          >
            {"<<"}
          </button>
        </li>
        <li className={`page-item ${isFirst ? "disabled" : ""}`}>
          <button
            className="page-link"
            onClick={() => setPage(pager.currentPage - 1)}
            disabled={isFirst}
          >
            {t("previous")}...
          </button>
        </li>
        {pager.pages.map((page, index) => (
          <li
            key={index}
            className={`page-item ${pager.currentPage === page ? "active" : ""}`}
          >
            <button className="page-link" onClick={() => setPage(page)}>
              {page}
            </button>
          </li>
        ))}
        <li
          className={`page-item ${pager.currentPage === pager.totalPages ? "disabled" : ""}`}
        >
          <button
            className="page-link"
            onClick={() => setPage(pager.currentPage + 1)}
            disabled={isLast}
          >
            {t("next")}...
          </button>
        </li>
        <li className={`page-item ${isLast ? "disabled" : ""}`}>
          <button
            className="page-link"
            onClick={() => setPage(pager.totalPages)}
            disabled={isLast}
          >
            {">>"}
          </button>
        </li>
      </ul>
    </div>
  );
};

export default Pagination;
