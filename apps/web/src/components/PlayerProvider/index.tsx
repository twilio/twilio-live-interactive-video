import React, { createContext, useCallback, useEffect, useState } from 'react';
import { Player as TwilioPlayer } from '@twilio/live-player-sdk';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { useAppState } from '../../state';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';

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
  const enqueueSnackbar = useEnqueueSnackbar();
  const { appState } = useAppState();

  const connect = useCallback(
    (token: string) => {
      const { protocol, host } = window.location;

      return TwilioPlayer.connect(token, {
        playerWasmAssetsPath: `${protocol}//${host}/player`,
      })
        .then(newPlayer => {
          setPlayer(newPlayer);
          // @ts-ignore
          window.twilioPlayer = newPlayer;
        })
        .catch(e => {
          console.log(e);
          onError(new Error('There was a problem connecting to the Twilio Live Stream.'));
        });
    },
    [onError]
  );

  const disconnect = () => {
    if (player) {
      if (player.state !== TwilioPlayer.State.Ended) {
        player.disconnect();
      }
      setPlayer(undefined);
    }
  };

  useEffect(() => {
    if (player) {
      const handleEnded = (state: TwilioPlayer.State) => {
        if (state === TwilioPlayer.State.Ended) {
          setPlayer(undefined);

          if (!appState.hasSpeakerInvite) {
            // If there is a speaker invite, the user is moving from a viewer to a speaker, so
            // we don't show this message.
            enqueueSnackbar({
              headline: 'Event has ended',
              message: 'The event has been ended by the host.',
              variant: 'error',
            });
            appDispatch({ type: 'reset-state' });
          }
        }
      };

      player.on(TwilioPlayer.Event.StateChanged, handleEnded);
      return () => {
        player.off(TwilioPlayer.Event.StateChanged, handleEnded);
      };
    }
  }, [player, enqueueSnackbar, appDispatch, appState]);

  return <PlayerContext.Provider value={{ connect, disconnect, player }}>{children}</PlayerContext.Provider>;
};
