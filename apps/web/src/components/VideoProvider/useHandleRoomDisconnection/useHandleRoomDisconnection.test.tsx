import { act, renderHook } from '@testing-library/react-hooks';
import { Room } from 'twilio-video';
import EventEmitter from 'events';
import useHandleRoomDisconnection from './useHandleRoomDisconnection';

const mockOnError = jest.fn();
const mockRemoveLocalAudioTrack = jest.fn();
const mockRemoveLocalVideoTrack = jest.fn();
const mockTogglePresentationMode = jest.fn();

describe('the useHandleRoomDisconnection hook', () => {
  let mockRoom: any = new EventEmitter();

  beforeEach(jest.clearAllMocks);

  it('should do nothing if the room emits a "disconnected" event with no error', () => {
    renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        false,
        mockTogglePresentationMode
      )
    );
    act(() => {
      mockRoom.emit('disconnected', mockRoom);
    });
    expect(mockOnError).not.toHaveBeenCalled();
  });

  it('should react to the rooms "disconnected" event and invoke onError callback if there is an error', () => {
    renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        false,
        mockTogglePresentationMode
      )
    );
    act(() => {
      mockRoom.emit('disconnected', mockRoom, 'mockError');
    });
    expect(mockOnError).toHaveBeenCalledWith('mockError');
  });

  it('should remove local tracks when the "disconnected" event is emitted', () => {
    renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        false,
        mockTogglePresentationMode
      )
    );
    act(() => {
      mockRoom.emit('disconnected', mockRoom, 'mockError');
    });
    expect(mockRemoveLocalAudioTrack).toHaveBeenCalled();
    expect(mockRemoveLocalVideoTrack).toHaveBeenCalled();
  });

  it('should not toggle Presentation Mode when the "disconnected" event is emitted and isPresenting is false', () => {
    renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        false,
        mockTogglePresentationMode
      )
    );
    act(() => {
      mockRoom.emit('disconnected', mockRoom, 'mockError');
    });
    expect(mockTogglePresentationMode).not.toHaveBeenCalled();
  });

  it('should toggle Presentation Mode  when the "disconnected" event is emitted and isPresenting is true', () => {
    renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        true,
        mockTogglePresentationMode
      )
    );
    act(() => {
      mockRoom.emit('disconnected', mockRoom, 'mockError');
    });
    expect(mockTogglePresentationMode).toHaveBeenCalled();
  });

  it('should tear down old listeners when receiving a new room', () => {
    const originalMockRoom = mockRoom;
    const { rerender } = renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        false,
        mockTogglePresentationMode
      )
    );
    expect(originalMockRoom.listenerCount('disconnected')).toBe(1);

    act(() => {
      mockRoom = new EventEmitter() as Room;
    });

    rerender();

    expect(originalMockRoom.listenerCount('disconnected')).toBe(0);
    expect(mockRoom.listenerCount('disconnected')).toBe(1);
  });

  it('should clean up listeners on unmount', () => {
    const { unmount } = renderHook(() =>
      useHandleRoomDisconnection(
        mockRoom,
        mockOnError,
        mockRemoveLocalAudioTrack,
        mockRemoveLocalVideoTrack,
        false,
        mockTogglePresentationMode
      )
    );
    unmount();
    expect(mockRoom.listenerCount('disconnected')).toBe(0);
  });
});
