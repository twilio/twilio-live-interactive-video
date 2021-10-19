import React, { createContext, useCallback, useState } from 'react';
import { Player as TwilioPlayer } from '@twilio/player-sdk';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { useAppState } from '../../state';

TwilioPlayer.setLogLevel(TwilioPlayer.LogLevel.Error);

type PlayerContextType = {
  player: TwilioPlayer | undefined;
  connect: (token: string) => Promise<void>;
  disconnect: () => void;
};

export const PlayerContext = createContext<PlayerContextType>(null!);

export const PlayerProvider: React.FC = ({ children }) => {
  const { onError } = useVideoContext();
  const [player, setPlayer] = useState<TwilioPlayer>();
  const { appDispatch } = useAppState();

  const connect = useCallback(
    (token: string) => {
      const { protocol, host } = window.location;

      return TwilioPlayer.connect(token, {
        playerWasmAssetsPath: `${protocol}//${host}/player`,
      })
        .then(newPlayer => {
          setPlayer(newPlayer);
          newPlayer.on(TwilioPlayer.Event.StateChanged, (state: TwilioPlayer.State) => {
            if (state === TwilioPlayer.State.Ended) {
              setPlayer(undefined);
              appDispatch({ type: 'reset-state' });
            }
          });
          // @ts-ignore
          window.twilioPlayer = newPlayer;
        })
        .catch(e => {
          console.log(e);
          onError(new Error('There was a problem connecting to the Twilio Live Stream.'));
        });
    },
    [onError, appDispatch]
  );

  const disconnect = () => {
    if (player) {
      if (player.state !== TwilioPlayer.State.Ended) {
        player.disconnect();
      }
      setPlayer(undefined);
    }
  };

  return <PlayerContext.Provider value={{ connect, disconnect, player }}>{children}</PlayerContext.Provider>;
};
