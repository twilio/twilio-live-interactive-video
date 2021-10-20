import React from 'react';
import { SnackbarImpl } from './Snackbar';
import { useSnackbar, SnackbarContent, SnackbarProvider as Provider } from 'notistack';

interface SnackbarProps {
  id: string | number;
  headline: string;
  message: string | React.ReactNode;
  variant?: 'error' | 'warning' | 'info';
}

export interface SnackbarMessage {
  headline: string;
  message: string | React.ReactNode;
  variant?: 'error' | 'warning' | 'info';
}

export const Snackbar = React.forwardRef<HTMLDivElement, SnackbarProps>(({ id, headline, message, variant }, ref) => {
  const { closeSnackbar } = useSnackbar();
  console.log('snackbar');
  const handleClose = () => {
    closeSnackbar(id);
  };

  return (
    <SnackbarContent ref={ref}>
      <SnackbarImpl headline={headline} message={message} variant={variant} handleClose={handleClose} />
    </SnackbarContent>
  );
});

export function SnackbarProvider({ children }: { children: React.ReactChild }) {
  return (
    <Provider
      anchorOrigin={{
        vertical: 'top',
        horizontal: 'right',
      }}
      content={(key, message: SnackbarMessage) => (
        <Snackbar id={key} headline={message.headline} message={message.message} variant={message.variant} />
      )}
    >
      {children}
    </Provider>
  );
}
