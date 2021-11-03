import React from 'react';
import { Button, Grid, Typography } from '@material-ui/core';
import MenuBar from './MenuBar';
import { shallow } from 'enzyme';
import ToggleAudioButton from '../Buttons/ToggleAudioButton/ToggleAudioButton';
import ToggleChatButton from '../Buttons/ToggleChatButton/ToggleChatButton';
import TogglePresentationModeButton from '../Buttons/TogglePresentationModeButton/TogglePresentationModeButton';
import ToggleVideoButton from '../Buttons/ToggleVideoButton/ToggleVideoButton';
import useRoomState from '../../hooks/useRoomState/useRoomState';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import * as utils from '../../utils';

jest.mock('../../hooks/useRoomState/useRoomState');
jest.mock('../../hooks/useVideoContext/useVideoContext');

const mockUseRoomState = useRoomState as jest.Mock<any>;
const mockUseVideoContext = useVideoContext as jest.Mock<any>;

mockUseVideoContext.mockImplementation(() => ({
  isPresenting: false,
  togglePresentationMode: () => {},
  room: { name: 'Test Room' },
}));

mockUseRoomState.mockImplementation(() => 'connected');

describe('the MenuBar component', () => {
  beforeEach(() => {
    //@ts-ignore
    utils.isMobile = false;
    process.env.REACT_APP_DISABLE_TWILIO_CONVERSATIONS = 'false';
  });

  it('should disable toggle buttons while reconnecting to the room', () => {
    mockUseRoomState.mockImplementationOnce(() => 'reconnecting');
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(ToggleAudioButton).prop('disabled')).toBe(true);
    expect(wrapper.find(ToggleVideoButton).prop('disabled')).toBe(true);
    expect(wrapper.find(TogglePresentationModeButton).prop('disabled')).toBe(true);
  });

  it('should enable toggle buttons while connected to the room', () => {
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(ToggleAudioButton).prop('disabled')).toBe(false);
    expect(wrapper.find(ToggleVideoButton).prop('disabled')).toBe(false);
    expect(wrapper.find(TogglePresentationModeButton).prop('disabled')).toBe(false);
  });

  it('should hide the TogglePresentationModeButton and show the "You are sharing your screen" banner when isPresenting is true', () => {
    mockUseVideoContext.mockImplementationOnce(() => ({
      isPresenting: true,
      togglePresentationMode: () => {},
      room: { name: 'Test Room' },
    }));
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(TogglePresentationModeButton).exists()).toBe(false);
    expect(
      wrapper
        .find(Grid)
        .at(0)
        .find(Typography)
        .text()
    ).toBe('You are sharing your screen');
  });

  it('should display the TogglePresentationModeButton when isPresenting is false and isMobile is false', () => {
    mockUseVideoContext.mockImplementationOnce(() => ({
      isPresenting: false,
      togglePresentationMode: () => {},
      room: { name: 'Test Room' },
    }));
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(TogglePresentationModeButton).exists()).toBe(true);
  });

  it('should hide the TogglePresentationModeButton when isPresenting is false and isMobile is true', () => {
    mockUseVideoContext.mockImplementationOnce(() => ({
      isPresenting: false,
      togglePresentationMode: () => {},
      room: { name: 'Test Room' },
    }));
    // @ts-ignore
    utils.isMobile = true;
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(TogglePresentationModeButton).exists()).toBe(false);
  });

  it('should render the ToggleChatButton when REACT_APP_DISABLE_TWILIO_CONVERSATIONS is not true', () => {
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(ToggleChatButton).exists()).toBe(true);
  });

  it('should hide the ToggleChatButton when REACT_APP_DISABLE_TWILIO_CONVERSATIONS is true', () => {
    process.env.REACT_APP_DISABLE_TWILIO_CONVERSATIONS = 'true';
    const wrapper = shallow(<MenuBar />);
    expect(wrapper.find(ToggleChatButton).exists()).toBe(false);
  });

  it('should call togglePresentationMode when the "Stop Sharing" button is clicked', () => {
    const mockTogglePresentationMode = jest.fn();
    mockUseVideoContext.mockImplementationOnce(() => ({
      isPresenting: true,
      togglePresentationMode: mockTogglePresentationMode,
      room: { name: 'Test Room' },
    }));
    const wrapper = shallow(<MenuBar />);

    wrapper
      .find(Grid)
      .at(0)
      .find(Button)
      .simulate('click');

    expect(mockTogglePresentationMode).toHaveBeenCalledTimes(1);
  });
});
