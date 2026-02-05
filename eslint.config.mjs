import js from '@eslint/js';
import globals from 'globals';
import react from 'eslint-plugin-react';
import reactCompiler from 'eslint-plugin-react-compiler';
import { defineConfig } from 'eslint/config';
import { fixupConfigRules, fixupPluginRules } from '@eslint/compat';
import { FlatCompat } from '@eslint/eslintrc';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default defineConfig([{
  files: ['**/*.{js,mjs,cjs,jsx,ts,tsx}'],

  extends: [
    ...fixupConfigRules(
      compat.extends(
        'plugin:react/jsx-runtime',
        'plugin:react/recommended',
        'plugin:react-hooks/recommended',
        'airbnb-base',
      ),
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

    parserOptions: {
      ecmaFeatures: { jsx: true },
    },

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
    // Import rules
    'import/no-unresolved': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/extensions': 'off',

    // Style
    indent: ['error', 2],
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single'],
    semi: ['error', 'always'],

    'prefer-destructuring': [
      'error',
      { array: false, object: false },
      { enforceForRenamedProperties: false },
    ],

    // React
    'react/jsx-uses-react': 'error',
    'react/jsx-uses-vars': 'error',
    'react/no-deprecated': 'warn',
    'react/no-direct-mutation-state': 'error',
  },
}]);
