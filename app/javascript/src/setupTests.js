import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { afterEach } from "vitest";
import ResizeObserver from "resize-observer-polyfill";

global.ResizeObserver = ResizeObserver;
afterEach(() => {
  cleanup();
});
