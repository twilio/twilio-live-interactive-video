import { OptionsObject, useSnackbar } from 'notistack';
import { SnackbarMessage } from '../../components/Snackbar/SnackbarProvider';

export function useEnqueueSnackbar() {
  const { enqueueSnackbar } = useSnackbar();
  // This is so useSnackbar has the right type signature
  return (message: SnackbarMessage, options?: OptionsObject) => enqueueSnackbar(message, options);
}
