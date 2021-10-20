import { useEffect, useState } from 'react';
import useSyncContext from '../useSyncContext/useSyncContext';

export function useRaisedHandsMap() {
  const { raisedHandsMap } = useSyncContext();
  const [raisedHands, setRaisedHands] = useState<string[]>([]);

  useEffect(() => {
    if (raisedHandsMap) {
      // Sets the list on load. Limiting to first 100 viewers who are raising their hand
      raisedHandsMap.getItems({ pageSize: 100 }).then(paginator => {
        setRaisedHands(paginator.items.map(item => item.key));
      });

      const handleItemAdded = (args: any) => {
        setRaisedHands(prevRaisedHands => [args.item.key, ...prevRaisedHands]);
      };

      const handleItemRemoved = (args: any) => {
        setRaisedHands(prevRaisedHands => prevRaisedHands.filter(i => i !== args.key));
      };

      raisedHandsMap.on('itemAdded', handleItemAdded);
      raisedHandsMap.on('itemRemoved', handleItemRemoved);

      return () => {
        raisedHandsMap.off('itemAdded', handleItemAdded);
        raisedHandsMap.on('itemRemoved', handleItemRemoved);
      };
    }
  }, [raisedHandsMap]);

  return raisedHands;
}
