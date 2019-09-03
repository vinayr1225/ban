import { __ } from '~/locale';

export const namespaceSelectOptions = state => {
  const serializedNamespaces = state.namespaces.map(({ fullPath }) => ({
    id: fullPath,
    text: fullPath,
  }));

  return [
    { text: __('Groups'), children: serializedNamespaces },
    {
      text: __('Users'),
      children: [{ id: state.defaultTargetNamespace, text: state.defaultTargetNamespace }],
    },
  ];
};

export const isImportingAnyRepo = state => state.reposBeingImported.length > 0;

export const hasProviderRepos = state => state.providerRepos.length > 0;

export const hasImportedProjects = state => state.importedProjects.length > 0;

export const concatenatedPath = (path, filter) => {
  if (filter && filter.length > 0) {
    return path.concat(`?filter=${filter}`);
  }

  return path;
};

export const reposPathWithFilter = state => concatenatedPath(state.reposPath, state.filter);
export const jobsPathWithFilter = state => concatenatedPath(state.jobsPath, state.filter);
