import { ThemeProvider } from '@mui/material';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import { extensionManager } from '@/utils/extension';

const queryClient = new QueryClient({
  defaultOptions: { queries: { refetchOnWindowFocus: false, retry: 3 } }
});

interface AppProps {
  children?: React.ReactNode;
}

const App: React.FC<AppProps> = ({ children }) => (
  <ThemeProvider theme={extensionManager.getTheme()}>
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  </ThemeProvider>
);

export default App;
