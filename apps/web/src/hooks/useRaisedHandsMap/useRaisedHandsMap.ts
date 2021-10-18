import { useEffect, useState } from 'react';
import useSyncContext from '../useSyncContext/useSyncContext';

export function useRaisedHandsMap() {
  const { raisedHandsMap } = useSyncContext();
  const [raisedHands, setRaisedHands] = useState<string[]>([]);

  useEffect(() => {
    if (raisedHandsMap) {
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
