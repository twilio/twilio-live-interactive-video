import React from 'react';
import MainParticipant from './MainParticipant';
import ParticipantTracks from '../ParticipantTracks/ParticipantTracks';
import { shallow } from 'enzyme';
import useMainParticipant from '../../hooks/useMainParticipant/useMainParticipant';
import useSelectedParticipant from '../VideoProvider/useSelectedParticipant/useSelectedParticipant';
import usePresentationParticipant from '../../hooks/usePresentationParticipant/usePresentationParticipant';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';

jest.mock('../../hooks/useMainParticipant/useMainParticipant');
jest.mock('../VideoProvider/useSelectedParticipant/useSelectedParticipant');
jest.mock('../../hooks/usePresentationParticipant/usePresentationParticipant');
jest.mock('../../hooks/useVideoContext/useVideoContext');

const mockuseMainParticipant = useMainParticipant as jest.Mock<any>;
const mockUseSelectedParticipant = useSelectedParticipant as jest.Mock<any>;
const mockUsePresentationParticipant = usePresentationParticipant as jest.Mock<any>;
const mockUseVideoContext = useVideoContext as jest.Mock<any>;

const mockLocalParticipant = {};

describe('the MainParticipant component', () => {
  mockUseVideoContext.mockImplementation(() => ({
    room: {
      localParticipant: mockLocalParticipant,
    },
  }));

  it('should set the videoPriority to high when the main participant is the selected participant', () => {
    const mockParticipant = {};
    mockuseMainParticipant.mockImplementationOnce(() => mockParticipant);
    mockUseSelectedParticipant.mockImplementationOnce(() => [mockParticipant]);
    mockUsePresentationParticipant.mockImplementationOnce(() => ({}));
    const wrapper = shallow(<MainParticipant />);
    expect(wrapper.find(ParticipantTracks).prop('videoPriority')).toBe('high');
  });

  it('should set the videoPriority to high when the main participant is presenting content', () => {
    const mockParticipant = {};
    mockuseMainParticipant.mockImplementationOnce(() => mockParticipant);
    mockUseSelectedParticipant.mockImplementationOnce(() => [{}]);
    mockUsePresentationParticipant.mockImplementationOnce(() => mockParticipant);
    const wrapper = shallow(<MainParticipant />);
    expect(wrapper.find(ParticipantTracks).prop('videoPriority')).toBe('high');
  });

  describe('when the main participant is the localParticipant', () => {
    const mockParticipant = {};
    mockuseMainParticipant.mockImplementation(() => mockParticipant);
    mockUseSelectedParticipant.mockImplementation(() => [{}]);
    mockUsePresentationParticipant.mockImplementation(() => mockParticipant);
    mockUseVideoContext.mockImplementation(() => ({
      room: {
        localParticipant: mockParticipant,
      },
    }));

    const wrapper = shallow(<MainParticipant />);

    it('should not set the videoPriority', () => {
      expect(wrapper.find(ParticipantTracks).prop('videoPriority')).toBe(null);
    });

    it('should set the enablePresentationMode prop to false', () => {
      expect(wrapper.find(ParticipantTracks).prop('enablePresentationMode')).toBe(false);
    });

    it('should set the isLocalParticipant prop to true', () => {
      expect(wrapper.find(ParticipantTracks).prop('isLocalParticipant')).toBe(true);
    });
  });

  it('should set the videoPriority to null when the main participant is not the selected participant and they are not presenting content', () => {
    const mockParticipant = {};
    mockuseMainParticipant.mockImplementationOnce(() => mockParticipant);
    mockUseSelectedParticipant.mockImplementationOnce(() => [{}]);
    mockUsePresentationParticipant.mockImplementationOnce(() => ({}));
    const wrapper = shallow(<MainParticipant />);
    expect(wrapper.find(ParticipantTracks).prop('videoPriority')).toBe(null);
  });
});
