import React, { StrictMode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import '../../i18n.js';
import NewsPage from './NewsPage.jsx';

const queryClient = new QueryClient();

export default function NewsPageLayout({ locale = 'fr-FR', size = 3 }) {
  return (
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <NewsPage locale={locale} size={size} />
      </QueryClientProvider>
    </StrictMode>
  );
}
