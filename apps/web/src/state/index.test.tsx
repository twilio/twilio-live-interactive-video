import React from 'react';
import { act, renderHook } from '@testing-library/react-hooks';

import AppStateProvider, { useAppState } from './index';
import usePasscodeAuth from './usePasscodeAuth/usePasscodeAuth';

jest.mock('./usePasscodeAuth/usePasscodeAuth', () => jest.fn(() => ({ user: 'passcodeUser' })));
jest.mock('./useActiveSinkId/useActiveSinkId.ts', () => () => ['default', () => {}]);

// @ts-ignore
window.fetch = jest.fn(() =>
  Promise.resolve({
    text: () => 'mockVideoToken',
    json: () => ({
      token: 'mockVideoToken',
    }),
  })
);

const wrapper: React.FC = ({ children }) => <AppStateProvider>{children}</AppStateProvider>;

describe('the useAppState hook', () => {
  beforeEach(jest.clearAllMocks);
  beforeEach(() => (process.env = {} as any));

  it('should set an error', () => {
    const { result } = renderHook(useAppState, { wrapper });
    act(() => result.current.setError(new Error('testError')));
    expect(result.current.error!.message).toBe('testError');
  });

  it('should throw an error if used outside of AppStateProvider', () => {
    const { result } = renderHook(useAppState);
    expect(result.error.message).toEqual('useAppState must be used within the AppStateProvider');
  });

  describe('the passcode functionality', () => {
    it('should use the usePasscodeAuth hook', async () => {
      const { result } = renderHook(useAppState, { wrapper });
      expect(usePasscodeAuth).toHaveBeenCalled();
      expect(result.current.user).toBe('passcodeUser');
    });
  });
});
