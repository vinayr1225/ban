import { shallowMount } from '@vue/test-utils';

import ClusterFormDropdown from '~/create_cluster/eks_cluster/components/cluster_form_dropdown.vue';
import RegionDropdown from '~/create_cluster/eks_cluster/components/region_dropdown.vue';

describe('RegionDropdown', () => {
  const buildVM = (props = {}) =>
    shallowMount(RegionDropdown, {
      propsData: props,
    });

  const getClusterFormDropdown = vm => vm.find(ClusterFormDropdown);

  it('renders a cluster-form-dropdown', () => {
    expect(getClusterFormDropdown(buildVM()).exists()).toBe(true);
  });

  it('sets regions to cluster-form-dropdown items property', () => {
    const regions = [{ name: 'basic' }];

    expect(getClusterFormDropdown(buildVM({ regions })).props('items')).toEqual(regions);
  });

  it('sets a loading text', () => {
    expect(getClusterFormDropdown(buildVM()).props('loadingText')).toEqual('Loading Regions');
  });

  it('sets a placeholder', () => {
    expect(getClusterFormDropdown(buildVM()).props('placeholder')).toEqual('Select a region');
  });

  it('sets an empty results text', () => {
    expect(getClusterFormDropdown(buildVM()).props('emptyText')).toEqual('No region found');
  });

  it('sets a search field placeholder', () => {
    expect(getClusterFormDropdown(buildVM()).props('searchFieldPlaceholder')).toEqual(
      'Search regions',
    );
  });

  it('sets hasErrors property', () => {
    expect(getClusterFormDropdown(buildVM({ error: {} })).props('hasErrors')).toEqual(true);
  });

  it('sets an error message', () => {
    expect(getClusterFormDropdown(buildVM()).props('errorMessage')).toEqual(
      'Could not load regions from your AWS account',
    );
  });
});
