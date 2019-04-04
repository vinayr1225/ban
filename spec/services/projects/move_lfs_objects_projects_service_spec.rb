require 'spec_helper'

describe Projects::MoveLfsObjectsProjectsService do
  let!(:user) { create(:user) }
  let!(:project_with_lfs_objects) { create(:project, namespace: user.namespace) }
  let!(:target_project) { create(:project, namespace: user.namespace) }

  subject { described_class.new(target_project, user) }

  before do
    create_list(:lfs_objects_project, 3, project: project_with_lfs_objects)
  end

  describe '#execute' do
    it 'links the lfs objects from existent in source project' do
      expect(target_project.lfs_objects.size).to eq 0

      subject.execute(project_with_lfs_objects)

      expect(project_with_lfs_objects.reload.lfs_objects.size).to eq 0
      expect(target_project.reload.lfs_objects.size).to eq 3
    end

    it 'does not link existent lfs_object in the current project' do
      target_project.lfs_objects << project_with_lfs_objects.lfs_objects.first(2)

      expect(target_project.lfs_objects.size).to eq 2

      subject.execute(project_with_lfs_objects)

      expect(target_project.lfs_objects.size).to eq 3
    end

    it 'rollbacks changes if transaction fails' do
      allow(subject).to receive(:success).and_raise(StandardError)

      expect { subject.execute(project_with_lfs_objects) }.to raise_error(StandardError)

      expect(project_with_lfs_objects.lfs_objects.size).to eq 3
      expect(target_project.lfs_objects.size).to eq 0
    end

    context 'when remove_remaining_elements is false' do
      let(:options) { { remove_remaining_elements: false } }

      it 'does not remove remaining lfs objects' do
        target_project.lfs_objects << project_with_lfs_objects.lfs_objects.first(2)

        subject.execute(project_with_lfs_objects, options)

        expect(project_with_lfs_objects.lfs_objects.size).not_to eq 0
      end
    end
  end
end
