import React, { StrictMode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import '../../i18n.js';
import HelpPage from './HelpPage.jsx';

const queryClient = new QueryClient();

export default function HelpLayout({ locale = 'fr-FR', directusUrl }) {
  return (
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <HelpPage locale={locale} directusUrl={directusUrl} />
      </QueryClientProvider>

    </StrictMode>
  );
}
