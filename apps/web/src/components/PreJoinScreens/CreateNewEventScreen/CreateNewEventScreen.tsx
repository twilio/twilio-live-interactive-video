import React, { ChangeEvent, FormEvent } from 'react';
import { Heading } from '@twilio-paste/core/heading';
import { Text } from '@twilio-paste/core/text';
import { Input } from '@twilio-paste/core/input';
import { Label } from '@twilio-paste/core/label';
import { Button } from '@twilio-paste/core/button';
import { Box } from '@twilio-paste/core/box';

import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';

interface CreateNewEventScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function CreateNewEventScreen({ state, dispatch }: CreateNewEventScreenProps) {
  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-event-name', eventName: event.target.value });
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.DeviceSelectionScreen });
  };

  return (
    <>
      <Heading as="h1" variant="heading20">
        Create new event
      </Heading>
      <Text as="p" fontWeight="fontWeightBold" color="colorTextWeak">
        Tip: give your event a name that’s related to the topic you’ll be talking about.
      </Text>
      <Box as="form" onSubmit={handleSubmit}>
        <Box width="100%" marginTop="space70" marginBottom="space150">
          <Label htmlFor="input-event-name">Event Name</Label>
          <Input type="text" id="input-event-name" value={state.eventName} onChange={handleNameChange} />
        </Box>
        <Box display="flex" justifyContent="flex-end">
          <Button variant="primary" type="submit" disabled={!state.eventName}>
            Continue
          </Button>
        </Box>
      </Box>
    </>
  );
}
