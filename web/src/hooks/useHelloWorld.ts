import { fetchOpenInit } from '@/api/openApi';
import { useQuery } from '@tanstack/react-query';

export const useHelloWorld = () => {
  return useQuery({
    queryKey: ['openInit'],
    queryFn: fetchOpenInit
  });
};
