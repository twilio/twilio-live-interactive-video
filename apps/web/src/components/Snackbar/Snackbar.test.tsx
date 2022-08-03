import { shallow } from 'enzyme';
import React from 'react';
import { SnackbarImpl } from './Snackbar';

describe('the Snackbar component', () => {
  it('should render correctly with "warning" variant', () => {
    const wrapper = shallow(
      <SnackbarImpl variant="warning" headline="Test Headline" message="Test Message" handleClose={() => {}} />
    );
    expect(wrapper).toMatchSnapshot();
  });

  it('should render correctly with "error" variant', () => {
    const wrapper = shallow(
      <SnackbarImpl variant="error" headline="Test Headline" message="Test Message" handleClose={() => {}} />
    );
    expect(wrapper).toMatchSnapshot();
  });

  it('should render correctly with "info" variant', () => {
    const wrapper = shallow(
      <SnackbarImpl variant="info" headline="Test Headline" message="Test Message" handleClose={() => {}} />
    );
    expect(wrapper).toMatchSnapshot();
  });

  it('should render correctly with no handleClose function provided', () => {
    const wrapper = shallow(<SnackbarImpl variant="error" headline="Test Headline" message="Test Message" />);
    expect(wrapper).toMatchSnapshot();
  });
});
