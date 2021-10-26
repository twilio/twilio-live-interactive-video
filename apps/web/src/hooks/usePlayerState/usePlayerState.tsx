import { useEffect, useState } from 'react';
import { Player as TwilioPlayer } from '@twilio/player-sdk';
import usePlayerContext from '../usePlayerContext/usePlayerContext';

export function usePlayerState() {
  const { player } = usePlayerContext();
  const [state, setState] = useState<TwilioPlayer.State>();

  useEffect(() => {
    if (player) {
      const setPlayerState = () => setState(player.state as TwilioPlayer.State);
      setPlayerState();

      player.on(TwilioPlayer.Event.StateChanged, setPlayerState);

      return () => {
        player.off(TwilioPlayer.Event.StateChanged, setPlayerState);
      };
    }
  }, [player]);

  return state;
}
