import React, { StrictMode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import '../../i18n.js';
import GlossaryPage from './GlossaryPage.jsx';

const queryClient = new QueryClient();

export default function GlossaryLayout({ locale = 'fr-FR', directusUrl }) {
  return (
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <GlossaryPage locale={locale} directusUrl={directusUrl} />
      </QueryClientProvider>
    </StrictMode>
  );
}
