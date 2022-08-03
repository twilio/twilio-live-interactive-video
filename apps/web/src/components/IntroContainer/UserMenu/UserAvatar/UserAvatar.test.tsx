import React from 'react';
import { shallow } from 'enzyme';
import Person from '@material-ui/icons/Person';
import UserAvatar from './UserAvatar';

describe('the UserAvatar component', () => {
  it('should display the Person icon', () => {
    const wrapper = shallow(<UserAvatar />);
    expect(wrapper.find(Person).exists()).toBe(true);
  });
});
