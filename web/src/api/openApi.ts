import { extensionManager } from '@/utils/extension';

export const fetchOpenInit = async () => {
  const axios = extensionManager.getExtAxios({ open: true });
  const response = await axios.get('/open/init');
  return response.data;
};
