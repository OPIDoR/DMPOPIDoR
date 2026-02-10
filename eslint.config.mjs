import js from "@eslint/js";
import globals from "globals";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import reactCompiler from "eslint-plugin-react-compiler";
import prettier from "eslint-plugin-prettier";
import eslintConfigPrettier from "eslint-config-prettier";

export default [
  // Base Javascript configuration
  js.configs.recommended,

  // Ignore files & directories
  {
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "app/assets/builds/**",
      "app/javascript/locales/**",
    ],
  },

  // React files configuration
  {
    files: ["**/*.{jsx,tsx}"],

    plugins: {
      react,
      "react-hooks": reactHooks,
      "react-compiler": reactCompiler,
      prettier,
    },

    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
      },
    },

    settings: {
      react: {
        version: "detect",
      },
    },

    rules: {
      ...react.configs.recommended.rules,
      ...react.configs["jsx-runtime"].rules,
      ...reactHooks.configs.recommended.rules,
      ...reactCompiler.configs.recommended.rules,
      ...eslintConfigPrettier.rules,
      "prettier/prettier": "error",
      "react/no-deprecated": "warn",
      "react/no-direct-mutation-state": "error",
      "react/prop-types": "off", // TODO: disable this rule for now, need to be removed after migrating to TS
      "react-hooks/exhaustive-deps": "off",
    },
  },

  // JavaScript/Rails files configuration (Stimulus, Turbo, jQuery)
  {
    files: ["**/*.{js,mjs,cjs}"],

    plugins: {
      prettier,
    },

    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.jquery,
        ...globals.jasmine,
        Stimulus: "readonly",
        Turbo: "readonly",
        timeago: "readonly",
        fixture: "readonly",
        spyOnEvent: "readonly",
      },
    },

    rules: {
      ...eslintConfigPrettier.rules,
      "prettier/prettier": "error",
    },
  },
];
