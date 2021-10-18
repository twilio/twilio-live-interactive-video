import { useContext } from 'react';
import { SyncContext } from '../../components/SyncProvider';

export default function useSyncContext() {
  const context = useContext(SyncContext);
  if (!context) {
    throw new Error('useSyncContext must be used within a SyncProvider');
  }
  return context;
}
