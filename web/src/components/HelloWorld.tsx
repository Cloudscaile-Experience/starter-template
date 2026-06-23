import App from '@/App';
import { useHelloWorld } from '@/hooks/useHelloWorld';
import helloTranslations from '@/locales/hello.json';
import { extensionManager } from '@/utils/extension';
import { Box, CircularProgress, Typography } from '@mui/material';
import type React from 'react';
import { useTranslation } from 'react-i18next';

export const ns = extensionManager.getNsForTranslation('hello');
extensionManager.registerTranslation(ns, helloTranslations);

const HelloWorld: React.FC = () => {
  const { t } = useTranslation(ns);
  const { data, isLoading, isError } = useHelloWorld();

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        p: 4,
        m: 2,
        bgcolor: 'background.default',
        borderRadius: 2
      }}
    >
      <Typography variant="h3" color="primary.main" gutterBottom>
        {t('title')}
      </Typography>

      {isLoading && <CircularProgress sx={{ mt: 2 }} />}
      {isError && (
        <Typography color="error.main" sx={{ mt: 2 }}>
          {t('error')}
        </Typography>
      )}

      {data && (
        <Box
          sx={{
            mt: 4,
            p: 3,
            bgcolor: 'background.paper',
            borderRadius: '12px',
            boxShadow: 1,
            textAlign: 'center',
            width: '100%',
            maxWidth: 400
          }}
        >
          <Typography variant="body1" color="text.secondary">
            {data?.message}
          </Typography>
        </Box>
      )}
    </Box>
  );
};

const HelloWorldContainer = () => (
  <App>
    <HelloWorld />
  </App>
);

export { HelloWorld };

export default HelloWorldContainer;
