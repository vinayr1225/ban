import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import EksClusterConfigurationForm from '~/create_cluster/eks_cluster/components/eks_cluster_configuration_form.vue';
import RegionDropdown from '~/create_cluster/eks_cluster/components/region_dropdown.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('EksClusterConfigurationForm', () => {
  let store;
  let actions;
  let state;

  beforeEach(() => {
    actions = {
      fetchRegions: jest.fn(),
    };
    state = {
      regions: [{ name: 'region 1' }],
      isLoadingRegions: false,
      loadingRegionsError: { message: '' },
    };
    store = new Vuex.Store({
      state,
      actions,
    });
  });

  const buildVM = (props = {}) =>
    shallowMount(EksClusterConfigurationForm, {
      propsData: props,
      localVue,
      store,
    });

  describe('when mounted', () => {
    it('fetches available regions', () => {
      buildVM();
      expect(actions.fetchRegions).toHaveBeenCalled();
    });
  });

  it('sets isLoadingRegions to RegionDropdown loading property', () => {
    state.isLoadingRegions = true;

    const vm = buildVM();

    expect(vm.find(RegionDropdown).props('loading')).toEqual(state.isLoadingRegions);
  });

  it('sets regions to RegionDropdown regions property', () => {
    const vm = buildVM();

    expect(vm.find(RegionDropdown).props('regions')).toEqual(state.regions);
  });

  it('sets loadingRegionsError to RegionDropdown error property', () => {
    const vm = buildVM();

    expect(vm.find(RegionDropdown).props('error')).toEqual(state.loadingRegionsError);
  });
});
