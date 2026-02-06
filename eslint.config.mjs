import js from '@eslint/js';
import globals from 'globals';
import react from 'eslint-plugin-react';
import reactCompiler from 'eslint-plugin-react-compiler';
import { defineConfig } from 'eslint/config';
import { FlatCompat } from '@eslint/eslintrc';
import { fixupConfigRules, fixupPluginRules } from '@eslint/compat';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

export default defineConfig([
  {
    files: ['**/*.{js,mjs,cjs,jsx,ts,tsx}'],

    extends: [
      ...fixupConfigRules(
        compat.extends(
          'plugin:react/recommended',
          'plugin:react-hooks/recommended',
          'plugin:react/jsx-runtime',
          'plugin:prettier/recommended'
        )
      ),
      js.configs.recommended,
      reactCompiler.configs.recommended,
    ],

    plugins: {
      react: fixupPluginRules(react),
    },

    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      parserOptions: { ecmaFeatures: { jsx: true } },
      globals: {
        ...globals.node,
        ...globals.browser,
        ...globals.jquery,
        ...globals.jasmine,
        timeago: true,
        fixture: true,
        spyOnEvent: true,
      },
    },

    settings: {
      react: { version: 'detect' },
    },

    rules: {
      'prettier/prettier': 'error',
      'react/no-deprecated': 'warn',
      'react/no-direct-mutation-state': 'error',
    },
  },
]);
