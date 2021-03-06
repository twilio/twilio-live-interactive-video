import { act, renderHook } from '@testing-library/react-hooks';
import { Location } from 'history';
import { useHistory, useLocation } from 'react-router-dom';
import usePasscodeAuth, { getPasscode, verifyPasscode } from './usePasscodeAuth';

jest.mock('react-router-dom', () => ({
  useLocation: jest.fn(),
  useHistory: jest.fn(),
}));

const mockUseLocation = useLocation as jest.Mock<any>;
const mockUseHistory = useHistory as jest.Mock<any>;

const mockReplace = jest.fn();
mockUseHistory.mockImplementation(() => ({ replace: mockReplace }));

describe('the usePasscodeAuth hook', () => {
  describe('on first render', () => {
    beforeEach(() => window.sessionStorage.clear());
    it('should return a user when the passcode is valid', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ ok: true, json: () => Promise.resolve({ token: 'mockVideoToken' }) })
      );
      mockUseLocation.mockImplementation(() => ({ search: '' }));
      window.sessionStorage.setItem('passcode', '123123');
      const { result, waitForNextUpdate } = renderHook(usePasscodeAuth);
      await waitForNextUpdate();
      expect(result.current).toMatchObject({ isAuthReady: true, user: { passcode: '123123' } });
    });

    it('should remove the query parameter from the URL when the passcode is valid', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ ok: true, json: () => Promise.resolve({ token: 'mockVideoToken' }) })
      );

      mockUseLocation.mockImplementation(() => ({ search: '?passcode=000000', pathname: '/test-pathname' }));
      const { waitForNextUpdate } = renderHook(usePasscodeAuth);
      await waitForNextUpdate();
      expect(mockReplace).toHaveBeenLastCalledWith('/test-pathname');
    });

    it('should not return a user when the app code is invalid', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ status: 401, json: () => Promise.resolve({ type: 'errorMessage' }) })
      );
      mockUseLocation.mockImplementation(() => ({ search: '' }));
      window.sessionStorage.setItem('passcode', '123123');
      const { result, waitForNextUpdate } = renderHook(usePasscodeAuth);
      await waitForNextUpdate();
      expect(result.current).toMatchObject({ isAuthReady: true, user: null });
    });

    it('should not return a user when there is no passcode', () => {
      const { result } = renderHook(usePasscodeAuth);
      expect(result.current).toMatchObject({ isAuthReady: true, user: null });
    });
  });

  describe('signout function', () => {
    it('should clear session storage and user on signout', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ ok: true, json: () => Promise.resolve({ token: 'mockVideoToken' }) })
      );
      window.sessionStorage.setItem('passcode', '123123');
      const { result, waitForNextUpdate } = renderHook(usePasscodeAuth);
      await waitForNextUpdate();
      await act(() => result.current.signOut());
      expect(window.sessionStorage.getItem('passcode')).toBe(null);
      expect(result.current.user).toBe(null);
    });
  });

  describe('signin function', () => {
    it('should set a user when a valid passcode is submitted', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ ok: true, json: () => Promise.resolve({ token: 'mockVideoToken' }) })
      );
      const { result } = renderHook(usePasscodeAuth);
      await act(() => result.current.signIn('123456'));
      expect(result.current.user).toEqual({ passcode: '123456' });
    });

    it('should return an error when an invalid passcode is submitted', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ status: 401, json: () => Promise.resolve({ error: { message: 'passcode incorrect' } }) })
      );
      const { result, waitForNextUpdate } = renderHook(usePasscodeAuth);
      await waitForNextUpdate();
      result.current.signIn('123456').catch(err => {
        expect(err.message).toBe('Passcode is incorrect');
      });
    });

    it('should return an error when an expired passcode is submitted', async () => {
      // @ts-ignore
      window.fetch = jest.fn(() =>
        Promise.resolve({ status: 401, json: () => Promise.resolve({ error: { message: 'passcode expired' } }) })
      );
      const { result, waitForNextUpdate } = renderHook(usePasscodeAuth);
      await waitForNextUpdate();
      result.current.signIn('123456').catch(err => {
        expect(err.message).toBe('Passcode has expired');
      });
    });
  });
});

describe('the getPasscode function', () => {
  beforeEach(() => window.sessionStorage.clear());

  it('should return the passcode from session storage', () => {
    const mockLocation = { search: '' } as Location;
    window.sessionStorage.setItem('passcode', '123123');
    expect(getPasscode(mockLocation)).toBe('123123');
  });

  it('should return the passcode from the URL', () => {
    const mockLocation = { search: '?passcode=234234' } as Location;

    expect(getPasscode(mockLocation)).toBe('234234');
  });

  it('should return the passcode from the URL when the app code is also stored in sessionstorage', () => {
    window.sessionStorage.setItem('passcode', '123123');
    const mockLocation = { search: '?passcode=234234' } as Location;

    expect(getPasscode(mockLocation)).toBe('234234');
  });

  it('should return null when there is no passcode', () => {
    const mockLocation = { search: '' } as Location;
    expect(getPasscode(mockLocation)).toBe(null);
  });
});

describe('the verifyPasscode function', () => {
  it('should return the correct response when the passcode is valid', async () => {
    // @ts-ignore
    window.fetch = jest.fn(() =>
      Promise.resolve({ ok: true, json: () => Promise.resolve({ token: 'mockVideoToken' }) })
    );

    const result = await verifyPasscode('123456');
    expect(result).toEqual({ isValid: true });
  });

  it('should return the correct response when the passcode is invalid', async () => {
    // @ts-ignore
    window.fetch = jest.fn(() =>
      Promise.resolve({ status: 401, json: () => Promise.resolve({ error: { message: 'errorMessage' } }) })
    );

    const result = await verifyPasscode('123456');
    expect(result).toEqual({ isValid: false, error: 'errorMessage' });
  });

  it('should call the API with the correct parameters', async () => {
    await verifyPasscode('123456');
    expect(window.fetch).toHaveBeenLastCalledWith('/token', {
      body:
        '{"user_identity":"temp-name","room_name":"temp-room","passcode":"123456","create_room":false,"create_conversation":false}',
      headers: { 'content-type': 'application/json' },
      method: 'POST',
    });
  });
});
