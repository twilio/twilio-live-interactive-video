import React from 'react';
import { mount, shallow } from 'enzyme';
import usePresentationParticipant from '../../../hooks/usePresentationParticipant/usePresentationParticipant';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';

import TogglePresentationModeButton, {
  SCREEN_SHARE_TEXT,
  SHARE_IN_PROGRESS_TEXT,
  SHARE_NOT_SUPPORTED_TEXT,
} from './TogglePresentationModeButton';
import ScreenShareIcon from '../../../icons/ScreenShareIcon';
import { Button, Tooltip } from '@material-ui/core';

jest.mock('../../../hooks/usePresentationParticipant/usePresentationParticipant');
jest.mock('../../../hooks/useVideoContext/useVideoContext');

const mockUsePresentationParticipant = usePresentationParticipant as jest.Mock<any>;
const mockUseVideoContext = useVideoContext as jest.Mock<any>;

const mockTogglePresentationMode = jest.fn();
mockUseVideoContext.mockImplementation(() => ({ togglePresentationMode: mockTogglePresentationMode }));

Object.defineProperty(navigator, 'mediaDevices', {
  value: {
    getDisplayMedia: () => {},
  },
  configurable: true,
});

describe('the TogglePresentationModeButton component', () => {
  it('should render correctly when Presentation Mode is allowed', () => {
    const wrapper = mount(<TogglePresentationModeButton />);
    expect(wrapper.find(ScreenShareIcon).exists()).toBe(true);
    expect(wrapper.text()).toBe(SCREEN_SHARE_TEXT);
  });

  it('should render correctly when another user is presenting content', () => {
    mockUsePresentationParticipant.mockImplementationOnce(() => 'mockParticipant');
    const wrapper = mount(<TogglePresentationModeButton />);
    expect(wrapper.find(Button).prop('disabled')).toBe(true);
    expect(wrapper.find(Tooltip).prop('title')).toBe(SHARE_IN_PROGRESS_TEXT);
  });

  it('should call the correct toggle function when clicked', () => {
    const wrapper = shallow(<TogglePresentationModeButton />);
    wrapper.find(Button).simulate('click');
    expect(mockTogglePresentationMode).toHaveBeenCalled();
  });

  it('should render the presentation mode button with the correct messaging if Presentation Mode is not supported', () => {
    Object.defineProperty(navigator, 'mediaDevices', { value: { getDisplayMedia: undefined } });
    const wrapper = mount(<TogglePresentationModeButton />);
    expect(wrapper.find(Button).prop('disabled')).toBe(true);
    expect(wrapper.find(Tooltip).prop('title')).toBe(SHARE_NOT_SUPPORTED_TEXT);
  });
});
