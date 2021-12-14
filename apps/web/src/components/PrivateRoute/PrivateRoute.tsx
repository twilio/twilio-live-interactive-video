import React from 'react';
import { Location } from 'history';
import { Redirect, Route, RouteProps } from 'react-router-dom';
import { useAppState } from '../../state';

export default function PrivateRoute({ children, ...rest }: RouteProps) {
  const { isAuthReady, user } = useAppState();

  if (!user && !isAuthReady) {
    return null;
  }

  function getRedirectTo(location: Location) {
    const redirectTo = {
      pathname: '/login',
      search: '',
    };

    if (location.pathname !== '/') {
      redirectTo.search = '?redirect=' + location.pathname;
    }

    return redirectTo;
  }

  return <Route {...rest} render={({ location }) => (user ? children : <Redirect to={getRedirectTo(location)} />)} />;
}
