import { useEffect, useState } from 'react';
import { SyncMapItem } from 'twilio-sync';
import useSyncContext from '../useSyncContext/useSyncContext';

interface Speaker extends SyncMapItem {
  data: {
    host: boolean;
  };
}

export function useSpeakersMap() {
  const { speakersMap } = useSyncContext();
  const [speakers, setSpeakers] = useState<string[]>([]);
  const [host, setHost] = useState<string>();

  useEffect(() => {
    if (speakersMap) {
      // Sets the list on load. Limiting to first 100 speakers
      speakersMap.getItems({ pageSize: 100 }).then(paginator => {
        setSpeakers(paginator.items.map(item => item.key));
        const hostItem = paginator.items.find(speaker => (speaker as Speaker).data.host);
        setHost(hostItem?.key);
      });

      const handleItemAdded = (args: any) => {
        setSpeakers(prevSpeakers => [args.item.key, ...prevSpeakers]);
      };

      const handleItemRemoved = (args: any) => {
        setSpeakers(prevSpeakers => prevSpeakers.filter(i => i !== args.key));
      };

      speakersMap.on('itemAdded', handleItemAdded);
      speakersMap.on('itemRemoved', handleItemRemoved);

      return () => {
        speakersMap.off('itemAdded', handleItemAdded);
        speakersMap.off('itemRemoved', handleItemRemoved);
      };
    }
  }, [speakersMap]);

  return {
    speakers,
    host,
  };
}
