import { shallowMount } from '@vue/test-utils';

import ClusterFormDropdown from '~/create_cluster/eks_cluster/components/cluster_form_dropdown.vue';
import RegionDropdown from '~/create_cluster/eks_cluster/components/region_dropdown.vue';

describe('RegionDropdown', () => {
  const buildVM = (props = {}) =>
    shallowMount(RegionDropdown, {
      propsData: props,
    });

  it('renders a cluster-form-dropdown', () => {
    expect(
      buildVM()
        .find(ClusterFormDropdown)
        .exists(),
    ).toBe(true);
  });

  it('sets regions to cluster-form-dropdown items property', () => {
    const regions = [{ name: 'basic' }];
    const vm = buildVM({ regions });

    expect(vm.find(ClusterFormDropdown).props('items')).toEqual(regions);
  });

  it('sets a loading text', () => {
    const vm = buildVM();

    expect(vm.find(ClusterFormDropdown).props('loadingText')).toEqual('Loading Regions');
  });

  it('sets a placeholder', () => {
    const vm = buildVM();

    expect(vm.find(ClusterFormDropdown).props('placeholder')).toEqual('Select a region');
  });

  it('sets an empty results text', () => {
    const vm = buildVM();

    expect(vm.find(ClusterFormDropdown).props('emptyText')).toEqual('No region found');
  });

  it('sets a search field placeholder', () => {
    const vm = buildVM();

    expect(vm.find(ClusterFormDropdown).props('searchFieldPlaceholder')).toEqual('Search regions');
  });

  it('sets hasErrors property', () => {
    const vm = buildVM({ error: {} });

    expect(vm.find(ClusterFormDropdown).props('hasErrors')).toEqual(true);
  });

  it('sets an error message', () => {
    const vm = buildVM();

    expect(vm.find(ClusterFormDropdown).props('errorMessage')).toEqual(
      'Could not load regions from your AWS account',
    );
  });
});
