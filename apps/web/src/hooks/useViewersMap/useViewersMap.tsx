import { useEffect, useState } from 'react';
import useSyncContext from '../useSyncContext/useSyncContext';

export function useViewersMap() {
  const { viewersMap } = useSyncContext();
  const [viewers, setViewers] = useState<string[]>([]);

  useEffect(() => {
    if (viewersMap) {
      // Sets the list on load. Limiting to first 100 speakers
      viewersMap.getItems({ pageSize: 100 }).then(paginator => {
        setViewers(paginator.items.map(item => item.key));
      });

      const handleItemAdded = (args: any) => {
        setViewers(prevViewers => [...prevViewers, args.item.key]);
      };

      const handleItemRemoved = (args: any) => {
        setViewers(prevViewers => prevViewers.filter(i => i !== args.key));
      };

      viewersMap.on('itemAdded', handleItemAdded);
      viewersMap.on('itemRemoved', handleItemRemoved);

      return () => {
        viewersMap.off('itemAdded', handleItemAdded);
        viewersMap.off('itemRemoved', handleItemRemoved);
      };
    }
  }, [viewersMap]);

  return viewers;
}
