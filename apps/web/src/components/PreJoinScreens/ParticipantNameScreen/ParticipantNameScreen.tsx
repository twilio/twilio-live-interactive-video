import React, { ChangeEvent, FormEvent } from 'react';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';

import { Heading } from '@twilio-paste/core/heading';
import { Text } from '@twilio-paste/core/text';
import { Input } from '@twilio-paste/core/input';
import { Label } from '@twilio-paste/core/label';
import { Button } from '@twilio-paste/core/button';
import { Box } from '@twilio-paste/core/box';
interface ParticipantNameScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function ParticipantNameScreen({ state, dispatch }: ParticipantNameScreenProps) {
  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-participant-name', participantName: event.target.value });
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.CreateOrJoinScreen });
  };

  return (
    <Box>
      <Text as="p" fontWeight="fontWeightBold" color="colorTextWeak" marginBottom="space20" fontSize="fontSize70">
        Welcome to
      </Text>
      <Heading as="h1" variant="heading10">
        Twilio Live Video Events
      </Heading>
      <Box as="form" onSubmit={handleSubmit}>
        <Box width="100%" marginTop="space70" marginBottom="space150">
          <Label htmlFor="input-user-name">Full Name</Label>
          <Input type="text" id="input-user-name" value={state.participantName} onChange={handleNameChange} />
        </Box>
        <Box display="flex" justifyContent="flex-end">
          <Button variant="primary" type="submit" disabled={!state.participantName}>
            Continue
          </Button>
        </Box>
      </Box>
    </Box>
  );
}
