import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    root: path.resolve(__dirname),
    environment: "jsdom",
    globals: true,
    setupFiles: "./setupTests.js",
    css: true,
    server: {
      deps: {
        inline: ["react-loader-spinner"],
      },
    },
  },
});
